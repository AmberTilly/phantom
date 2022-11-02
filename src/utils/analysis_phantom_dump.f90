module analysis
!
! analysis
!
! :References: None
!
! :Owner: Megha Sharma
!
! :Runtime parameters: None
!
! :Dependencies: centreofmass, dump_utils, eos, fileutils, io, part,
!   physcon, prompting, readwrite_dumps, sortutils, units, vectorutils
!
!
! Module for generating KEPLER file from a TDE dumpfile.
!
!
 implicit none
 character(len=3), parameter, public :: analysistype = 'tde'
 public :: do_analysis

 private

contains
 !----------------------------------------------------------------
 !+
 !  routine to write an input file for KEPLER.
 !  uses phantom_to_kepler_arrays subroutine.
 !+
 !----------------------------------------------------------------
subroutine do_analysis(dumpfile,numfile,xyzh,vxyzu,pmass,npart,time,iunit)

 use io,              only : warning
 use dump_utils,      only : read_array_from_file
 use units,           only : udist,umass,unit_density,unit_ergg,unit_velocity,utime !units required to convert to kepler units.
 use prompting,       only : prompt
 use readwrite_dumps, only : opened_full_dump
 use sortutils,       only : set_r2func_origin,indexxfunc,r2func_origin

 integer,  intent(in) :: numfile,npart,iunit
 integer              :: i,j,location
 integer              :: ngrid = 0
 real :: xpos(3),pos(3),rad_test




 character(len=120)                :: output
 character(len=*),intent(in)       :: dumpfile


 !If dumpfile is not a complete dump we don't read it.
 if (.not.opened_full_dump) then
    write(*,'("SKIPPING FILE -- (Not a full dump)")')
    return
 endif


 !allocate for composition_kepler
 !Print the analysis being done
 write(*,'("Performing analysis type ",A)') analysistype
 write(*,'("Input file name is ",A)') dumpfile

 call set_r2func_origin(xpos(1),xpos(2),xpos(3))
 call indexxfunc(npart,r2func_origin,xyzh,iorder)
 location = minloc(xyzh(4,:),dim=1)
 xpos(:) = xyzh(1:3,location)
 do j = 1, npart

    i  = iorder(j) !Access the rank of each particle in radius.

    !the position of the particle is calculated by subtracting the point of highest density.
    !xyzh is position wrt the black hole present at origin.
    pos(:) = xyzh(1:3,i) - xpos(:)

    !calculate the position which is the location of the particle.
    rad_test    = sqrt(dot_product(pos(:),pos(:)))

    if (i==npart) then
      print*,"radius max", rad_test*udist
      print*,pmass*i*umass,"total mass"
    endif 

  enddo
end subroutine do_analysis
