%% PSF creation for the Biot-Savart Law
%
% Define the PSF (Point-Spread Function) as: h =(r-r')/|r-r'|^3
% where r' is at the center
% At the center the function is defined as 1 (could be set to zero too)
%
% Input:
% size = size of the box in which the PSF will be placed
%        The PSF will be placed at the center of the box
%

function [h] = BS_PSF(size)

    Nx = size(1);
    a = Nx/2;
    if mod(a,1) == 0;
        a = Nx/2;
    else
        a = (Nx-1)/2;
    end
    
    Ny = size(2);
    b = Ny/2;
    if mod(b,1) == 0;
        b = Ny/2;
    else
        b = (Ny-1)/2;
    end
    
    Nz = size(3);
    c = Nz/2;
    if mod(c,1) == 0;
        c = Nz/2;
    else
        c = (Nz-1)/2;
    end
    
% Define the PSF (Point-Spread Function) as: h =(r-r')/|r-r'|^3
% where r' is at the center
% At the center the function is defined as 1 (could be set to zero too)
    for i=1:Nx
        for j=1:Ny
            for k=1:Nz
                r = sqrt( (i-a)^2 + (j-b)^2 + (k-c)^2 );
                hx(i,j,k) = ( ((i-a)/(r^3)) );
                hy(i,j,k) = ( ((j-b)/(r^3)) );
                hz(i,j,k) = ( ((k-c)/(r^3)) );
                h(i,j,k) = 1/r^2;
            end
        end
    end
    hx(a,b,c)=1;
    hy(a,b,c)=1;
    hz(a,b,c)=1;
    
    h(:,:,:,1)=hx;
    h(:,:,:,2)=hy;
    h(:,:,:,3)=hz;