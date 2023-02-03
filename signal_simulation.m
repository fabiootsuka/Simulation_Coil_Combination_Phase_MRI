%% Complex Signal from mulriple coils simulation
%
% Inputs:
%   - params: parameters for the simulation. It must contain the following:
%               - nCoil: number of coils (default is 4)
%               - pad: padding (default is 40)
%   - field_dir: directory where B was saved
%   - magDir: directory to import the gt magnitude
%   - phDir: directory to import the gt phase
%   - noiseLv: noise level (expressed in percentages (1.00 = 100% noise)
%
% Fábio Seiji Otsuka
%
% 1st version: 12/05/2022
% 2nd version: 10/07/2022
% 3rd version: 18/08/2022 -> updated to use more than 4 coils
%

function signal_simulation(params,field_dir,magDir,phDir,maskDir,noiseLv)

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
    
    mag = niftiread(magDir);
    mask = niftiread(maskDir);
    matrixSize = [size(mag,1) size(mag,2) size(mag,3) size(mag,4)];
    n = [(matrixSize(1)+2*pad) (matrixSize(2)+2*pad) (matrixSize(3)+2*pad) matrixSize(4)];
    box_phase = zeros(n);
    box_mag = zeros(n);
    box_S = zeros(n);
    
    box_mag(pad+1:pad+matrixSize(1),pad+1:pad+matrixSize(2),pad+1:pad+matrixSize(3),:) = mag;
    clear mag

    ph = niftiread(phDir);
    box_phase(pad+1:pad+matrixSize(1),pad+1:pad+matrixSize(2),pad+1:pad+matrixSize(3),:) = ph;
    clear ph
    
    fprintf('Importing ground truth magnitude, phase and mask...\n');
    
    Im = zeros(n);
    
    dir_files = append(string(nCoil),'_Coils\head_phantom_noise_',string(noiseLv));
    mkdir(dir_files);
    
    ph = zeros( [(matrixSize(1)) (matrixSize(2)) (matrixSize(3)) matrixSize(4) nCoil] );
    mag = zeros( [(matrixSize(1)) (matrixSize(2)) (matrixSize(3)) matrixSize(4) nCoil] );
    mag_name = append(dir_files,'\mag_ch.nii');
    ph_name = append(dir_files,'\ph_ch.nii');
        
    if isfile(append(mag_name,'.gz')) && isfile(append(ph_name,'.gz'))
        fprintf('magnitude and phase already simulated\n');
        fprintf('Skipping...\n');
    else
        for N=1:nCoil
            
            fprintf('Creating a complex gaussian noise...\n');

            i_noise = imnoise(Im,'gaussian');
            r_noise = imnoise(Im,'gaussian');
            c_noise = r_noise + 1i*i_noise;
            
            Bt = niftiread(append(field_dir,'\B',string(N),'.nii.gz'));
            B = test_size(Bt,box_mag);
            clear Bt
        
            fprintf('Creating signal %d with noise level: %s\n',N,string(noiseLv));
            for i=1:matrixSize(4)
                box_S(:,:,:,i) = (box_mag(:,:,:,i)).*exp(1i*box_phase(:,:,:,i)).*(abs(B(:,:,:,1))+1i*abs(B(:,:,:,2)));
                const = noiseLv*mean(abs(box_S(41:204,41:245,142,i)).*mask(:,:,102),'all')/(mean(abs(c_noise(117:127,137:147,143,i)),'all'));
                box_S(:,:,:,i) = box_S(:,:,:,i) + const*c_noise(:,:,:,i);
            end

            fprintf('Signal %d created\n',N);
            mag(:,:,:,:,N) = abs(box_S(pad+1:pad+matrixSize(1),pad+1:pad+matrixSize(2),pad+1:pad+matrixSize(3),:));
            ph(:,:,:,:,N) = angle(box_S(pad+1:pad+matrixSize(1),pad+1:pad+matrixSize(2),pad+1:pad+matrixSize(3),:));
    
            clear box_S B i_noise r_noise
        end
        fprintf('Saving magnitude and phase...\n');
        niftiwrite(mag,mag_name,'Compressed',true);
        niftiwrite(ph,ph_name,'Compressed',true);
        fprintf('Magnitude and phase for each coil saved\n');
    end