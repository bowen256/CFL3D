      subroutine bc2007(jdim,kdim,idim,q,qj0,qk0,qi0,sj,sk,si,bcj,bck,
     .                  bci,xtbj,xtbk,xtbi,atbj,atbk,atbi,ista,iend,
     .                  jsta,jend,ksta,kend,nface,tursav,tj0,tk0,
     .                  ti0,vist3d,vj0,vk0,vi0,mdim,ndim,bcdata,
     .                  filname,iuns,nou,bou,nbuf,ibufdim,myid)
c
c     $Id$
c
c***********************************************************************
c     Purpose:  Set all primative variables with standard cfl3d 
c               normalization; rho/rho_inf, u/a_inf, v/a_inf,
c               w/a_inf, p/(rho_inf*a_inf**2), and up to two
c               turbulence quantities.
c***********************************************************************
c
#   ifdef CMPLX
      implicit complex(a-h,o-z)
#   endif
c
      character*120 bou(ibufdim,nbuf)
      character*80 filname
c
      dimension nou(nbuf)
      dimension q(jdim,kdim,idim,5), qi0(jdim,kdim,5,4),
     .          qj0(kdim,idim-1,5,4),qk0(jdim,idim-1,5,4)
      dimension sk(jdim,kdim,idim-1,5),si(jdim,kdim,idim,5),
     .          sj(jdim,kdim,idim-1,5)
      dimension bcj(kdim,idim-1,2),bck(jdim,idim-1,2),bci(jdim,kdim,2)
      dimension xtbj(kdim,idim-1,3,2),xtbk(jdim,idim-1,3,2),
     .          xtbi(jdim,kdim,3,2),atbj(kdim,idim-1,3,2),
     .          atbk(jdim,idim-1,3,2),atbi(jdim,kdim,3,2)
      dimension bcdata(mdim,ndim,2,7)
      dimension tursav(jdim,kdim,idim,2),tj0(kdim,idim-1,2,4),
     .          tk0(jdim,idim-1,2,4),ti0(jdim,kdim,2,4),
     .          vj0(kdim,idim-1,1,4),vk0(jdim,idim-1,1,4),
     .          vi0(jdim,kdim,1,4),vist3d(jdim,kdim,idim)
c
      common /maxiv/ ivmx
      common /mgrd/ levt,kode,mode,ncyc,mtt,icyc,level,lglobal
      common /reyue/ reue,tinf,ivisc(3)
      common /sklton/ isklton
c
      jdim1 = jdim-1
      kdim1 = kdim-1
      idim1 = idim-1
c
      jend1 = jend-1
      kend1 = kend-1
      iend1 = iend-1
c
c     this bc makes use of two planes of data (for ndata>0 in the input
c     deck, the two planes are identical; for ndata<0 in the input deck,
c     the two planes are set by the data file and may differ to reflect
c     two distinct planes of ghost cells)
c
c            * * * * * * * * * * * * * * * * * * * * * *
c            * standard boundary condition bctype=2007 *
c            * * * * * * * * * * * * * * * * * * * * * *
c
c******************************************************************************
c      j=1 boundary           set all primative variables           bctype 2007
c******************************************************************************
c
      if (nface.eq.3) then
c
c     check to see if turbulence data is input (itrflg1/2 = 1) or
c     if freestream values are to be used (itrflg1/2 = 0); the check
c     assumes if the first point has been set, all points have been
c
      ipp     = 1
      itrflg1 = 0
      itrflg2 = 0
      if (real(bcdata(1,1,ipp,6)) .ge. 0.) itrflg1 = 1
      if (real(bcdata(1,1,ipp,7)) .ge. 0.) itrflg2 = 1
c
      if (isklton.eq.1) then
