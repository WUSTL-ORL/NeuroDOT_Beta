function cortex_mu_a = reconstruct_img(lmdata, iA)

% RECONSTRUCT_IMG Performs image reconstruction by wavelength using
% inverted A-matrix.
%
%   img = RECONSTRUCT_IMG(data, iA) takes the inverted VOX x MEAS
%   sensitivity matrix "iA" and right-multiplies it by the logmeaned MEAS x
%   TIME light-level matrix "lmdata" to reconstruct an image in voxel
%   space. The image is output in a VOX x TIME matrix "img".
%
% See Also: TIKHONOV_INVERT_AMAT, SMOOTH_AMAT, SPECTROSCOPY_IMG,
% FINDGOODMEAS.

%% Parameters and Initialization.
units_scaling = 100; % Assuming OptProp in mm^-1

%% Reconstruct.
cortex_mu_a = iA * lmdata;

%% Correct units and convert to single.
cortex_mu_a = single(cortex_mu_a ./ units_scaling);