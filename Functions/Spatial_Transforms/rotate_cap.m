function tpos_out = rotate_cap(tpos_in, dTheta)

% ROTATE_CAP Rotates the cap in space.
%
%   tpos_out = ROTATE_CAP(tpos_in, dTheta) rotates the cap grid given by
%   "tpos_in" by the rotation vector "dTheta" (in degrees) and outputs it
%   as "tpos_out".
% 
% Dependencies: ROTATION_MATRIX.
% 
% See Also: PLOTLRMESHES, SCALE_CAP.

%% Parameters and Initialization.
centroid = mean(tpos_in, 1);
centroid_mat = repmat(centroid, [size(tpos_in, 1), 1]);
Dx_axis = dTheta(1); % Pos rotates true right down
Dy_axis = dTheta(2); % Pos rotates CCW from top
Dz_axis = dTheta(3); % Pos rotates back of cap up
d2r = pi / 180; % Convert from degrees to radians

%% Create rotation matrices.
rotX = rotation_matrix('x', Dx_axis * d2r);
rotY = rotation_matrix('y', Dy_axis * d2r);
rotZ = rotation_matrix('z', Dz_axis * d2r);

%% Rotate around Centroid.
rot = rotX * rotY * rotZ;
tpos_out = (tpos_in - centroid_mat) * rot + centroid_mat;



%
