%% Pipeline to run the simulations of multiple coil imaging
%
% This pipeline comprises functions to simulate images from multiple coils
% Since it is a simulation, it has some simplifications (RF inhomogeneities are neglected)
%
% Fábio S. Otsuka (2022)
%

%% 1) Import data from simulated dataset and define parameters for simulation

fprintf('---------- 1) Importing simulation parameters --------------------\n');
load('SimulationParameters address')
params.size = [164 205 205];
params.nCoil = 8;
params.pad = 40;
params.radius = 5;
params.I = 1;
params.voxel_size = SimParams.Res;
params.B0 = SimParams.B0;
params.B0_dir = SimParams.B0_dir;
params.CF = 42.58*params.B0*1000000;
params.TE = SeqParams.TE;
params.delta_TE = SeqParams.TE(2) - SeqParams.TE(1);
noiseLv = 0.05; %percentage of noise in the simulations
method = 'vrc'; %phase offset correction method, can be 'vrc' or ''mcpc3d-s'
k = 1; %weighting factor for magnitude, for the signal complex combination

%% 2) Calculate de magnetic field (B) distribution of different electric current (J) configurations

fprintf('---------- 2) Calculating the magnetic field distributions -------\n');
field_dir = append('B_field\',string(params.nCoil));
loop_calculation(params,field_dir) %this will generate magnetic field distributions and save on 'B_filed' folder

%% 3) Use results from step 2 to calculate the complex signal for each coil

fprintf('---------- 3) Calculating the complex signal ---------------------\n');
magDir = 'Ground truth magnitude image';
phDir = 'Ground truth phase image';
maskDir = 'Brain mask';

signal_simulation(params,field_dir,magDir,phDir,maskDir,noiseLv);

%% 4) Performs the phase matching (phase offset correction) using MCPC3D-S or VRC

fprintf('---------- 4) Phase offset correction using %s -------------------\n',method);
if strcmp(method,'mcpc3d-s') == 1
    MCPC3DS(params,magDir,maskDir,noiseLv)
elseif strcmp(method,'vrc') == 1
    VRC(params,noiseLv)
end

%% 5) Performs phase combination after offset correction using magnitude as weighting
%     factor with power k

fprintf('---------- 5) Phase coil combination using power %s --------------\n',string(k));

ph_combination(params,noiseLv,method,k)

%% 6) Calculates the QSM with the recombined images

fprintf('---------- 6) Calculating QSM ------------------------------------\n');

outDir = append(string(params.nCoil),'_Coils\head_phantom_noise_',string(noiseLv),'\',method,'\',string(k));
mask = niftiread(maskDir);
niftiwrite(mask,append(outDir,'\mask.nii'),'Compressed',true);
mag = niftiread(magDir);
niftiwrite(mag,append(outDir,'\mag.nii'),'Compressed',true);
matrix_size = params.size;
voxel_size = params.voxel_size;
B0 = params.B0;
B0_dir = params.B0_dir;
CF = params.CF;
TE = params.TE;
delta_TE = params.delta_TE;
save(append(outDir,'\data.mat'), 'TE', 'CF', 'delta_TE', 'B0_dir', 'voxel_size', 'matrix_size', 'B0');
run_QSM_pipeline(outDir);