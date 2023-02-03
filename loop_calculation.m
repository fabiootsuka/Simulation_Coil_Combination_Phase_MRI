%% Magnetic Field distribution from an Electric Current distribution (loop)
%
% Inputs:
%   - params: parameters for the simulation. It must contain the following:
%               - size: size of the box in which the magnetic field will be
%                       calculated
%               - nCoil: number of coils (default is 4)
%               - pad: padding (default is 40)
%               - radius: radius of the circular loop (default is 10)
%               - I: electric current intensity on the loop (default is 1)
%   - save_dir: directory to save J and B
%
% Obs: for the J_loop function, the size of the matrix should be at least
% 2*radius+1 in size at each dimension
%
% Fábio Seiji Otsuka
%
% 1st version: 12/05/2022
% 2nd version: 10/07/2022
% 3rd version: 18/08/2022 -> updated to use more than 4 coils
%

function loop_calculation(params,save_dir)
    
% Check if other parameters were defined by the user, if not, the default
% will be used

    if params.nCoil
        nCoil = params.nCoil;
    else
        nCoil = 4;
    end
    
    if params.pad
        pad = params.pad;
    else
        pad = 40;
    end
    
    if params.radius
        r = params.radius;
    else
        r = 5;
    end
    
    if params.I
        I = params.I;
    else
        I = 1;
    end
    
% Defining the sizes [Nx Ny Nz] as the double of the original image (in
% order to calculate the PSF)
    
    Nx = 2*params.size(1);
    Ny = 2*params.size(2);
    Nz = 2*params.size(3);
   
% Defining the angles of the orientation of each coil
%   - Obs. Currently the coils are positioned only perpendicular to the
%          axial plane (it's not possible to position them on other planes)
    angle = 2*pi/nCoil;
    
% Definind the total size of the PSF by adding the padding
    hSize = [(2*max(params.size) + 3*pad) (2*max(params.size) + 3*pad) (2*max(params.size) + 3*pad)];
      
% Calculate the PSF (if there's already a 'h.nii.gz' file in the working
% folder, than this step will be skipped, and the corresponding file will
% be imported)
    if isfile('h.nii.gz')
        fprintf('h alredy generated\n');
        fprintf('Importing h...\n');
        h = niftiread('h.nii.gz');
    else
        fprintf('Generating h...\n');
        tic
        h = BS_PSF(hSize);
        fprintf('h succesfully generated\n');
        fprintf('Saving h...\n');
        niftiwrite(h,'h.nii','Compressed',true);
        fprintf('h succesfully saved.\n');
    end
    
% Calculate the J and B distribution for each coil. Then, the resulting
% image is cropped to the size of [i j k] by positioning the center of the
% coil on the specified position.
%
% The position of each coil will depend on the number of coils previously
% defined (according to the 'angle' variable)
%
% If there's already the B_field# on the 'save_dir' folder, this will be
% skipped
    mkdir(save_dir);
    
    flag = 0;
    for N=1:nCoil
        file_test = append(save_dir,'\B',string(N),'.nii.gz');
        if isfile(file_test)
            flag = flag + 1;
        else
        end
    end
    
    if flag == nCoil
        fprintf('All B have already been calculated\n');
        fprintf('Skipping...\n');
    else
        if isfile('B.nii.gz');
            
        else
            h = niftiread('h.nii.gz');
            [x_coil,y_coil,z_coil]=sph2cart(pi/2,0,1);
            if abs(x_coil) < 1e-14
                x_coil = 0;
            end
            if abs(y_coil) < 1e-14
                y_coil = 0;
            end
            ori = [x_coil y_coil z_coil];

            J = J_loop(r,I,ori);
            Bp = B_loop(h,J);
            clear h
            niftiwrite(Bp,'B.nii','Compressed',true);
            clear Bp
        end
            
        for N=1:nCoil
            file_test = append(save_dir,'\B',string(N),'.nii.gz');
            if isfile(file_test)
                fprintf('Field B%d already generated\n',N);
                fprintf('Skipping...\n');
            else
                Bp = niftiread('B.nii.gz');
                [x_coil,y_coil,z_coil]=sph2cart(N*angle,0,1);
                if abs(x_coil) < 1e-14
                    x_coil = 0;
                end
                if abs(y_coil) < 1e-14
                    y_coil = 0;
                end
                ori = [x_coil y_coil z_coil];
                pos = [ (round((params.size(1))/2) + round(ori(1))*70)...
                    (round((params.size(2))/2) + round(ori(2))*90)...
                    (round((params.size(3))/2) + round(ori(3))*90)];
            
                Bn = imrotate(Bp,rad2deg(N*angle));
                clear Bp

                x = round(size(Bn,1)/2);
                y = round(size(Bn,2)/2);
                z = round(size(Bn,3)/2);
            
                B = Bn( x-pos(1)-pad:x-pos(1)+params.size(1)+pad-1, y-pos(2)-pad:y-pos(2)+params.size(2)+pad-1, z-pos(3)-pad:z-pos(3)+params.size(3)+pad-1, : );
                clear Bn
                
                fprintf('B%d succesfully calculated\n',N);
            
                Bname = append(save_dir,'\B',string(N),'.nii');
            %Jname = append(save_dir,'\J',string(N),'.nii');
            
                fprintf('Saving B%d...\n',N);
                niftiwrite(B,Bname,'Compressed',true);
            
            %fprintf('Saving J%d...\n',N);
            %niftiwrite(J,Jname,'Compressed',true);
                clear J B Bname
            end
        end
    end