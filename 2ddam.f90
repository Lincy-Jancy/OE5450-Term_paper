
program dambreaksim
implicit none

!! defining the parameters
integer,parameter:: n=41
real,parameter::g=9.81
integer:: p,q,timemarch,i,j,k,t
real:: dt,k,dx,dy,c

!! allocating array for the variable
real,dimension(n,n):: h,u,v
real,dimension(n+2,n+2):: h1,u1,v1,h2,u2,v2
real,dimension(n+2,n+2)::f1,g1,s1,f2,g2,s2,f3,g3,hproc,uproc,vproc,un1,un2,un3
real,dimension(n+2,n+2)::un1pred,un2pred,un3pred,hpred,upred,vpred
real,dimension(n+2,n+2)::u11,u21,u31,f11,f21,f31,g11,g21,g31,s11,s21
real,dimension(n+2,n+2):: nux,nuy,k1,k2,k3,u111,u211,u311
integer,dimension(4):: t_range
character(len=20):: e, output1,output2,output3 !!to print the results

!!!!!Initialization
p=0
q=200 !!length of domain
dx= (q-p)/(n-1)
dy=dx
dt=0.002 !!timestep
k=0.25
timemarch=0 !!initial time

!! initial height of the domain
h(1:41,1:18)=10.0 !! height in upstream side
h(7:22,19:20)=1.0 !! at the breach
h(1:41,21:41)=1.0 !! downstream side
!! initial velocity
u=0
v=0