c
c        check that the required auxiliary data has been set
         iflg = 0
         do 1 l=1,5
         do 1 ipp=1,2
         do 1 i=ista,iend1
         ii = i-ista+1
         do 1 k=ksta,kend1
         kk = k-ksta+1
         if (real(bcdata(kk,ii,ipp,l)) .lt. -1.e10) iflg = 1
   1     continue
         if (iflg.eq.1) then
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),*)'  Stopping in bc2007:'
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),*)'  primative variable data ',
     .                         'incorrectly set'
            call termn8(myid,-1,ibufdim,nbuf,bou,nou)
         end if
         if (itrflg1.gt.0 .or. itrflg2.gt.0) then
            if (ivmx.gt.5 .and. itrflg1*itrflg2.eq.0) then
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),*)'  stopping in bc2007...must',
     .         ' set both turbulence'
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),*)'  quantities for 2-eq turb.',
     .         ' models...only one is set'
               call termn8(myid,-1,ibufdim,nbuf,bou,nou)
            end if
         end if
c 
         if (filname.eq.'null') then
            rho1 = bcdata(1,1,1,1)
            u1   = bcdata(1,1,1,2)
            v1   = bcdata(1,1,1,3)
            w1   = bcdata(1,1,1,4)
            p1   = bcdata(1,1,1,5)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1001)ista,iend,ksta,kend
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1007) real(rho1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1008) real(u1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1009) real(v1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1010) real(w1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1011) real(p1)
            if (itrflg1.gt.0) then
               t1 = bcdata(1,1,1,6)
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),1014) real(t1)
            end if
            if (itrflg2.gt.0) then
               t2 = bcdata(1,1,1,7)
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),1015) real(t2)
            end if
         else
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2001)ista,iend,ksta,kend
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2007)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2008)filname
         end if
c
      end if
c
      do 100 l=1,5
      do 100 ip=1,2
      do 100 i=ista,iend1
      ii = i-ista+1
      do 100 k=ksta,kend1
      kk = k-ksta+1
      qj0(k,i,l,ip) = bcdata(kk,ii,ip,l)
      bcj(k,i,1) = 0.0
  100 continue
      if (ivisc(3).ge.2 .or. ivisc(2).ge.2 .or. ivisc(1).ge.2) then
        do 191 i=ista,iend1
        do 191 k=ksta,kend1
          vj0(k,i,1,1) = vist3d(1,k,i)
          vj0(k,i,1,2) = vist3d(1,k,i)
  191   continue
      end if
c   only need to do advanced model turbulence B.C.s on finest grid
      if (level .ge. lglobal) then
      if (ivisc(3).ge.4 .or. ivisc(2).ge.4 .or. ivisc(1).ge.4) then
        do 101 i=ista,iend1
        ii = i-ista+1
        do 101 k=ksta,kend1
          kk=k-ksta+1
          ip = 1
          t11 = (1 - itrflg1)*tursav(1,k,i,1) 
     .        + itrflg1*bcdata(kk,ii,ip,6)
          t21 = (1 - itrflg2)*tursav(1,k,i,2) 
     .        + itrflg2*bcdata(kk,ii,ip,7)
          ip = 2
          t12 = (1 - itrflg1)*tursav(1,k,i,1)
     .        + itrflg1*bcdata(kk,ii,ip,6)
          t22 = (1 - itrflg2)*tursav(1,k,i,2)
     .        + itrflg2*bcdata(kk,ii,ip,7)
          tj0(k,i,1,1) = t11
          tj0(k,i,2,1) = t21
          tj0(k,i,1,2) = t12
          tj0(k,i,2,2) = t22
  101   continue
      end if
      end if
      end if
c
c******************************************************************************
c      j=jdim boundary          set all primative variables         bctype 2007
c******************************************************************************
c 
      if (nface.eq.4) then
c
c     check to see if turbulence data is input (itrflg1/2 = 1) or
c     if freestream values are to be used (itrflg1/2 = 0); the check
c     assumes if the first point has been set, all points have been
c
      ipp     = 1
      itrflg1 = 0
      itrflg2 = 0
      if (real(bcdata(1,1,ipp,6)) .ge. 0.) itrflg1 = 1
      if (real(bcdata(1,1,ipp,7)) .ge. 0.) itrflg2 = 1
