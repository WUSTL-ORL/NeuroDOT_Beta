function [ftmag, ftdomain, ftpower, ftphase] = fft_tts(data, framerate)

% FFT_TTS Performs an FFT.
%
%   ftmag = FFT_TTS(data, framerate) takes a data array "data" of
%   the MEAS x TIME format, pads it timewise to the next highest power of
%   two (for better performance), performs the fast Fourier transform of
%   each channel using the built-in MATLAB function FFT, normalizes by the
%   padded time length, and takes the first half of the transformed data
%   (which is the positive half of the frequency domain). The result is
%   output into "ftmag".
%
%   [ftmag, ftdomain] = FFT_TTS(data, framerate) also returns the
%   corresponding normalized frequency domain "ftdomain", which extends
%   from 0 to the Nyquist frequency, which is calculated from the input
%   "framerate".
%
%   [ftmag, ftdomain, ftpower] = FFT_TTS(data, framerate) also returns the
%   power spectrum, which is the absolute value of the magnitude, squared.
%
%   [ftmag, ftdomain, ftpower, ftphase] = FFT_TTS(data, framerate) also
%   returns the phase at each frequency, as calculated by the MATLAB
%   ANGLE function.
%
% Dependencies: NORMALIZE2RANGE_TTS.
% 
% See Also: LOGMEAN, FFT, POW2, NEXTPOW2, ANGLE.

%% Parameters and Initialization.
dims = size(data);
Nt = dims(end);
NDtf = (ndims(data) > 2);
Ndft = pow2(nextpow2(Nt)); % Zero pack to a power of 2.
Nf = 1 + Ndft / 2;


%% N-D Input.
if NDtf
    data = reshape(data, [], Nt);
end

%% Remove mean.
normdata = bsxfun(@minus,data,mean(data,2));

%% Prep data for FFT.
ftdomain = (framerate / 2) * linspace(0, 1, Nf); % domain of FFT: [zero:Nyquist]

%% Perform FFT.
ftmag = fft(normdata, Ndft, 2) / Ndft; % Do FFT in TIME dimension and normalize by Ndft.
ftmag = 2 * abs(ftmag(:, 1:Nf)); % Take positive frequencies, x2 for negative frequencies.

%% N-D Output.
if NDtf
    ftmag = reshape(ftmag, [dims(1:end-1), Nf]);
end

%% Other outputs.
ftpower = abs(ftmag) .^ 2;
ftphase = angle(ftmag);



%
