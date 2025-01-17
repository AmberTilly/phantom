!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2025 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.github.io/                                             !
!--------------------------------------------------------------------------!
module kernel
!
! This module implements the M_4 cubic kernel
!   DO NOT EDIT - auto-generated by kernels.py
!
! :References: None
!
! :Owner: Daniel Price
!
! :Runtime parameters: None
!
! :Dependencies: physcon
!
 use physcon, only:pi
 implicit none
 character(len=9), public :: kernelname = 'M_4 cubic'
 real, parameter, public  :: radkern  = 2.
 real, parameter, public  :: radkern2 = 4.
 real, parameter, public  :: cnormk = 1./pi
 real, parameter, public  :: wab0 = 1., gradh0 = -3.*wab0
 real, parameter, public  :: dphidh0 = 1.4
 real, parameter, public  :: cnormk_drag = 10./(9.*pi)
 real, parameter, public  :: hfact_default = 1.2
 real, parameter, public  :: av_factor = 124./105.

contains

pure subroutine get_kernel(q2,q,wkern,grkern)
 real, intent(in)  :: q2,q
 real, intent(out) :: wkern,grkern

 !--M_4 cubic
 if (q < 1.) then
    wkern  = 0.75*q2*q - 1.5*q2 + 1.
    grkern = q*(2.25*q - 3.)
 elseif (q < 2.) then
    wkern  = -0.25*(q - 2.)**3
    grkern = -0.75*(q - 2.)**2
 else
    wkern  = 0.
    grkern = 0.
 endif

end subroutine get_kernel

pure elemental real function wkern(q2,q)
 real, intent(in) :: q2,q

 if (q < 1.) then
    wkern = 0.75*q2*q - 1.5*q2 + 1.
 elseif (q < 2.) then
    wkern = -0.25*(q - 2.)**3
 else
    wkern = 0.
 endif

end function wkern

pure elemental real function grkern(q2,q)
 real, intent(in) :: q2,q

 if (q < 1.) then
    grkern = q*(2.25*q - 3.)
 elseif (q < 2.) then
    grkern = -0.75*(q - 2.)**2
 else
    grkern = 0.
 endif

end function grkern

pure subroutine get_kernel_grav1(q2,q,wkern,grkern,dphidh)
 real, intent(in)  :: q2,q
 real, intent(out) :: wkern,grkern,dphidh
 real :: q4

 if (q < 1.) then
    q4 = q2*q2
    wkern  = 0.75*q2*q - 1.5*q2 + 1.
    grkern = q*(2.25*q - 3.)
    dphidh = -0.6*q4*q + 1.5*q4 - 2.*q2 + 1.4
 elseif (q < 2.) then
    q4 = q2*q2
    wkern  = -0.25*(q - 2.)**3
    grkern = -0.75*(q - 2.)**2
    dphidh = 0.2*q4*q - 1.5*q4 + 4.*q2*q - 4.*q2 + 1.6
 else
    wkern  = 0.
    grkern = 0.
    dphidh = 0.
 endif

end subroutine get_kernel_grav1

pure subroutine kernel_softening(q2,q,potensoft,fsoft)
 real, intent(in)  :: q2,q
 real, intent(out) :: potensoft,fsoft
 real :: q4, q6

 if (q < 1.) then
    q4 = q2*q2
    potensoft = q4*q/10. - 3.*q4/10. + 2.*q2/3. - 7./5.
    fsoft     = q*(15.*q2*q - 36.*q2 + 40.)/30.
 elseif (q < 2.) then
    q4 = q2*q2
    q6 = q4*q2
    potensoft = (q*(-q4*q + 9.*q4 - 30.*q2*q + 40.*q2 - 48.) + 2.)/(30.*q)
    fsoft     = (-5.*q6 + 36.*q4*q - 90.*q4 + 80.*q2*q - 2.)/(30.*q2)
 else
    potensoft = -1./q
    fsoft     = 1./q2
 endif

end subroutine kernel_softening

!------------------------------------------
! gradient acceleration kernel needed for
! use in Forward symplectic integrator
!------------------------------------------
pure subroutine kernel_grad_soft(q2,q,gsoft)
 real, intent(in)  :: q2,q
 real, intent(out) :: gsoft
 real :: q4

 if (q < 1.) then
    gsoft = q2*q*(1.5*q - 2.4)
 elseif (q < 2.) then
    q4 = q2*q2
    gsoft = (q4*(-0.5*q2 + 2.4*q - 3.) + 0.2)/q2
 else
    gsoft = -3./q2
 endif

end subroutine kernel_grad_soft

!------------------------------------------
! double-humped version of the kernel for
! use in drag force calculations
!------------------------------------------
pure elemental real function wkern_drag(q2,q)
 real, intent(in) :: q2,q

 !--double hump M_4 cubic kernel
 if (q < 1.) then
    wkern_drag = q2*(0.75*q2*q - 1.5*q2 + 1.)
 elseif (q < 2.) then
    wkern_drag = -0.25*q2*(q - 2.)**3
 else
    wkern_drag = 0.
 endif

end function wkern_drag

end module kernel
