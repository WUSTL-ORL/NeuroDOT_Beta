function data_out = BlockAverage(data_in, pulse, dt)

% BLOCKAVERAGE Averages data by stimulus blocks.
%
%   data_out = BLOCKAVERAGE(data_in, pulse, dt) takes a data array
%   "data_in" and uses the pulse and dt information to cut that data 
%   timewise into blocks of equal length (dt), which are then averaged 
%   together and output as "data_out".
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
%
% See Also: NORMALIZE2RANGE_TTS.

%% Parameters and Initialization.
dims = size(data_in);
Nt = dims(end); % Assumes time is always the last dimension.
NDtf = (ndims(data_in) > 2); %#ok<ISMAT>
Nbl = length(pulse);


% Check to make sure that the block after the last synch point for this
% pulse does not exceed the data's time dimension. 
if (dt + pulse(end)) > Nt
    Nbl = Nbl - 1;
end

%% N-D Input (for 3-D or N-D voxel spaces).
if NDtf
    data_in = reshape(data_in, [], Nt);
end

%% Cut data into blocks.
Nm=size(data_in,1);
blocks=zeros(Nm,dt,Nbl);
for k = 1:Nbl
    blocks(:, :, k) = data_in(:, pulse(k):(pulse(k) + dt - 1));
end

%% Average blocks and return.
data_out = mean(blocks, 3);

%% N-D Output.
if NDtf
    data_out = reshape(data_out, [dims(1:end-1), dt]);
end