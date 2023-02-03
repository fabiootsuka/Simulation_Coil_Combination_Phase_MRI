function MCPC3DS(params,magDir,maskDir,noiseLv)

    if params.nCoil
        nCoil = params.nCoil;
    else
        nCoil = 4;
    end
    
    TE = params.TE
    
    dir_files = append(string(nCoil),'_Coils\head_phantom_noise_',string(noiseLv));
    mkdir(append(dir_files,'\mcpc3d-s'));
    
    if isfile(append(dir_files,'\mcpc3d-s\ph.nii')) && isfile(append(dir_files,'\mcpc3d-s\ph_offset.nii'))
        fprintf('Phase ofsset correction already applied\n');
        fprintf('Skipping...\n');
    
    else
        fprintf('Combining signal from each coil using MCPC method\n');

        mag = niftiread(magDir);
        matrixSize = [size(mag,1) size(mag,2) size(mag,3) size(mag,4)];
        iMag = sqrt(sum((mag).^2,4));
        clear mag
    
%     mask = niftiread(maskDir);
% 
%     parameters.mag = iMag;
%     parameters.mask = mask; % can be an array or a string: 'nomask' | 'robustmask' | 'qualitymask'
%     parameters.calculate_B0 = false; % optianal B0 calculation for multi-echo
%     parameters.phase_offset_correction = 'off'; % options are: 'off' | 'on' | 'bipolar'
%     parameters.voxel_size = params.voxel_size;
    
        phase = niftiread(append(dir_files,'\ph_ch.nii.gz'));
    
        fprintf('Estimating phase offset using %s\n',method);
        for N=1:nCoil
        %[phase_u(:,:,:,1)] = ROMEO(phase(:,:,:,1,N), parameters);
        %[phase_u(:,:,:,2)] = ROMEO(phase(:,:,:,2,N), parameters);
            phase_u(:,:,:,1) = unwrapPhase(iMag, phase(:,:,:,1,N),[size(mag,1) size(mag,2) size(mag,3)]);
            phase_u(:,:,:,2) = unwrapPhase(iMag, phase(:,:,:,2,N),[size(mag,1) size(mag,2) size(mag,3)]);
        
            offset = ( phase_u(:,:,:,1)*TE(2) - phase_u(:,:,:,2)*TE(1) )/(TE(2)-TE(1));
            off_mcpc3d(:,:,:,N) = offset;
            clear phase_u offset
        end

        fprintf('Saving phase offset...\n');
        niftiwrite(off_mcpc3d,append(dir_files,'\mcpc3d-s\ph_offset.nii'),'Compressed',true);
        fprintf('Phase offset estimated\n');
    
        for N=1:nCoil
            for t=1:matrixSize(4)
                ph_corr(:,:,:,t,N) = phase(:,:,:,t,N) - off_mcpc3d(:,:,:,N);
            end
        end
        clear off_mcpc3d
    
        fprintf('Saving corrected phase...\n');
        niftiwrite(ph_corr,append(dir_files,'\mcpc3d-s\ph_corr.nii'),'Compressed',true);
        fprintf('Phase offset corrected\n');
    end