c
      itrflg1 = 0
      itrflg2 = 0
      if (real(bcdata(1,1,ip,6)) .ge. 0.) itrflg1 = 1
      if (real(bcdata(1,1,ip,7)) .ge. 0.) itrflg2 = 1
c
      if (isklton.eq.1) then
c
c        check that the required auxiliary data has been set
         iflg = 0
         do 2 l=1,5
         do 2 ipp=1,2
         do 2 i=ista,iend1
         ii = i-ista+1
         do 2 k=ksta,kend1
         kk = k-ksta+1
         if (real(bcdata(kk,ii,ipp,l)) .lt. -1.e10) iflg = 1
   2     continue
         if (iflg.eq.1) then
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),*)'  Stopping in bc2007:'
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),*)'  primative variable data ',
     .                         'incorrectly set'
            call termn8(myid,-1,ibufdim,nbuf,bou,nou)
         end if
         if (itrflg1.gt.0 .or. itrflg2.gt.0) then
            if (ivmx.gt.5 .and. itrflg1*itrflg2.eq.0) then
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),*)'  stopping in bc2007...must',
     .         ' set both turbulence'
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),*)'  quantities for 2-eq turb.',
     .         ' models...only one is set'
               call termn8(myid,-1,ibufdim,nbuf,bou,nou)
            end if
         end if
c
         if (filname.eq.'null') then
            rho1 = bcdata(1,1,1,1)
            u1   = bcdata(1,1,1,2)
            v1   = bcdata(1,1,1,3)
            w1   = bcdata(1,1,1,4)
            p1   = bcdata(1,1,1,5)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1002)ista,iend,ksta,kend
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1007) real(rho1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1008) real(u1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1009) real(v1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1010) real(w1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1011) real(p1)
            if (itrflg1.gt.0) then
               t1 = bcdata(1,1,1,6)
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),1014) real(t1)
            end if
            if (itrflg2.gt.0) then
               t2 = bcdata(1,1,1,7)
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),1015) real(t2)
            end if
         else
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2002)ista,iend,ksta,kend
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2007)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2008)filname
         end if
c
      end if
c
      do 200 l=1,5
      do 200 ip=1,2
      do 200 i=ista,iend1
      ii = i-ista+1
      do 200 k=ksta,kend1
      kk = k-ksta+1
      qj0(k,i,l,ip+2) = bcdata(kk,ii,ip,l)
      bcj(k,i,2) = 0.0
  200 continue
      if (ivisc(3).ge.2 .or. ivisc(2).ge.2 .or. ivisc(1).ge.2) then
        do 291 i=ista,iend1
        do 291 k=ksta,kend1
          vj0(k,i,1,3) = vist3d(jdim1,k,i)
          vj0(k,i,1,4) = vist3d(jdim1,k,i)
  291   continue
      end if
c   only need to do advanced model turbulence B.C.s on finest grid
      if (level .ge. lglobal) then
      if (ivisc(3).ge.4 .or. ivisc(2).ge.4 .or. ivisc(1).ge.4) then
        do 201 i=ista,iend1
        ii=i-ista+1
        do 201 k=ksta,kend1
          kk=k-ksta+1
          ip = 1
          t13 = (1 - itrflg1)*tursav(jdim1,k,i,1)
     .        + itrflg1*bcdata(kk,ii,ip,6)
          t23 = (1 - itrflg2)*tursav(jdim1,k,i,2)
     .        + itrflg2*bcdata(kk,ii,ip,7)
          ip = 2
          t14 = (1 - itrflg1)*tursav(jdim1,k,i,1)
     .        + itrflg1*bcdata(kk,ii,ip,6)
          t24 = (1 - itrflg2)*tursav(jdim1,k,i,2)
     .        + itrflg2*bcdata(kk,ii,ip,7)
          tj0(k,i,1,3) = t13
          tj0(k,i,2,3) = t23
          tj0(k,i,1,4) = t14
          tj0(k,i,2,4) = t24
  201   continue
      end if
      end if
      end if
