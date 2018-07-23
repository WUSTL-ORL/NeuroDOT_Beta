function data_out = highpass(data_in, omegaHz, frate)

% HIGHPASS Applies a zero-phase digital highpass filter.
%
%   data_out = HIGHPASS(data_in, omegaHz, frate) takes a light-level array
%   "data_in" in the MEAS x TIME format and applies to it a
%   forward-backward zero-phase digital highpass filter at a Nyquist cutoff
%   frequency of "omegaHz * (2 * frate)", returning it as "data_out".
% 
%   This function also removes the linear component of the input data.
%
% See Also: LOWPASS, LOGMEAN, FILTFILT.

%% Parameters and Initialization.
poles = 5;

dims = size(data_in);
Nt = dims(end); % Assumes time is always the last dimension.
NDtf = (ndims(data_in) > 2);

%% N-D Input.
if NDtf
    data_in = reshape(data_in, [], Nt);
end

%% Calculate Nyquist frequency and build filter.
omegaNy = omegaHz * (2 / frate);
[b, a] = butter(poles, omegaNy, 'high');

%% Detrend.
d0 = data_in(:, 1); % start point
dF = data_in(:, Nt); % end point
beta = -d0;

alpha = (d0 - dF) ./ (Nt - 1); % slope for linear fit
alpha_full = bsxfun(@times, [0:(Nt - 1)], alpha);
correction = bsxfun(@plus, alpha_full, beta); % correction for linear
data_in = data_in + correction;

%% Forward-backward filter data for each measurement.
data_out = filtfilt(b, a, data_in')';

%% N-D Output.
if NDtf
    data_out = reshape(data_out, dims);
end



%
