function cortex_hb = spectroscopy_img(cortex_mu_a, E)

% SPECTROSCOPY_IMG Completes the Beer-Lambert law from a reconstructed
% image.
%
%   img_out = SPECTROSCOPY_IMG(img_in, E) takes the reconstructed VOX x
%   TIME x WL mua image "img_in" and multiplies it by the inverse
%   of the extinction coefficient matrix "E" to create an output VOX x TIME
%   x HB matrix "img_out", where HB 1 and 2 are the voxel-space time series
%   images for HbO and HbR, respectively.
%
% See Also: RECONSTRUCT_IMG, AFFINE3D_IMG.

%% Parameters and Initialization.
[Nvox, Nt, Nc] = size(cortex_mu_a);
[E1, E2] = size(E);
umol_scale = 1000;

%% Check compatibility of the image and E matrix.
if E1 ~= Nc
    error(['ERROR: The image wavelengths and spectroscopy matrix dimensions do not match.'])
end

%% Invert Spectroscopy Matrix.
iE = inv(E);

% Initialize Outputs
cortex_hb = zeros(Nvox, Nt, Nc, 'single');
for k = 1:E2
    temp = zeros(Nvox, Nt);
    for l = 1:E1
        temp = temp + squeeze(iE(k, l)) .* squeeze(cortex_mu_a(:, :, l));
    end
    cortex_hb(:, :, k) = temp;
end

cortex_hb = cortex_hb .* umol_scale; % Fix units to umol



%