c
c******************************************************************************
c      k=1 boundary           set all primative variables           bctype 2007
c******************************************************************************
c
      if (nface.eq.5) then
c
c     check to see if turbulence data is input (itrflg1/2 = 1) or
c     if freestream values are to be used (itrflg1/2 = 0); the check
c     assumes if the first point has been set, all points have been
c
      ipp     = 1
      itrflg1 = 0
      itrflg2 = 0
      if (real(bcdata(1,1,ipp,6)) .ge. 0.) itrflg1 = 1
      if (real(bcdata(1,1,ipp,7)) .ge. 0.) itrflg2 = 1
c
      if (isklton.eq.1) then
c
c        check that the required auxiliary data has been set
         iflg = 0
         do 3 l=1,5
         do 3 ipp=1,2
         do 3 i=ista,iend1
         ii = i-ista+1
         do 3 j=jsta,jend1
         jj = j-jsta+1
         if (real(bcdata(jj,ii,ipp,l)) .lt. -1.e10) iflg = 1
   3     continue
         if (iflg.eq.1) then
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),*)'  Stopping in bc2007:'
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),*)'  primative variable data ',
     .                         'incorrectly set'
            call termn8(myid,-1,ibufdim,nbuf,bou,nou)
         end if
         if (itrflg1.gt.0 .or. itrflg2.gt.0) then
            if (ivmx.gt.5 .and. itrflg1*itrflg2.eq.0) then
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),*)'  stopping in bc2007...must',
     .         ' set both turbulence'
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),*)'  quantities for 2-eq turb.',
     .         ' models...only one is set'
               call termn8(myid,-1,ibufdim,nbuf,bou,nou)
            end if
         end if
c
         if (filname.eq.'null') then
            rho1 = bcdata(1,1,1,1)
            u1   = bcdata(1,1,1,2)
            v1   = bcdata(1,1,1,3)
            w1   = bcdata(1,1,1,4)
            p1   = bcdata(1,1,1,5)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1003)ista,iend,ksta,kend
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1007) real(rho1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1008) real(u1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1009) real(v1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1010) real(w1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1011) real(p1)
            if (itrflg1.gt.0) then
               t1 = bcdata(1,1,1,6)
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),1014) real(t1)
            end if
            if (itrflg2.gt.0) then
               t2 = bcdata(1,1,1,7)
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),1015) real(t2)
            end if
         else
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2003)ista,iend,jsta,jend
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2007)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2008)filname
         end if
c
      end if
c
      do 300 l=1,5
      do 300 ip=1,2
      do 300 i=ista,iend1
      ii = i-ista+1
      do 300 j=jsta,jend1
      jj = j-jsta+1
      qk0(j,i,l,ip) = bcdata(jj,ii,ip,l)
      bck(j,i,1) = 0.0
  300 continue
      if (ivisc(3).ge.2 .or. ivisc(2).ge.2 .or. ivisc(1).ge.2) then
        do 391 i=ista,iend1
        do 391 j=jsta,jend1
          vk0(j,i,1,1) = vist3d(j,1,i)
          vk0(j,i,1,2) = vist3d(j,1,i)
  391   continue
      end if
c   only need to do advanced model turbulence B.C.s on finest grid
      if (level .ge. lglobal) then
      if (ivisc(3).ge.4 .or. ivisc(2).ge.4 .or. ivisc(1).ge.4) then
        do 301 i=ista,iend1
        ii=i-ista+1
        do 301 j=jsta,jend1
          jj=j-jsta+1
          ip = 1
          t11 = (1 - itrflg1)*tursav(j,1,i,1)
     .        + itrflg1*bcdata(jj,ii,ip,6)
          t21 = (1 - itrflg2)*tursav(j,1,i,2)
     .        + itrflg2*bcdata(jj,ii,ip,7)
          ip = 2
          t12 = (1 - itrflg1)*tursav(j,1,i,1)
     .        + itrflg1*bcdata(jj,ii,ip,6)
          t22 = (1 - itrflg2)*tursav(j,1,i,2)
     .        + itrflg2*bcdata(jj,ii,ip,7)
          tk0(j,i,1,1) = t11
          tk0(j,i,2,1) = t21
          tk0(j,i,1,2) = t12
          tk0(j,i,2,2) = t22
  301   continue
      end if
      end if
      end if
