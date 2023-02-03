function ph_combination(params,noiseLv,method,k)

    nCoil = params.nCoil;
    dir_files = append(string(nCoil),'_Coils\head_phantom_noise_',string(noiseLv));
    if isfile(append(dir_files,'\',method,'\',string(k),'\ph.nii'))
        fprintf('Phase and magnitude already reconstructed\n');
        fprintf('Skipping...\n');
    else
        mag = niftiread(append(dir_files,'\mag_ch.nii.gz'));
        ph = niftiread(append(dir_files,'\',method,'\ph_corr.nii.gz'));
        matrixSize = [size(mag,1) size(mag,2) size(mag,3) size(mag,4)];

        if strcmp(string(k),'h') == 1
            fprintf('Using highest signal from each coil...\n');
        
            mag_h = zeros( [(matrixSize(1)) (matrixSize(2)) (matrixSize(3)) matrixSize(4)] );
            ph_h = zeros( [(matrixSize(1)) (matrixSize(2)) (matrixSize(3)) matrixSize(4)] );
            box_S = mag.*exp(1i*ph);

            for i=1:matrixSize(1)
                for j=1:matrixSize(2)
                    for k=1:matrixSize(3)
                        for t=1:size(TE,2)
                            ph_h(i,j,k,t) = angle(max(box_S(i,j,k,:,t),[],4));
                        end
                    end
                end
            end
            niftiwrite(ph_h,append(dir_files,'\',method,'\',string(k),'\ph.nii'),'Compressed',true);
    
        else       
            fprintf('Using weighted complex sum (factor %d)...\n',k);   
            field_sum = zeros( [matrixSize(1) matrixSize(2) matrixSize(3) matrixSize(4)] );
            for t=1:matrixSize(4)
                if k == 0
                    norm = 1;
                else
                    norm = sum(mag(:,:,:,t,:),5).^(k-1);
                end
                field = (mag.^k).*exp(1i*ph);
                field_sum(:,:,:,t) = sum(field(:,:,:,t,:),5)./norm;
                field_sum(isinf(field_sum)|isnan(field_sum)) = 0;
            end
    
            ph_sum = angle(field_sum);
            mkdir(append(dir_files,'\',method,'\',string(k)));
            niftiwrite(ph_sum,append(dir_files,'\',method,'\',string(k),'\ph.nii'),'Compressed',true);
        end
    end
