""" to compile this use:
>>> python setup.py build_ext --inplace

to generate html report use:
>>> cython -a crank16.pxd

"""

#cython: cdivision=True
#cython: boundscheck=False
#cython: nonecheck=False
#cython: wraparound=False

import numpy as np
cimport numpy as np

# import main loop
from _core16b cimport _core16b

# -----------------------------------------------------------------
# kernels uint16 take extra parameter for defining the bitdepth
# -----------------------------------------------------------------


cdef inline np.uint16_t kernel_mean(int* histo, float pop, np.uint16_t g,int bitdepth,int maxbin, int midbin, int s0, int s1):
    cdef int i,bilat_pop=0
    cdef float mean = 0.

    if pop:
        for i in range(maxbin):
            if (g>(i-s0)) and (g<(i+s1)):
                bilat_pop += histo[i]
                mean += histo[i]*i
        if bilat_pop:
            return <np.uint16_t>(mean/bilat_pop)
        else:
            return <np.uint16_t>(0)
    else:
        return <np.uint16_t>(0)


cdef inline np.uint16_t kernel_pop(int* histo, float pop, np.uint16_t g,int bitdepth,int maxbin, int midbin, int s0, int s1):
    cdef int i,bilat_pop=0

    if pop:
        for i in range(maxbin):
            if (g>(i-s0)) and (g<(i+s1)):
                bilat_pop += histo[i]
        return <np.uint16_t>(bilat_pop)
    else:
        return <np.uint16_t>(0)


# -----------------------------------------------------------------
# python wrappers
# -----------------------------------------------------------------
def mean(np.ndarray[np.uint16_t, ndim=2] image,
            np.ndarray[np.uint8_t, ndim=2] selem,
            np.ndarray[np.uint8_t, ndim=2] mask=None,
            np.ndarray[np.uint16_t, ndim=2] out=None,
            char shift_x=0, char shift_y=0, int bitdepth=8, int s0=1, int s1=1):
    """average gray level (clipped on uint8)
    """
    return _core16b(kernel_mean,image,selem,mask,out,shift_x,shift_y,bitdepth,s0,s1)


def pop(np.ndarray[np.uint16_t, ndim=2] image,
            np.ndarray[np.uint8_t, ndim=2] selem,
            np.ndarray[np.uint8_t, ndim=2] mask=None,
            np.ndarray[np.uint16_t, ndim=2] out=None,
            char shift_x=0, char shift_y=0, int bitdepth=8, int s0=1, int s1=1):
    """returns the number of actual pixels of the structuring element inside the mask
    """
    return _core16b(kernel_pop,image,selem,mask,out,shift_x,shift_y,bitdepth,s0,s1)

