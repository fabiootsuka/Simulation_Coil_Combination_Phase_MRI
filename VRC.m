function VRC(params,noiseLv)

    if params.nCoil
        nCoil = params.nCoil;
    else
        nCoil = 4;
    end
    
    TE = params.TE;
    
    dir_files = append(string(nCoil),'_Coils\head_phantom_noise_',string(noiseLv));
    mkdir(append(dir_files,'\vrc'));
    
    if isfile(append(dir_files,'\vrc\ph.nii')) && isfile(append(dir_files,'\vrc\ph_offset.nii'))
        fprintf('Phase ofsset correction already applied\n');
        fprintf('Skipping...\n');
    
    else
        fprintf('Combining signal from each coil using VRC method\n');

        mag = niftiread(append(dir_files,'\mag_ch.nii.gz'));
        phase = niftiread(append(dir_files,'\ph_ch.nii.gz'));
    
        fprintf('Creating VRI by combining all coils\n');
        for N=1:nCoil;
            S(:,:,:,N) = mag(:,:,:,1,N).*exp(1i*phase(:,:,:,1,N));
        end
    
        clear mag
        msize = size(S);
        msize(1);
        x = ceil(msize(1)/2);
        y = ceil(msize(2)/2);
        z = ceil(msize(3)/2);

% Selecting VRI (using SPM)
        SPM = zeros(msize(1),msize(2),msize(3),msize(4));
        for i=1:msize(4)
            B = angle(S((x-5):(x+4),(y-5):(y+4),(z-5):(z+4),i));
            SPM(:,:,:,i) = S(:,:,:,i)*exp(-1i*mean(B(:)));
        end
        clear B
        v = sum(SPM,4);
        clear S SPM

%     for i=1:nCoil
%         delta_phi(:,:,:,i) = angle(v)-phase(:,:,:,1,i);
%     end
        fprintf('Filtering the phase difference\n');
        for i=1:nCoil
            filter_phi(:,:,:,i) = medfilt3(angle(v)-phase(:,:,:,1,i));
        end

        fprintf('Saving phase offset...\n');
        niftiwrite(filter_phi,append(dir_files,'\vrc\ph_offset.nii'),'Compressed',true);
    
        for N=1:nCoil
            for t=1:length(TE)
                ph_corr(:,:,:,t,N) = angle( exp(1i*phase(:,:,:,t,N)).*exp(1i*filter_phi(:,:,:,N)));
            end
        end
        
        fprintf('Saving corrected phase...\n');
        niftiwrite(ph_corr,append(dir_files,'\vrc\ph_corr.nii'),'Compressed',true);
        fprintf('Phase offset corrected\n');
    end
