function data_out = lowpass(data_in, omegaHz, frate)

% LOWPASS Applies a zero-phase digital lowpass filter.
%
%   data_out = LOWPASS(data_in, omegaHz, frate) takes a light-level array
%   "data_in" in the MEAS x TIME format and applies to it a
%   forward-backward zero-phase digital lowpass filter at a Nyquist cutoff
%   frequency of "omegaHz * (2 * frate)", returning it as "data_out".
% 
%   This function also removes the linear component of the input data.
%
% See Also: HIGHPASS, LOGMEAN, FILTFILT.
% 
% Copyright (c) 2017 Washington University 
% Created By: Adam T. Eggebrecht
% Eggebrecht et al., 2014, Nature Photonics; Zeff et al., 2007, PNAS.
%
% Washington University hereby grants to you a non-transferable, 
% non-exclusive, royalty-free, non-commercial, research license to use 
% and copy the computer code that is provided here (the Software).  
% You agree to include this license and the above copyright notice in 
% all copies of the Software.  The Software may not be distributed, 
% shared, or transferred to any third party.  This license does not 
% grant any rights or licenses to any other patents, copyrights, or 
% other forms of intellectual property owned or controlled by Washington 
% University.
% 
% YOU AGREE THAT THE SOFTWARE PROVIDED HEREUNDER IS EXPERIMENTAL AND IS 
% PROVIDED AS IS, WITHOUT ANY WARRANTY OF ANY KIND, EXPRESSED OR 
% IMPLIED, INCLUDING WITHOUT LIMITATION WARRANTIES OF MERCHANTABILITY 
% OR FITNESS FOR ANY PARTICULAR PURPOSE, OR NON-INFRINGEMENT OF ANY 
% THIRD-PARTY PATENT, COPYRIGHT, OR ANY OTHER THIRD-PARTY RIGHT.  
% IN NO EVENT SHALL THE CREATORS OF THE SOFTWARE OR WASHINGTON 
% UNIVERSITY BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, OR 
% CONSEQUENTIAL DAMAGES ARISING OUT OF OR IN ANY WAY CONNECTED WITH 
% THE SOFTWARE, THE USE OF THE SOFTWARE, OR THIS AGREEMENT, WHETHER 
% IN BREACH OF CONTRACT, TORT OR OTHERWISE, EVEN IF SUCH PARTY IS 
% ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

%% Parameters and Initialization.
poles = 5;
Npad=10000;

dims = size(data_in);
Nt = dims(end); % Assumes time is always the last dimension.
NDtf = (ndims(data_in) > 2);

%% N-D Input.
if NDtf
    data_in = reshape(data_in, [], Nt);
end
Nm=size(data_in,1);

%% Calculate Nyquist frequency and build filter.
omegaNy = omegaHz * (2 / frate);
[b, a] = butter(poles, omegaNy, 'low');

%% Detrend.
data_in=bsxfun(@minus,data_in,mean(data_in,2)); % remove mean
% d0 = data_in(:, 1); % start point
% dF = data_in(:, Nt); % end point
% beta = -d0;
% 
% alpha = (d0 - dF) ./ (Nt - 1); % slope for linear fit
% alpha_full = bsxfun(@times, [0:(Nt - 1)], alpha);
% correction = bsxfun(@plus, alpha_full, beta); % correction for linear
% data_in = data_in + correction;
data_in=cat(2,zeros(Nm,Npad),data_in,zeros(Nm,Npad));

%% Forward-backward filter data for each measurement.
data_out = filtfilt(b, a, data_in')';
data_out=data_out(:,(Npad+1):(end-Npad));

%% Detrend.
% d0 = data_out(:, 1); % start point
% dF = data_out(:, Nt); % end point
% beta = -d0;
% 
% alpha = (d0 - dF) ./ (Nt - 1); % slope for linear fit
% alpha_full = bsxfun(@times, [0:(Nt - 1)], alpha);
% correction = bsxfun(@plus, alpha_full, beta); % correction for linear
% data_out = data_out + correction;
data_out=bsxfun(@minus,data_out,mean(data_out,2)); % remove mean


%% N-D Output.
if NDtf
    data_out = reshape(data_out, dims);
end



%
