%% NEURODOT BASE PREPROCESSING PIPELINE SCRIPT
% This script gives a brief example of how to run the Preprocessing
% Pipeline. A file of sample data is already designated below, but you can
% use the "load" command to load your own optical data. In order to load
% the sample file, change the path below in the "addpath" line to the
% folder under which you have ND2 installed.
% 
% A number of select visualizations have been left commented at the end of
% this script.

%% Installation
% installpath = ''; % INSERT YOUR DESIRED INSTALL PATH HERE
% addpath(genpath(installpath))

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
hpdata = highpass(ddata, .02, info.system.framerate);

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
badata = BlockAverage(rdata, info, 2);
% badata = BlockAverage(rdata, info, 2, 34);

preprocessed = badata;

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
% % % params.ylimits = [-0.3, 0.3];
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
% % % title({'LPF1';''})
% % % PlotGray(SSRdata, info, params)
% % % title({'SSR';''})
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



%
