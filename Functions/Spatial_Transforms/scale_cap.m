function tpos_out = scale_cap(tpos_in, M)

% SCALE_CAP Scales a cap grid.
% 
%   tpos_out = SCALE_CAP(tpos_in, M) scales the full cap grid given in
%   "tpos_in" by a factor of "M" around its centroid, and outputs it as
%   "tpos_out".
% 
% See Also: CAP_FITTER.

%% Parameters and Initialization.
centroid = mean(tpos_in, 1);
centroid_mat = repmat(centroid, [size(tpos_in, 1), 1]);

scaling_mat = [M, 0, 0;...
    0, M, 0;...
    0, 0, M];

%% Do Scaling.
tpos_out = (tpos_in - centroid_mat) * scaling_mat + centroid_mat;



%
