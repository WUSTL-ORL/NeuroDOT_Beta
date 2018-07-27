%% NEURODOT BASE DOT PROCESSING SCRIPT
% This script combines both the Preprocessing and Reconstruction pipelines.
% A file of sample data is already designated below, but you can use the
% "load" command to load your own optical data. In order to load the sample
% file, change the path below in the "addpath" line to the folder under
% which you have ND2 installed.
% 
% A number of select visualizations have been left commented at the end of
% this script.

%% Installation
% installpath = ''; % INSERT YOUR DESIRED INSTALL PATH HERE
% addpath(genpath(installpath))

%% PREPROCESSING PIPELINE
%% S-D Measurements
clear; close all; clc
load('Data/NeuroDOT_Base_HW_Sample_1.mat')

%% Logmean Light Levels
lmdata = logmean(data);

%% Detect Noisy Channels
info = FindGoodMeas(lmdata, info, 0.075);

%% Detrend Data
ddata = detrend_tts(lmdata);

%% High Pass Filter
hpdata = highpass(lmdata, .02, info.system.framerate);

%% Low Pass Filter 1
lp1data = lowpass(hpdata, 1, info.system.framerate);

%% Superficial Signal Regression
hem = gethem(lp1data, info);
[SSRdata, ~] = regcorr(lp1data, info, hem);

%% Low Pass Filter 2
lp2data = lowpass(SSRdata, 0.5, info.system.framerate);

%% 1 Hz Resampling
[rdata, info] = resample_tts(lp2data, info, 1, 1e-5);

%% Block Averaging
badata = BlockAverage(rdata, info.paradigm.synchpts(info.paradigm.Pulse_2), 30);

preprocessed = badata;

%% RECONSTRUCTION PIPELINE
%% Sensitivity A Matrix
if ~exist('A', 'var')
    load('A_Adult_96x92.mat') % Contains A-matrix, dims, infoA.
end

for j = 1:2
    keep = (info.pairs.WL == j) & (info.pairs.r2d <= 42) & info.MEAS.GI;
        
    %% Invert A-Matrix
    iA = Tikhonov_invert_Amat(A(keep, :), 0.01, 0.1);
    
    %% Smooth Inverted A-Matrix
    iA_smoothed = smooth_Amat(iA, dim, 5);
    
    %% Reconstruct Image Volume
    cortex_mu_a(:, :, j) = reconstruct_img(preprocessed(keep, :), iA_smoothed);
end

%% Spectroscopy
load('E.mat')
cortex_Hb = spectroscopy_img(cortex_mu_a, E);

cortex_HbO = cortex_Hb(:, :, 1);
cortex_HbR = cortex_Hb(:, :, 2);
cortex_HbT = cortex_HbO + cortex_HbR;

cortex_HbOvol = Good_Vox2vol(cortex_HbO, dim);
cortex_HbOvol = normalize2range_tts(cortex_HbOvol, 1:4);

