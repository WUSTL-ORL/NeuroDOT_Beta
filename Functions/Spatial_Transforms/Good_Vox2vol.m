function imgvol = Good_Vox2vol(img, dim)

% GOOD_VOX2VOL Turns a Good Voxels data stream into a volume.
% 
%   imgvol = GOOD_VOX2VOL(img, dim) reshapes a VOX x TIME array "img" into
%   an X x Y x Z x TIME array "imgvol", according to the dimensions of the
%   space described by "dim".
% 
% See Also: SPECTROSCOPY_IMG.

%% Parameters and Initialization.
[Nvox, Nt] = size(img);

%% Stream image into good voxels.
imgvol = zeros(dim.nVx * dim.nVy * dim.nVz, Nt);
imgvol(dim.Good_Vox, :) = img;

%% Reshape image into the voxel space.
imgvol = reshape(imgvol, dim.nVx, dim.nVy, dim.nVz, Nt);