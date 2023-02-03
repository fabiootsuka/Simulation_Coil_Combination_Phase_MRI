function run_QSM_pipeline(data_dir)
    
    load(append(data_dir,'\data.mat'));
    mag = niftiread(append(data_dir,'\mag.nii.gz'));
    ph = niftiread(append(data_dir,'\ph.nii.gz'));
    Mask = niftiread(append(data_dir,'\mask.nii.gz'));

    field = mag.*exp(-1i*ph);
    [iFreq_raw, N_std] = Fit_ppm_complex(field);
    iMag = sqrt(sum(abs(field).^2,4));
    %Mask = BET(iMag,matrix_size,voxel_size);
    
    parameters.TE = TE; % required for multi-echo
    parameters.mag = iMag;
    parameters.mask = Mask; % can be an array or a string: 'nomask' | 'robustmask' | 'qualitymask'
    parameters.calculate_B0 = false; % optianal B0 calculation for multi-echo
    parameters.phase_offset_correction = 'off'; % options are: 'off' | 'on' | 'bipolar'
    parameters.voxel_size = voxel_size;
    [iFreq] = ROMEO(iFreq_raw, parameters);
    
    %iFreq = unwrapPhase(iMag, iFreq_raw, matrix_size);
    niftiwrite(iFreq,append(data_dir,'\field_map.nii'),'Compressed',true);
    
    RDF = PDF(iFreq, N_std, Mask, matrix_size, voxel_size, B0_dir);
    niftiwrite(RDF,append(data_dir,'\local_field.nii'),'Compressed',true);

    save RDF.mat RDF iFreq iFreq_raw iMag N_std Mask matrix_size...
        voxel_size delta_TE CF B0_dir;

    QSM = MEDI_L1('lambda',1000);
    niftiwrite(QSM,append(data_dir,'\chi.nii'),'Compressed',true);