function data_out = normalize2range_tts(data_in, range_to_avg)

% NORMALIZE2RANGE_TTS Normalizes time traces to average of a range.
%
%   data_out = NORMALIZE2RANGE_TTS(data_in, range_to_avg) takes a
%   light-level array "data_in" in the MEAS x TIME format, and calculates
%   the mean of each channel for the time points specified by vector
%   "range_to_avg". If no range is specified, the function defaults to
%   averaging all time points. Each channel then has this mean subtracted
%   from it, and the result is output as "data_out".
%
%   The formal equation for the NORMALIZE2RANGE_TTS operation is:
%       y = x - <x(range)>
%   The MATLAB pseudocode form is:
%       y(each row) = x(each row) - mean(x(range));
%
%   Example 1: If data = [21, 20, 19; 300, 295, 305];
%
%   then NORMALIZE2RANGE_TTS(data) yields [1, 0, -1; 0, -5, 5].
%
%   Example 2: If data = [1, 2, 3, 4, 5, 6, 7];
%
%   then NORMALIZE2RANGE_TTS(data, 1:5) yields [-2, -1, 0, 1, 2, 3, 4].
%
% See Also: FFT_TTS, LOGMEAN.

%% Parameters and Initialization.
dims = size(data_in);
Nt = dims(end); % Assumes time is always the last dimension.
NDtf = (ndims(data_in) > 2);
if nargin == 1
    range_to_avg = 1:Nt;
end

%% N-D Input.
if NDtf
    data_in = reshape(data_in, [], Nt);
end

%% Normalize.
data_out = bsxfun(@minus, data_in, mean(data_in(:, range_to_avg), 2)); % Subtract each channel's mean from itself.

%% N-D Output.
if NDtf
    data_out = reshape(data_out, dims);
end



%
