function iA_out = smooth_Amat(iA_in, dim, gsigma)

% SMOOTH_AMAT Performs Gaussian smoothing on a sensitivity matrix.
%
%   iA_out = SMOOTH_AMAT(iA_in, dim, gsigma) takes the inverted VOX x MEAS
%   sensitivity matrix "iA_in" and performs Gaussian smoothing in the 3D
%   voxel space on each of the concatenated measurement matrices within,
%   returning it as "iA_out". The user specifies the Gaussian filter
%   half-width "gsigma".
%
% See Also: TIKHONOV_INVERT_AMAT, RECONSTRUCT_IMG, FINDGOODMEAS.

%% Parameters and Initialization.
[Nvox, Nm] = size(iA_in);
iA_out = zeros(Nvox, Nm, 'single');

nVx = dim.nVx;
nVy = dim.nVy;
nVz = dim.nVz;

gsigma = gsigma / dim.sV;


%% Preallocate voxel space.
if isfield(dim, 'Good_Vox')
    GV = dim.Good_Vox;
else
    GV = ones(nVx, nVy, nVz); % WARNING: THIS RUNS WAY SLOWER.
end

%% Do smoothing in parallel.
parpool
parfor k = 1:Nm
    iAvox = zeros(nVx, nVy, nVz); % Set up temp iAvox
    iAvox(GV) = iA_in(:, k); % Grab iA vox for a meas
    iAvox = imgaussfilt3(iAvox,gsigma); % smooth
    iA_out(:, k) = single(iAvox(GV)); % Put back into vector form on the way out.
end

%% Shut down pool so this can be re-run.
delete(gcp('nocreate'))

%
