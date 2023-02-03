# Simulation_Coil_Combination_Phase_MRI

This code was written in Matlab R2021a

Some functions implemented in this code were called form other functions, such as the MEDI toolbox (http://pre.weill.cornell.edu/mri/pages/qsm.html) and ROMEO (https://github.com/korbinian90/ROMEO), therefore it is necessary to download and install them properly to use in Matlab;
Any other algorithm could be, in principle, implemented into this simulation.

All the pipeline is listed into the "run_all_pipeline", and it is divided into 6 parts:
1) Import of data and initialization of the parameters
2) Generation of coils and their respective magnetic fields' distribution
3) Generation of the complex signal acquired by each coil
4) Phase Matching (phase offset correction using MCPC3D-S or VRC)
5) Phase Combining (using magnitude weighted sum at defined power)
6) QSM implementation

Each step calls different functions, and also creates different folders. The folder created are listed below:
- B_field: a folder containing the Magnetic Fields generated for each coil
- 4_Coil or 8_Coil: folder where the results from coil combination will be stored. Inside these folder, another folder will be created:
    - head_phantom_noise_###: folder for the results of the simulation at ### noise level
        - vrc: results from the VRC method
        - mcpc3d-s: results from the MCPC3D-S method
Inside the "vrc" or "mcpc3d-s" folder, a folder indicated by a number will be created. This number is referenced to the power of the weighting factor used on step 5



Output files:
Aside from the resulting files created by MEDI toolbos functions, ROMEO and/or other toolboxes, this code generates the folowwing files:
- h.nii.gz: The spatial distribution function for the calculation of the Magnetic Fields, according to the Biot-Savart Law
- B#.nii.gz: The Magnetic Field distribution of the #-th coil
- mag.ch.nii.gz: Magnitude of each coil
- ph_ch.nii.gz: Phase of each coil
- ph_offset.nii.gz: Phase offset calculated for each coil (using either VRC or MCPC3D-S method)
- ph_corr.nii.gz: Corrected phase from each coil
- ph.nii.gz: Combined phase images (weighted complex sum)
- mag.nii.gz: Combined magnitude images (SoS)
      
  