c
c******************************************************************************
c      k=kdim boundary          set all primative variables         bctype 2007
c******************************************************************************
c
      if (nface.eq.6) then
c
c     check to see if turbulence data is input (itrflg1/2 = 1) or
c     if freestream values are to be used (itrflg1/2 = 0); the check
c     assumes if the first point has been set, all points have been
c
      ipp     = 1
      itrflg1 = 0
      itrflg2 = 0
      if (real(bcdata(1,1,ipp,6)) .ge. 0.) itrflg1 = 1
      if (real(bcdata(1,1,ipp,7)) .ge. 0.) itrflg2 = 1
c
      if (isklton.eq.1) then
c
c        check that the required auxiliary data has been set
         iflg = 0
         do 4 l=1,5
         do 4 ipp=1,2
         do 4 i=ista,iend1
         ii = i-ista+1
         do 4 j=jsta,jend1
         jj = j-jsta+1
         if (real(bcdata(jj,ii,ipp,l)) .lt. -1.e10) iflg = 1
   4     continue
         if (iflg.eq.1) then
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),*)'  Stopping in bc2007:'
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),*)'  primative variable data ',
     .                         'incorrectly set'
            call termn8(myid,-1,ibufdim,nbuf,bou,nou)
         end if
         if (itrflg1.gt.0 .or. itrflg2.gt.0) then
            if (ivmx.gt.5 .and. itrflg1*itrflg2.eq.0) then
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),*)'  stopping in bc2007...must',
     .         ' set both turbulence'
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),*)'  quantities for 2-eq turb.',
     .         ' models...only one is set'
               call termn8(myid,-1,ibufdim,nbuf,bou,nou)
            end if
         end if
c
         if (filname.eq.'null') then
            rho1 = bcdata(1,1,1,1)
            u1   = bcdata(1,1,1,2)
            v1   = bcdata(1,1,1,3)
            w1   = bcdata(1,1,1,4)
            p1   = bcdata(1,1,1,5)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1004)ista,iend,ksta,kend
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1007) real(rho1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1008) real(u1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1009) real(v1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1010) real(w1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1011) real(p1)
            if (itrflg1.gt.0) then
               t1 = bcdata(1,1,1,6)
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),1014) real(t1)
            end if
            if (itrflg2.gt.0) then
               t2 = bcdata(1,1,1,7)
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),1015) real(t2)
            end if
         else
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2004)ista,iend,jsta,jend
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2007)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2008)filname
         end if
c
      end if
c
      do 400 l=1,5
      do 400 ip=1,2
      do 400 i=ista,iend1
      ii = i-ista+1
      do 400 j=jsta,jend1
      jj = j-jsta+1
      qk0(j,i,l,ip+2) = bcdata(jj,ii,ip,l)
      bck(j,i,2) = 0.0
  400 continue
      if (ivisc(3).ge.2 .or. ivisc(2).ge.2 .or. ivisc(1).ge.2) then
        do 491 i=ista,iend1
        do 491 j=jsta,jend1
          vk0(j,i,1,3) = vist3d(j,kdim1,i)
          vk0(j,i,1,4) = vist3d(j,kdim1,i)
  491   continue
      end if