h1=0
h1(2:n+1,2:n+1)=h
u1=0
u1(2:n+1,2:n+1)=u
v1=0
v1(2:n+1,2:n+1)=v

	call boundary(h1,u1,v1,n) !!define boundary conditions
    call dependent(h1,u1,v1,g,un1,un2,un3,F1,F2,F3,G1,G2,G3,S1,S2) !! calculate the dependent fluxes

	c= dt/dx

	do k= 1,3750 !!start the time marching

		timemarch = timemarch +1
		print*,'Time March =',timemarch

		hproc=h1
		uproc=u1
		vproc=v1
        !!predictor step
		do i=2,n+1  !!u/s ca;culation
			do j=2,19
				hproc(i,j) = un1(i,j) - c * (F1(i,j) - F1(i,j-1)) - c*(G1(i,j) - G1(i-1,j))
                uproc(i,j) = un2(i,j) - c * (F2(i,j) - F2(i,j-1)) - c*(G2(i,j) - G2(i-1,j))+ dt*(g*h1(i,j)*(0.05-S1(i,j)))
                vproc(i,j) = un3(i,j) - c * (F3(i,j) - F3(i,j-1)) - c*(G3(i,j) - G3(i-1,j))+ dt*(g*h1(i,j)*(-S2(i,j)))
            end do
		end do
		do i=8,23 !!breach calculation
			do j=20,21
				hproc(i,j) = un1(i,j) - c * (F1(i,j) - F1(i,j-1)) - c*(G1(i,j) - G1(i-1,j))
                uproc(i,j) = un2(i,j) - c * (F2(i,j) - F2(i,j-1)) - c*(G2(i,j) - G2(i-1,j))+ dt*(g*h1(i,j)*(0.05-S1(i,j)))
                vproc(i,j) = un3(i,j) - c * (F3(i,j) - F3(i,j-1)) - c*(G3(i,j) - G3(i-1,j))+ dt*(g*h1(i,j)*(-S2(i,j)))
            end do
		end do
		do i=2,n+1 !!d/s calculation
			do j=22,42
				hproc(i,j) = un1(i,j) - c * (F1(i,j) - F1(i,j-1)) - c*(G1(i,j) - G1(i-1,j))
                uproc(i,j) = un2(i,j) - c * (F2(i,j) - F2(i,j-1)) - c*(G2(i,j) - G2(i-1,j))+ dt*(g*h1(i,j)*(0.05-S1(i,j)))
                vproc(i,j) = un3(i,j) - c * (F3(i,j) - F3(i,j-1)) - c*(G3(i,j) - G3(i-1,j))+ dt*(g*h1(i,j)*(-S2(i,j)))
            end do
		end do
        !!store the value in another variable
		un1pred=un1
		un2pred=un2
		un3pred =un3
		hpred=hproc
		upred=uproc
		vpred=vproc

		call redependent(hproc,uproc,vproc,n,h2,u2,v2) !! re-dependent calculate
		call dependent(h2,u2,v2,g,k1,k2,k3,F11,F21,F31,G11,G21,G31,S11,S21)!!update fluxes with the re-dependent values

        !!corrector step
		do i=2,n+1 !!u/s calculation
			do j=2,19
				U11(i,j) = 0.5 * (un1pred(i,j) + hpred(i,j) - c * (F11(i,j+1) - F11(i,j)) - c*(G11(i+1,j) - G11(i,j)))
                U21(i,j) = 0.5 * (un2pred(i,j) + upred(i,j) - c * (F21(i,j+1) - F21(i,j)) - c*(G21(i+1,j) - G21(i,j)))&
                + dt*(g*h1(i,j)*(0.05-S11(i,j)))
                U31(i,j) = 0.5 * (un3pred(i,j) + vpred(i,j) - c * (F31(i,j+1) - F31(i,j)) - c*(G31(i+1,j) - G31(i,j)))&
                 + dt*(g*h1(i,j)*(-S21(i,j)))
            end do
		end do

		do i=8,23 !!breach calculation
			do j=20,21
				U11(i,j) = 0.5 * (un1pred(i,j) + hpred(i,j) - c * (F11(i,j+1) - F11(i,j)) - c*(G11(i+1,j) - G11(i,j)))
                U21(i,j) = 0.5 * (un2pred(i,j) + upred(i,j) - c * (F21(i,j+1) - F21(i,j)) - c*(G21(i+1,j) - G21(i,j)))&
                + dt*(g*h1(i,j)*(0.05-S11(i,j)))
                U31(i,j) = 0.5 * (un3pred(i,j) + vpred(i,j) - c * (F31(i,j+1) - F31(i,j)) - c*(G31(i+1,j) - G31(i,j)))&
                 + dt*(g*h1(i,j)*(-S21(i,j)))
            end do
		end do

		do i=2,n+1 !!d/s calculation
			do j=22,42
				U11(i,j) = 0.5 * (un1pred(i,j) + hpred(i,j) - c * (F11(i,j+1) - F11(i,j)) - c*(G11(i+1,j) - G11(i,j)))
                U21(i,j) = 0.5 * (un2pred(i,j) + upred(i,j) - c * (F21(i,j+1) - F21(i,j)) - c*(G21(i+1,j) - G21(i,j)))&
                + dt*(g*h1(i,j)*(0.05-S11(i,j)))
                U31(i,j) = 0.5 * (un3pred(i,j) + vpred(i,j) - c * (F31(i,j+1) - F31(i,j)) - c*(G31(i+1,j) - G31(i,j)))&
                 + dt*(g*h1(i,j)*(-S21(i,j)))
            end do
		end do

		call boundary(u11,u21,u31,n) !!update the boundary conditions
        !!calculation for artificial viscosity
		nux=0 !!x-direction
		do i=2,n+1
			do j=2,19
				nux(i,j)= abs(h1(i,j+1)-2*h1(i,j)+h1(i,j-1))/(abs(h1(i,j+1))+ abs(2*h1(i,j))+ abs(h1(i,j-1)))
            end do
		end do
		do i=8,23
			do j=20,21
				nux(i,j)= abs(h1(i,j+1)-2*h1(i,j)+h1(i,j-1))/(abs(h1(i,j+1))+ abs(2*h1(i,j))+ abs(h1(i,j-1)))
            end do
		end do
		do i=2,n+1
			do j=22,42
				nux(i,j)= abs(h1(i,j+1)-2*h1(i,j)+h1(i,j-1))/(abs(h1(i,j+1))+ abs(2*h1(i,j))+ abs(h1(i,j-1)))
            end do
		end do

		nuy=0 !!y-direction
		do i=2,n+1
			do j=2,19
				nuy(i,j)= abs(h1(i+1,j)-2*h1(i,j)+h1(i-1,j))/(abs(h1(i+1,j))+ abs(2*h1(i,j))+ abs(h1(i-1,j)))
			end do
		end do
		do i=8,23
			do j=20,21
				nuy(i,j)= abs(h1(i+1,j)-2*h1(i,j)+h1(i-1,j))/(abs(h1(i+1,j))+ abs(2*h1(i,j))+ abs(h1(i-1,j)))
			end do
		end do
		do i=2,n+1
			do j=22,n+1
				nuy(i,j)= abs(h1(i+1,j)-2*h1(i,j)+h1(i-1,j))/(abs(h1(i+1,j))+ abs(2*h1(i,j))+ abs(h1(i-1,j)))
			end do
		end do

		call art_vis(n,u11,k,nux,nuy,u111) !!artifical viscosity added to the variable
		call art_vis(n,u21,k,nux,nuy,u211)
		call art_vis(n,u31,k,nux,nuy,u311)

		call boundary(u111,u211,u311,n) !!updating the boundary after calculating the art_vis

	call redependent (u111,u211,u311,n,h1,u1,v1) !!update the finial variable

	t= int((k*dt))
	t_range= (/1,3,5,7/)

	if (any(t_range .eq. t)) then

	write(e, '(I2)') t
    output1 = 'eta'//trim(e)//'s.txt'
    output2= 'uvel'//trim(e)//'s.txt'
    output3='vvel'//trim(e)//'s.txt'

		call write_out(20,output1,h1,n)
		call write_out(30,output2,u1,n)
		call write_out(40,output3,v1,n)
	end if

    call dependent(h1,u1,v1,g,un1,un2,un3,F1,F2,F3,G1,G2,G3,S1,S2)
