# coding: utf-8
# cython: boundscheck=False
# cython: nonecheck=False
# cython: cdivision=True
# cython: wraparound=False
# cython: language_level=3

# Standard library
from collections import OrderedDict
from libc.math cimport M_PI

# Third party
from astropy.constants import G
import numpy as np
cimport numpy as np
np.import_array()
import cython
cimport cython

# Gala
from gala.units import galactic
from gala.potential.potential.cpotential cimport (CPotentialWrapper,
                                                  MAX_N_COMPONENTS, CPotential)
from gala.potential.potential.cpotential import CPotentialBase

cdef extern from "extra_compile_macros.h":
    int USE_GSL

cdef extern from "src/funcdefs.h":
    ctypedef double (*densityfunc)(double t, double *pars, double *q, int n_dim) nogil
    ctypedef double (*energyfunc)(double t, double *pars, double *q, int n_dim) nogil
    ctypedef void (*gradientfunc)(double t, double *pars, double *q, int n_dim, double *grad) nogil

cdef extern from "scf/src/bfe.h":
    double scf_value(double t, double *pars, double *q, int n_dim) nogil
    double scf_density(double t, double *pars, double *q, int n_dim) nogil
    void scf_gradient(double t, double *pars, double *q, int n_dim, double *grad) nogil

    double scf_interp_value(double t, double *pars, double *q, int n_dim) nogil
    double scf_interp_density(double t, double *pars, double *q, int n_dim) nogil
    void scf_interp_gradient(double t, double *pars, double *q, int n_dim, double *grad) nogil

__all__ = ['SCFPotential', 'InterpolatedSCFPotential']


gsl_err_msg = ("Gala was compiled without GSL and so the {classname} class "
               "will not work.  See the gala documentation for more "
               "information about installing and using GSL with gala: "
               "http://gala.adrian.pw/en/latest/install.html")


cdef class SCFWrapper(CPotentialWrapper):

    def __init__(self, G, parameters, q0, R):
        self.init([G] + list(parameters),
                  np.ascontiguousarray(q0),
                  np.ascontiguousarray(R))
        if USE_GSL == 1:
            self.cpotential.value[0] = <energyfunc>(scf_value)
            self.cpotential.density[0] = <densityfunc>(scf_density)
            self.cpotential.gradient[0] = <gradientfunc>(scf_gradient)


class SCFPotential(CPotentialBase):
    r"""
    SCFPotential(m, r_s, Snlm, Tnlm, units=None, origin=None, R=None)
    A gravitational potential represented as a basis function expansion.  This
    uses the self-consistent field (SCF) method of Hernquist & Ostriker (1992)
    and Lowing et al. (2011), and represents all coefficients as real
    quantities.
    Parameters
    ----------
    m : numeric
        Scale mass.
    r_s : numeric
        Scale length.
    Snlm : array_like
        Array of coefficients for the cos() terms of the expansion.
        This should be a 3D array with shape `(nmax+1, lmax+1, lmax+1)`,
        where `nmax` is the number of radial expansion terms and `lmax`
        is the number of spherical harmonic `l` terms.
    Tnlm : array_like
        Array of coefficients for the sin() terms of the expansion.
        This should be a 3D array with shape `(nmax+1, lmax+1, lmax+1)`,
        where `nmax` is the number of radial expansion terms and `lmax`
        is the number of spherical harmonic `l` terms.
    units : iterable
        Unique list of non-reducable units that specify (at minimum) the
        length, mass, time, and angle units.
    """
    _physical_types = {'m': 'mass',
                       'r_s': 'length',
                       'nmax': 'dimensionless',
                       'lmax': 'dimensionless',
                       'Snlm': 'dimensionless',
                       'Tnlm': 'dimensionless'}

    def __init__(self, m, r_s, Snlm, Tnlm=None, units=None,
                 origin=None, R=None):
        from gala._cconfig import GSL_ENABLED
        if not GSL_ENABLED:
            raise ValueError(gsl_err_msg.format('SCFPotential'))

        Snlm = np.array(Snlm)

        if Tnlm is None:
            Tnlm = np.zeros_like(Snlm)
        Tnlm = np.array(Tnlm)

        if Snlm.shape != Tnlm.shape:
            raise ValueError("Shape of coefficient arrays must match! "
                             "({} vs {})".format(Snlm.shape, Tnlm.shape))

        # extra parameters
        nmax = Tnlm.shape[0]-1
        lmax = Tnlm.shape[1]-1

        parameters = OrderedDict()
        parameters['m'] = m
        parameters['r_s'] = r_s
        parameters['nmax'] = nmax
        parameters['lmax'] = lmax
        parameters['Snlm'] = Snlm
        parameters['Tnlm'] = Tnlm

        # TODO: I need to save the full 3D Snlm, Tnlm and ravel elsewhere

        super(SCFPotential, self).__init__(parameters=parameters,
                                           units=units,
                                           Wrapper=SCFWrapper,
                                           origin=origin,
                                           R=R,
                                           c_only=['nmax', 'lmax']) # don't expose these in the .parameters dictionary