c   only need to do advanced model turbulence B.C.s on finest grid
      if (level .ge. lglobal) then
      if (ivisc(3).ge.4 .or. ivisc(2).ge.4 .or. ivisc(1).ge.4) then
        do 401 i=ista,iend1
        ii=i-ista+1
        do 401 j=jsta,jend1
          jj=j-jsta+1
          ip = 1
          t13 = (1 - itrflg1)*tursav(j,kdim1,i,1)
     .        + itrflg1*bcdata(jj,ii,ip,6)
          t23 = (1 - itrflg2)*tursav(j,kdim1,i,2)
     .        + itrflg2*bcdata(jj,ii,ip,7)
          ip = 2
          t14 = (1 - itrflg1)*tursav(j,kdim1,i,1)
     .        + itrflg1*bcdata(jj,ii,ip,6)
          t24 = (1 - itrflg2)*tursav(j,kdim1,i,2)
     .        + itrflg2*bcdata(jj,ii,ip,7)
          tk0(j,i,1,3) = t13
          tk0(j,i,2,3) = t23
          tk0(j,i,1,4) = t14
          tk0(j,i,2,4) = t24
  401   continue
      end if
      end if
      end if
c
c******************************************************************************
c      i=1 boundary           set all primative variables           bctype 2007
c******************************************************************************
c
      if (nface.eq.1) then
c
c     check to see if turbulence data is input (itrflg1/2 = 1) or
c     if freestream values are to be used (itrflg1/2 = 0); the check
c     assumes if the first point has been set, all points have been
c
      ipp     = 1
      itrflg1 = 0
      itrflg2 = 0
      if (real(bcdata(1,1,ipp,6)) .ge. 0.) itrflg1 = 1
      if (real(bcdata(1,1,ipp,7)) .ge. 0.) itrflg2 = 1
c
      if (isklton.eq.1) then
c
c        check that the required auxiliary data has been set
         iflg = 0
         do 5 l=1,5
         do 5 ipp=1,2
         do 5 k=ksta,kend1
         kk = k-ksta+1
         do 5 j=jsta,jend1
         jj = j-jsta+1
         if (real(bcdata(jj,kk,ipp,l)) .lt. -1.e10) iflg = 1
   5     continue
         if (iflg.eq.1) then
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),*)'  Stopping in bc2007:'
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),*)'  primative variable data ',
     .                         'incorrectly set'
            call termn8(myid,-1,ibufdim,nbuf,bou,nou)
         end if
         if (itrflg1.gt.0 .or. itrflg2.gt.0) then
            if (ivmx.gt.5 .and. itrflg1*itrflg2.eq.0) then
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),*)'  stopping in bc2007...must',
     .         ' set both turbulence'
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),*)'  quantities for 2-eq turb.',
     .         ' models...only one is set'
               call termn8(myid,-1,ibufdim,nbuf,bou,nou)
            end if
         end if
c
         if (filname.eq.'null') then
            rho1 = bcdata(1,1,1,1)
            u1   = bcdata(1,1,1,2)
            v1   = bcdata(1,1,1,3)
            w1   = bcdata(1,1,1,4)
            p1   = bcdata(1,1,1,5)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1005)ista,iend,ksta,kend
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1007) real(rho1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1008) real(u1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1009) real(v1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1010) real(w1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1011) real(p1)
            if (itrflg1.gt.0) then
               t1 = bcdata(1,1,1,6)
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),1014) real(t1)
            end if
            if (itrflg2.gt.0) then
               t2 = bcdata(1,1,1,7)
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),1015) real(t2)
            end if
         else
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2005)jsta,jend,ksta,kend
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2007)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2008)filname
         end if
c
      end if
c
      do 500 l=1,5
      do 500 ip=1,2
      do 500 k=ksta,kend1
      kk = k-ksta+1
      do 500 j=jsta,jend1
      jj = j-jsta+1
      qi0(j,k,l,ip) = bcdata(jj,kk,ip,l)
      bci(j,k,1) = 0.0
  500 continue
      if (ivisc(3).ge.2 .or. ivisc(2).ge.2 .or. ivisc(1).ge.2) then
        do 591 k=ksta,kend1
        do 591 j=jsta,jend1
          vi0(j,k,1,1) = vist3d(j,k,1)
          vi0(j,k,1,2) = vist3d(j,k,1)
  591   continue
      end if