%% Select Visualizations
% % % 
% % % % Raw data and cap viz.
% % % params.rlimits = [10, 16];
% % % params.Nwls = 2;
% % % 
% % % PlotTimeTraceAllMeas(data, info, params)
% % % PlotFalloffLL(data, info)
% % % 
% % % PlotCap(info)
% % % 
% % % params.mode = [];
% % % PlotCapMeanLL(data, info, params)
% % % 
% % % params2 = params;
% % % params2.rlimits = [27, 33];
% % % PlotCapMeanLL(data, info, params2)
% % % 
% % % % Logmean, time traces and gray plots.
% % % params.yscale = 'linear';
% % % params.ylimits = 'auto';
% % % PlotTimeTraceAllMeas(lmdata, info, params)
% % % 
% % % PlotGray(lmdata, info, params)
% % % 
% % % params.ylimits = [];
% % % params.yscale = [];
% % % 
% % % % Noisy channels.
% % % PlotHistogramSTD(info, params)
% % % 
% % % params.mode = 'good';
% % % params.rlimits = [10, 16; 27, 33; 36, 42; 44, 50];
% % % PlotCapGoodMeas(info, params)
% % % 
% % % params.mode ='bad';
% % % params.rlimits = [10, 16; 27, 33; 36, 42];
% % % PlotCapGoodMeas(info, params)
% % % 
% % % params.mode = [];
% % % params.rlimits = [10, 16];
% % % 
% % % % Mean time trace for first 4 signal processing steps.
% % % params.fig_handle = figure('Color', 'k');
% % % PlotTimeTraceMean(lmdata, info, params)
% % % PlotTimeTraceMean(ddata, info, params)
% % % PlotTimeTraceMean(hpdata, info, params)
% % % PlotTimeTraceMean(lp1data, info, params)
% % % legend({'logmean', 'detrended', 'HPF', 'LPF1'}, 'Color', [0.1, 0.1, 0.1], 'TextColor', 'w')
% % % title('r \in [10, 16], 850 nm')
% % % 
% % % % Power spectrum for 3 signal processing steps before SSR.
% % % params.fig_handle = figure('Color', 'k');
% % % params.ylimits = [0, 1e-5];
% % % PlotPowerSpectrumMean(ddata, info, params)
% % % PlotPowerSpectrumMean(hpdata, info, params)
% % % PlotPowerSpectrumMean(lp1data, info, params)
% % % legend({'detrended', 'HPF', 'LPF1'}, 'Color', [0.1, 0.1, 0.1], 'TextColor', 'w')
% % % title('r \in [10, 16], 850 nm')
% % % 
% % % % Showing superficial and cortical layers for before and after SSR.
% % % params.rlimits = [10, 16; 27, 33];
% % % params.fig_handle = figure('Color', 'k');
% % % PlotPowerSpectrumMean(lp1data, info, params)
% % % title('LPF1')
% % % 
% % % params.fig_handle = figure('Color', 'k');
% % % PlotPowerSpectrumMean(SSRdata, info, params)
% % % title('SSR')
% % % 
% % % params.fig_handle = [];
% % % PlotGray(lp1data, info, params)
% % % title('LPF1')
% % % PlotGray(SSRdata, info, params)
% % % title('SSR')
% % % 
% % % params.ylimits = [];
% % % params.fig_handle = figure('Color', 'k');
% % % PlotTimeTraceMean(lp1data, info, params)
% % % title('LPF1')
% % % 
% % % params.fig_handle = figure('Color', 'k');
% % % PlotTimeTraceMean(SSRdata, info, params)
% % % title('SSR')
% % % 
% % % % Now just showing cortical layers for steps after SSR.
% % % params.rlimits = [27, 33];
% % % params.fig_handle = figure('Color', 'k');
% % % PlotPowerSpectrumMean(SSRdata, info, params)
% % % PlotPowerSpectrumMean(lp2data, info, params)
% % % legend({'SSR', 'LPF2'}, 'Color', 'k', 'TextColor', 'w')
% % % title('r \in [27, 33], 850 nm, GM')
% % % 
% % % params.rlimits = [27, 33];
% % % params.ylimits = [-0.005 0.005];
% % % params.fig_handle = figure('Color', 'k');
% % % PlotTimeTraceMean(SSRdata, info, params)
% % % PlotTimeTraceMean(lp2data, info, params)
% % % legend({'SSR', 'LPF2'}, 'Color', 'k', 'TextColor', 'w')
% % % title('r \in [27, 33], 850 nm, GM')
% % % 
% % % params.fig_handle = [];
% % % PlotTimeTraceMean(rdata, info, params)
% % % 
% % % % Normalizing helps us see classical HbO/R/T activation patterns.
% % % ndata = normalize2range_tts(badata, 1:4);
% % % 
% % % params.useGM = 1;
% % % params.ylimits = [-0.06, 0.06];
% % % params.yscale = 'linear';
% % % PlotTimeTraceAllMeas(ndata, info, params)
% % % 
% % % PlotGray(ndata, info, params)
% % % 
% % % % Go to voxel space.
% % % cortex_mu_a_vol1 = Good_Vox2vol(cortex_Hb(:, :, 1), dim);
% % % cortex_mu_a_vol2 = Good_Vox2vol(cortex_Hb(:, :, 2), dim);
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
