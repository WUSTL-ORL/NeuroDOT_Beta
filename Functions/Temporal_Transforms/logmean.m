function data_out = logmean(data_in)

% LOGMEAN Takes the log-ratio of raw intensity data.
%
%   data_out = LOGMEAN(data_in) takes a light-level data array "data_in" of
%   the format MEAS x TIME, and takes the negative log of each element of a
%   row divided by that row's average. The result is output into "data_out"
%   in the same MEAS x TIME format.
%
%   The formal equation for the LOGMEAN operation is:
%       y = -ln(x / <x>)
%   The MATLAB pseudocode form is:
%       y(each row) = -log(x(each row) ./ mean(x(each row)));
%
%   Example: If data = [1, 10, 100; exp(1), 10*exp(1), 100*exp(1)];
%
%   then LOGMEAN(data) yields [3.6109, 1.3083, -.9943; 3.6109, 1.3083,
%   -.9943].
%
% See Also: LOWPASS, HIGHPASS.

%% Parameters and Initialization.
dims = size(data_in);
Nt = dims(end); % Assumes time is always the last dimension.
NDtf = (ndims(data_in) > 2);

%% N-D Input.
if NDtf
    data_in = reshape(data_in, [], Nt);
end

%% Perform Logmean.
data_out = -log(bsxfun(@rdivide, data_in, mean(data_in, 2)));

%% N-D Output.
if NDtf
    data_out = reshape(data_out, dims);
end



%