c   only need to do advanced model turbulence B.C.s on finest grid
      if (level .ge. lglobal) then
      if (ivisc(3).ge.4 .or. ivisc(2).ge.4 .or. ivisc(1).ge.4) then
        do 501 k=ksta,kend1
        kk=k-ksta+1
        do 501 j=jsta,jend1
          jj=j-jsta+1
          ip = 1
          t11 = (1 - itrflg1)*tursav(j,k,1,1)
     .        + itrflg1*bcdata(jj,kk,ip,6)
          t21 = (1 - itrflg2)*tursav(j,k,1,2)
     .        + itrflg2*bcdata(jj,kk,ip,7)
          ip = 2
          t12 = (1 - itrflg1)*tursav(j,k,1,1)
     .        + itrflg1*bcdata(jj,kk,ip,6)
          t22 = (1 - itrflg2)*tursav(j,k,1,2)
     .        + itrflg2*bcdata(jj,kk,ip,7)
          ti0(j,k,1,1) = t11
          ti0(j,k,2,1) = t21
          ti0(j,k,1,2) = t12
          ti0(j,k,2,2) = t22
  501   continue
      end if
      end if
      end if
c
c******************************************************************************
c      i=idim boundary          set all primative variables         bctype 2007
c******************************************************************************
c
      if (nface.eq.2) then
c
c     check to see if turbulence data is input (itrflg1/2 = 1) or
c     if freestream values are to be used (itrflg1/2 = 0); the check
c     assumes if the first point has been set, all points have been
c
      ipp     = 1
      itrflg1 = 0
      itrflg2 = 0
      if (real(bcdata(1,1,ipp,6)) .ge. 0.) itrflg1 = 1
      if (real(bcdata(1,1,ipp,7)) .ge. 0.) itrflg2 = 1
c
      if (isklton.eq.1) then
c
c        check that the required auxiliary data has been set
         iflg = 0
         do 6 l=1,5
         do 6 ipp=1,2
         do 6 k=ksta,kend1
         kk = k-ksta+1
         do 6 j=jsta,jend1
         jj = j-jsta+1
         if (real(bcdata(jj,kk,ipp,l)) .lt. -1.e10) iflg = 1
   6     continue
         if (iflg.eq.1) then
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),*)'  Stopping in bc2007:'
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),*)'  primative variable data ',
     .                         'incorrectly set'
            call termn8(myid,-1,ibufdim,nbuf,bou,nou)
         end if
         if (itrflg1.gt.0 .or. itrflg2.gt.0) then
            if (ivmx.gt.5 .and. itrflg1*itrflg2.eq.0) then
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),*)'  stopping in bc2007...must',
     .         ' set both turbulence'
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),*)'  quantities for 2-eq turb.',
     .         ' models...only one is set'
               call termn8(myid,-1,ibufdim,nbuf,bou,nou)
            end if
         end if
c
         if (filname.eq.'null') then
            rho1 = bcdata(1,1,1,1)
            u1   = bcdata(1,1,1,2)
            v1   = bcdata(1,1,1,3)
            w1   = bcdata(1,1,1,4)
            p1   = bcdata(1,1,1,5)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1006)ista,iend,ksta,kend
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1007) real(rho1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1008) real(u1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1009) real(v1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1010) real(w1)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),1011) real(p1)
            if (itrflg1.gt.0) then
               t1 = bcdata(1,1,1,6)
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),1014) real(t1)
            end if
            if (itrflg2.gt.0) then
               t2 = bcdata(1,1,1,7)
               nou(1) = min(nou(1)+1,ibufdim)
               write(bou(nou(1),1),1015) real(t2)
            end if
         else
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2006)jsta,jend,ksta,kend
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2007)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),2008)filname
         end if
c
      end if
