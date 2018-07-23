function data_out = detrend_tts(data_in)

% DETREND_TTS Performs linear detrending.
%
%   data_out = DETREND_TTS(data_in) takes a raw light-level data array
%   "data_in" of the format MEAS x TIME and removes the straight-line fit
%   along the TIME dimension from each measurement, returning it as
%   "data_out".
%
% See Also: LOGMEAN.

%% Parameters and Initialization.
dims = size(data_in);
Nt = dims(end);
NDtf = (ndims(data_in) > 2);

%% N-D Input.
if NDtf
    data_in = reshape(data_in, [], Nt);
end

%% Detrend.
data_out = detrend(data_in')';

%% N-D Output.
if NDtf
    data_out = reshape(data_out, dims);
end



%
