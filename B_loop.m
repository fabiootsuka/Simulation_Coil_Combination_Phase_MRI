%% Generates the magnetic field from a current distribution
%
% Input:
% size = size of the box in which the B distribution will be calculated
% J_vector = 4_D vector of the J distribution, the 4th dimension are the x,
%            y and z components of J
%
% Output:
% B = magnetic field distribution
%
% Fábio Seiji Otsuka

function [B] = B_loop(h,J)

% 3D Convolution of the J vectors with the h
% takes to Fourier space and multiple voxel-wise
% then, returns to original space)
    %B = pad_convolution(J_vector,h,0);
    
    %B(:,:,:,1) = flipdim(imrotate(Bx,90),2);
    %B(:,:,:,2) = flipdim(imrotate(By,90),2);
    %B(:,:,:,3) = flipdim(imrotate(Bz,90),2);
    
    Jx = J(:,:,:,1);
    Jy = J(:,:,:,2);
    Jz = J(:,:,:,3);
    clear J
    
    hx = h(:,:,:,1);
    hy = h(:,:,:,2);
    hz = h(:,:,:,3);
    clear h
    
    fprintf('Calculating Bx...\n');
    Bx = convn(Jy,hz) - convn(Jz,hy);
    B(:,:,:,1) = Bx;
    clear Bx
    fprintf('Calculating By...\n');
    By = convn(Jz,hx) - convn(Jx,hz);
    B(:,:,:,2) = By;
    clear By hz Jz
    fprintf('Calculating Bz...\n');
    Bz = convn(Jx,hy) - convn(Jy,hx);
    B(:,:,:,3) = Bz;
    clear Bz