end do

end program

subroutine dependent (h,u,v,g,un1,un2,un3,F1,F2,F3,G1,G2,G3,S1,S2)
implicit none
integer,parameter:: n=41
integer::i,j
real,dimension(n+2,n+2)::h,u,v,un1,un2,un3,F1,F2,F3,G1,G2,G3,S1,S2
real::g,n1

do i=1,n+2
    do j=1,n+2
        un1(i,j)=h(i,j)
        un2(i,j)= h(i,j)*u(i,j)
        un3(i,j)= h(i,j)*v(i,j)

        F1(i,j) = h(i,j)*u(i,j)
        F2(i,j) = h(i,j)*u(i,j)*u(i,j) + 0.5*(g*h(i,j)*h(i,j))
        F3(i,j) = h(i,j)*u(i,j)*v(i,j)

        G1(i,j)= h(i,j)*v(i,j)
        G2(i,j)= h(i,j)*u(i,j)*v(i,j)
        G3(i,j) = h(i,j)*v(i,j)*v(i,j) + 0.5*(g*h(i,j)*h(i,j))

        n1=0.15
        S1(i,j)= u(i,j)*(n1**2*(sqrt((u(i,j)*u(i,j)+v(i,j)*v(i,j)))/(h(i,j)**1.33)))
        S2(i,j)= v(i,j)*(n1**2*(sqrt((u(i,j)**2+v(i,j)**2)))/(h(i,j)**1.33))
    end do