c
      do 600 l=1,5
      do 600 ip=1,2
      do 600 k=ksta,kend1
      kk = k-ksta+1
      do 600 j=jsta,jend1
      jj = j-jsta+1
      qi0(j,k,l,ip+2) = bcdata(jj,kk,ip,l)
      bci(j,k,2) = 0.0
  600 continue
      if (ivisc(3).ge.2 .or. ivisc(2).ge.2 .or. ivisc(1).ge.2) then
        do 691 k=ksta,kend1
        do 691 j=jsta,jend1
          vi0(j,k,1,3) = vist3d(j,k,idim1)
          vi0(j,k,1,4) = vist3d(j,k,idim1)
  691   continue
      end if
c   only need to do advanced model turbulence B.C.s on finest grid
      if (level .ge. lglobal) then
      if (ivisc(3).ge.4 .or. ivisc(2).ge.4 .or. ivisc(1).ge.4) then
        do 601 k=ksta,kend1
        kk=k-ksta+1
        do 601 j=jsta,jend1
          jj=j-jsta+1
          ip = 1
          t13 = (1 - itrflg1)*tursav(j,k,idim1,1)
     .        + itrflg1*bcdata(jj,kk,ip,6)
          t23 = (1 - itrflg2)*tursav(j,k,idim1,2)
     .        + itrflg2*bcdata(jj,kk,ip,7)
          ip = 2
          t14 = (1 - itrflg1)*tursav(j,k,idim1,1)
     .        + itrflg1*bcdata(jj,kk,ip,6)
          t24 = (1 - itrflg2)*tursav(j,k,idim1,2)
     .        + itrflg2*bcdata(jj,kk,ip,7)
          ti0(j,k,1,3) = t13
          ti0(j,k,2,3) = t23
          ti0(j,k,1,4) = t14
          ti0(j,k,2,4) = t24
  601   continue
      end if
      end if
      end if
c
 1001 format(' ','  j=   1  set all primative variables    type 2007',
     .       '  i=',i3,',',i3,'  k=',i3,',',i3)
 1002 format(' ','  j=jdim  set all primative variables    type 2007',
     .       '  i=',i3,',',i3,'  k=',i3,',',i3)
 1003 format(' ','  k=   1  set all primative variables    type 2007',
     .       '  i=',i3,',',i3,'  j=',i3,',',i3)
 1004 format(' ','  k=kdim  set all primative variables    type 2007',
     .       '  i=',i3,',',i3,'  j=',i3,',',i3)
 1005 format(' ','  i=   1  set all primative variables    type 2007',
     .       '  j=',i3,',',i3,'  k=',i3,',',i3)
 1006 format(' ','  i=idim  set all primative variables    type 2007',
     .       '  j=',i3,',',i3,'  k=',i3,',',i3)
 1007 format(11x,'rho/rhoinf       = ',f8.4)
 1008 format(11x,'u/ainf           = ',f8.4)
 1009 format(11x,'v/ainf           = ',f8.4)
 1010 format(11x,'w/ainf           = ',f8.4)
 1011 format(11x,'p/rhoinf/ainf**2 = ',f8.4)
 1014 format(11x,'turb1 (nondim)   = ',e12.4)
 1015 format(11x,'turb2 (nondim)   = ',e12.4)
c
 2001 format(' ','  j=   1  set all primative variables    type 2007',
     .       '  i=',i3,',',i3,'  k=',i3,',',i3)
 2002 format(' ','  j=jdim  set all primative variables    type 2007',
     .       '  i=',i3,',',i3,'  k=',i3,',',i3)
 2003 format(' ','  k=   1  set all primative variables    type 2007',
     .       '  i=',i3,',',i3,'  j=',i3,',',i3)
 2004 format(' ','  k=kdim  set all primative variables    type 2007',
     .       '  i=',i3,',',i3,'  j=',i3,',',i3)
 2005 format(' ','  i=   1  set all primative variables    type 2007',
     .       '  j=',i3,',',i3,'  k=',i3,',',i3)
 2006 format(' ','  i=idim  set all primative variables    type 2007',
     .       '  j=',i3,',',i3,'  k=',i3,',',i3)
 2007 format(11x,'primative variables set from file:')
 2008 format('           ',a60)
c
      return 
      end