function rot = rotation_matrix(direction, theta)

% ROTATION_MATRIX Creates a rotation matrix.
% 
%   rot = ROTATION_MATRIX(direction, theta) generates a rotation matrix
%   "rot" for the vector "direction" given an angle "theta" (in radians).
% 
% See Also: ROTATE_CAP.

%% Parameters and Initialization.
rot = zeros(3);

%% Generate rotation matrices.
switch direction
    case 'x'
        rot = [1 0 0;...
            0 cos(theta) -sin(theta);...
            0 sin(theta) cos(theta)];
    case 'y'
        rot = [cos(theta) 0 sin(theta);...
            0 1 0;...
            -sin(theta) 0 cos(theta)];
    case 'z'
        rot = [cos(theta) -sin(theta) 0;...
            sin(theta) cos(theta) 0;...
            0 0 1];
end