cdef class InterpolatedSCFWrapper(CPotentialWrapper):

    def __init__(self, G, parameters, q0, R):
        self.init([G] + list(parameters),
                  np.ascontiguousarray(q0),
                  np.ascontiguousarray(R))
        if USE_GSL == 1:
            self.cpotential.value[0] = <energyfunc>(scf_interp_value)
            self.cpotential.density[0] = <densityfunc>(scf_interp_density)
            self.cpotential.gradient[0] = <gradientfunc>(scf_interp_gradient)


class InterpolatedSCFPotential(CPotentialBase):
    r"""
    InterpolatedSCFPotential(m, r_s, Sjnlm, Tjnlm, tj, comj, units=None, origin=None, R=None)
    TODO: update copy-pasta docstring
    A gravitational potential represented as a basis function expansion.  This
    uses the self-consistent field (SCF) method of Hernquist & Ostriker (1992)
    and Lowing et al. (2011), and represents all coefficients as real
    quantities.
    Parameters
    ----------
    m : numeric
        Scale mass.
    r_s : numeric
        Scale length.
    Snlm : array_like
        Array of coefficients for the cos() terms of the expansion.
        This should be a 3D array with shape `(nmax+1, lmax+1, lmax+1)`,
        where `nmax` is the number of radial expansion terms and `lmax`
        is the number of spherical harmonic `l` terms.
    Tnlm : array_like
        Array of coefficients for the sin() terms of the expansion.
        This should be a 3D array with shape `(nmax+1, lmax+1, lmax+1)`,
        where `nmax` is the number of radial expansion terms and `lmax`
        is the number of spherical harmonic `l` terms.
    units : iterable
        Unique list of non-reducable units that specify (at minimum) the
        length, mass, time, and angle units.
    """
    _physical_types = {'m': 'mass',
                       'r_s': 'length',
                       'nmax': 'dimensionless',
                       'lmax': 'dimensionless',
                       'Sjnlm': 'dimensionless',
                       'Tjnlm': 'dimensionless',
                       'tj': 'time',
                       'originj': 'length'}

    def __init__(self, m, r_s, Sjnlm, Tjnlm, tj, originj=None, units=None):
        from gala._cconfig import GSL_ENABLED
        if not GSL_ENABLED:
            raise ValueError(gsl_err_msg.format('InterpolatedSCFPotential'))

        Sjnlm = np.array(Sjnlm)
        Tjnlm = np.array(Tjnlm)
        tj = np.array(tj)

        # extra parameters
        ntimes = Sjnlm.shape[0]
        nmax = Sjnlm.shape[1] - 1
        lmax = Sjnlm.shape[2] - 1

        if originj is None:
            originj = np.zeros((ntimes, 3))
        else:
            originj = np.array(originj)

        if Sjnlm.shape != Tjnlm.shape:
            raise ValueError("Shape of coefficient arrays must match! "
                             f"({Sjnlm.shape} vs {Tjnlm.shape})")

        parameters = OrderedDict()
        parameters['m'] = m
        parameters['r_s'] = r_s
        parameters['nmax'] = nmax
        parameters['lmax'] = lmax
        parameters['ntimes'] = ntimes
        parameters['Sjnlm'] = Sjnlm
        parameters['Tjnlm'] = Tjnlm
        parameters['tj'] = tj
        parameters['originj'] = originj

        super().__init__(
            parameters=parameters, units=units, Wrapper=InterpolatedSCFWrapper,
            origin=None, R=None,
            c_only=['nmax', 'lmax', 'ntimes']) # don't expose these