end do
end
subroutine redependent(u1,u2,u3,n,h,u,v)
implicit none
integer::n
real,dimension(n+2,n+2)::h,u,v,U1,U2,U3
h=U1
u=U2/U1
v=U3/U1
end
subroutine boundary(h,u,v,n) !!reflecting boundary condition
implicit none
integer:: n
real,dimension(n+2,n+2)::h,u,v

		 h(:,1) = h (:,2)
		 h(:,N+2)= h(:,N+1)
		 h(1,:)= h(2,:)
		 h(N+2,:)= h(N+1,:);

        h(1:7,20)= h(1:7,19)
		h(24:43,20)= h(24:43,19)
        h(1:7,21)= h(1:7,22)
		h(24:43,21)= h(24:43,22)
        h(7,20:21)= h(6,20:21)
		h(24,20:21)= h(25,20:21)

        v(:,1) = v (:,2)
		v(:,N+2)= v(:,N+1)
		v(1,:)= v(2,:)
		v(N+2,:)= v(N+1,:)

        v(1:7,20)= v(1:7,19)
		v(24:43,20)= v(24:43,19)
        v(1:7,21)= v(1:7,22)
		v(24:43,21)= v(24:43,22)
        v(7,20:21)= v(6,20:21)
		v(24,20:21)= v(25,20:21)


        u(:,1) = u (:,2)
		u(:,N+2)= u(:,N+1)
		u(1,:)= u(2,:)
		u(N+2,:)= u(N+1,:)

        u(1:7,20)= u(1:7,19)
		u(24:43,20)= u(24:43,19)
        u(1:7,21)= u(1:7,22)
		u(24:43,21)= u(24:43,22)
        u(7,20:21)= u(6,20:21)
		u(23,20:21)= u(24,20:21)

end

subroutine art_vis(n,U1,k,vhx,vhy,u1res)
implicit none
integer:: n,i,j
real,dimension(n+2,n+2):: u1,vhx,vhy,u1res
real:: k,epsi_nve,epsi_pve,epsiy_nve,epsiy_pve

	do i=2,n+1
		do j=2,19
			epsi_nve=k* max(vhx(i,j-1),vhx(i,j))
			epsi_pve= k* max(vhx(i,j+1),vhx(i,j))

			epsiy_nve= k*  max(vhy(i-1,j),vhy(i,j));
            epsiy_pve= k*  max(vhy(i+1,j),vhy(i,j));

            u1res(i,j)= U1(i,j)+ (epsi_pve*(U1(i,j+1)-U1(i,j))-epsi_nve*(U1(i,j)-U1(i,j-1)))&
             + (epsiy_pve*(U1(i+1,j)-U1(i,j))-epsiy_nve*(U1(i,j)-U1(i-1,j)));
		end do
	end do
	do i=8,23
		do j=20,21
			epsi_nve=k* max(vhx(i,j-1),vhx(i,j))
			epsi_pve= k* max(vhx(i,j+1),vhx(i,j))

			epsiy_nve= k*  max(vhy(i-1,j),vhy(i,j));
            epsiy_pve= k*  max(vhy(i+1,j),vhy(i,j));

            u1res(i,j)= U1(i,j)+ (epsi_pve*(U1(i,j+1)-U1(i,j))-epsi_nve*(U1(i,j)-U1(i,j-1)))&
             + (epsiy_pve*(U1(i+1,j)-U1(i,j))-epsiy_nve*(U1(i,j)-U1(i-1,j)));
		end do
	end do
	do i=2,n+1
		do j=22,n+1
			epsi_nve=k* max(vhx(i,j-1),vhx(i,j))
			epsi_pve= k* max(vhx(i,j+1),vhx(i,j))

			epsiy_nve= k*  max(vhy(i-1,j),vhy(i,j));
            epsiy_pve= k*  max(vhy(i+1,j),vhy(i,j));

            u1res(i,j)= U1(i,j)+ (epsi_pve*(U1(i,j+1)-U1(i,j))-epsi_nve*(U1(i,j)-U1(i,j-1)))&
             + (epsiy_pve*(U1(i+1,j)-U1(i,j))-epsiy_nve*(U1(i,j)-U1(i-1,j)));
		end do
	end do

end

subroutine write_out(unit,output,u,n)
implicit none

integer:: unit
integer:: n,i
real,dimension(n+2,n+2):: u
character(len=20):: output


		open(unit, file= output ,status='unknown')
			do i=1,n+2
				write(unit,*) u(:,i)
			end do
		close (unit)

end
