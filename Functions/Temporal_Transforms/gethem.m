function hem = gethem(data, info, sel_type, value)

% GETHEM Calculates mean across set of measurements.
%
%   hem = GETHEM(data, info) takes a light-level array "data" of the format
%   MEAS x TIME, and using the scan metadata in "info.pairs" averages the
%   measurements for each wavelength present. The result is
%   referred to as the "hem" of a measurement set. If there is a
%   good measurements logical vector present in "info.MEAS.GI", it will be
%   applied to the data; otherwise, "info.MEAS.GI" will be set to true for
%   all measurements (i.e., all measurements are assumed to be good). The
%   variable "hem" is output in the format WL x TIME.
% 
%   hem = GETHEM(data, info, sel_type, value) allows the user to set the
%   criteria for determining shallow measurements. "sel_type" can be 'r2d',
%   'r3d', or 'NN', corresponding to the columns of the "info.pairs" table,
%   and "value" can either take the form of a two-element "[min, max]"
%   vector (for 'r2d' and 'r3d'), or a scalar or vector containing all
%   nearest neighbor numbers to be averaged. By default, this function
%   averages the first nearest neighbor.
%
% See Also: REGCORR, DETREND_TTS.

%% Parameters and Initialization.
[Nm, Nt] = size(data);
cs = unique(info.pairs.WL); % WLs.
Nc = length(cs); % Number of WLs.
hem = zeros(Nc, Nt);

if exist('sel_type', 'var')  &&  exist('value', 'var')
    if ischar(value)
        value = str2double(value);
    end
else
    sel_type = 'r2d';
    value = [10, 16];
end

switch sel_type
    case 'r2d'
        keep_R_NN = (info.pairs.r2d >= value(1))  &...
            (info.pairs.r2d <= value(2));
    case 'r3d'
        keep_R_NN = (info.pairs.r3d >= value(1))  &...
            (info.pairs.r3d <= value(2));
    case 'NN'
        keep_R_NN = zeros(size(info.pairs.NN));
        for k = value
            keep_R_NN = keep_R_NN  |  (info.pairs.NN == k);
        end
end

%% If no GI, assume all measurements good.
if (isfield(info, 'MEAS')  &&  ~istablevar(info.MEAS, 'GI'))
    info.MEAS.GI = true(Nm, 1);
elseif ~isfield(info, 'MEAS')
    info.MEAS = table(true(Nm, 1), 'VariableNames', {'GI'});
end

%% Make "hem" by averaging measurments (e.g., nn1).
for k = 1:Nc
    keep = keep_R_NN  &  info.pairs.WL == cs(k)  &  info.MEAS.GI;
    hem(k, :) = mean(data(keep, :), 1);
end



%
