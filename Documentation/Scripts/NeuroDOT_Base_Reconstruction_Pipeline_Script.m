%% NEURODOT BASE RECONSTRUCTION PIPELINE SCRIPT
% This script runs the Reconstruction pipeline. It is assumed that you have
% already preprocessed a set of data and that it is stored under the
% variable name "preprocessed". Also, note that this pipeline reconstructs
% only the first three NN pairs, filtered for good measurements, and at
% both wavelengths. Spectroscopy will not work without at least two
% wavelengths and a matching E matrix.
% 
% A visualization has been left commented at the end of this script.

%% Installation
% installpath = ''; % INSERT YOUR DESIRED INSTALL PATH HERE
% addpath(genpath(installpath))

%% Sensitivity A Matrix
if ~exist('A', 'var')
    load('A_Adult_96x92.mat') % Contains A-matrix, dims, infoA.
end

for i = 1:2
    keep = (info.pairs.WL == i) & (info.pairs.r2d <= 42) & info.MEAS.GI;
    iA = [];
    iA_smoothed = [];
    
    %% Invert A-Matrix
    iA = Tikhonov_invert_Amat(A(keep, :), 0.01, 0.1);
    
    %% Smooth Inverted A-Matrix
    iA_smoothed = smooth_Amat(iA, dim, 5, 1.2);
    
    %% Reconstruct Image Volume
    cortex_mu_a(:, :, i) = reconstruct_img(preprocessed(keep, :), iA_smoothed);
end

%% Spectroscopy
load('E.mat')
cortex_Hb = spectroscopy_img(cortex_mu_a, E);

cortex_HbO = cortex_Hb(:, :, 1);
cortex_HbR = cortex_Hb(:, :, 2);
cortex_HbT = cortex_HbO + cortex_HbR;

%% Select Visualizations
% % % % Go to voxel space.
% % % cortex_mu_a_vol1 = Good_Vox2vol(cortex_mu_a(:, :, 1), dim);
% % % cortex_mu_a_vol2 = Good_Vox2vol(cortex_mu_a(:, :, 2), dim);
% % % 
% % % cortex_mu_a_vol1 = normalize2range_tts(cortex_mu_a_vol1, 1:4);
% % % cortex_mu_a_vol2 = normalize2range_tts(cortex_mu_a_vol2, 1:4);
% % % 
% % % % Basic interactivity...
% % % t18 = cortex_mu_a_vol1(:, :, :, 18);
% % % PlotSlices(t18)
% % % 
% % % % ... now with atlas.
% % % load('Atlas_MNI152nl_T1_on_111.mat')
% % % PlotSlices(atlas, [], [], t18)
% % % 
% % % % Set coordinates to Superior Temporal Gyrus (STG).
% % % params.slices = [10, 45, 33];
% % % 
% % % t18 = cortex_mu_a_vol2(:, :, :, 18);
% % % PlotSlices(atlas, [], params, t18)
% % % 
% % % t13_21 = mean(cortex_mu_a_vol2(:, :, :, 13:21), 4);
% % % PlotSlices(atlas, [], params, t13_21)
% % % 
% % % t13_21 = mean(cortex_mu_a_vol1(:, :, :, 13:21), 4);
% % % PlotSlices(atlas, [], params, t13_21)
% % % 
% % % % Go to voxel space.
% % % cortex_HbOvol = Good_Vox2vol(cortex_HbO, dim);
% % % cortex_HbRvol = Good_Vox2vol(cortex_HbR, dim);
% % % cortex_HbTvol = Good_Vox2vol(cortex_HbT, dim);
% % % 
% % % cortex_HbOvol = normalize2range_tts(cortex_HbOvol, 1:4);
% % % cortex_HbRvol = normalize2range_tts(cortex_HbRvol, 1:4);
% % % cortex_HbTvol = normalize2range_tts(cortex_HbTvol, 1:4);
% % % 
% % % t18 = cortex_HbOvol(:, :, :, 18);
% % % PlotSlices(atlas, [], params, t18)
% % % 
% % % t18 = cortex_HbRvol(:, :, :, 18);
% % % PlotSlices(atlas, [], params, t18)
% % % 
% % % t18 = cortex_HbTvol(:, :, :, 18);
% % % PlotSlices(atlas, [], params, t18)
% % % 
% % % t13_21 = cortex_HbOvol(:, :, :, 13:21);
% % % PlotSlices(atlas, [], params, mean(t13_21, 4))
% % % 
% % % t13_21 = cortex_HbRvol(:, :, :, 13:21);
% % % PlotSlices(atlas, [], params, mean(t13_21, 4))
% % % 
% % % t13_21 = cortex_HbTvol(:, :, :, 13:21);
% % % PlotSlices(atlas, [], params, mean(t13_21, 4))
% % % 
% % % load('LR_Meshes_MNI_164k.mat')
% % % 
% % % t18 = cortex_HbOvol(:, :, :, 18);
% % % PlotInterpSurfMesh(t18, MNIl, MNIr, dim, params)
% % % 
% % % t18 = cortex_HbRvol(:, :, :, 18);
% % % PlotInterpSurfMesh(t18, MNIl, MNIr, dim, params)
% % % 
% % % t18 = cortex_HbTvol(:, :, :, 18);
% % % PlotInterpSurfMesh(t18, MNIl, MNIr, dim, params)
% % % 
% % % t13_21 = cortex_HbOvol(:, :, :, 13:21);
% % % PlotInterpSurfMesh(mean(t13_21, 4), MNIl, MNIr, dim, params)
% % % 
% % % t13_21 = cortex_HbRvol(:, :, :, 13:21);
% % % PlotInterpSurfMesh(mean(t13_21, 4), MNIl, MNIr, dim, params)
% % % 
% % % t13_21 = cortex_HbTvol(:, :, :, 13:21);
% % % PlotInterpSurfMesh(mean(t13_21, 4), MNIl, MNIr, dim, params)



%
