function [xdir, ydir, zdir] = CheckOrientation(info)

% CHECKORIENTATION Interpretes 3D orientation information.
%
%   [xdir, ydir, zdir] = CHECKORIENTATION(info) checks the directions of
%   the data encoding in "info.optodes.plot3orientation" to make it
%   compatible with 3D cap visualizations. The default reverses the x-axis
%   and leaves the other two alone. The directions are returned in "xdir",
%   "ydir", and "zdir" 
% 
% See Also: PLOTCAPDATA.

%% Parameters and Initialization.
xdir = [];
ydir = [];
zdir = [];

%% Interpret the orientation codes.
switch info.optodes.plot3orientation.i
    case 'R2L'
        xdir = 'reverse';
    case 'L2R'
        xdir = 'normal';
    otherwise
        xdir = 'reverse'; % Default.
end
switch info.optodes.plot3orientation.j
    case 'A2P'
        ydir = 'reverse';
    case 'P2A'
        ydir = 'normal';
    otherwise
        ydir = 'normal'; % Default.
end
switch info.optodes.plot3orientation.k
    case {'V2D', 'I2S'}
        zdir = 'reverse';
    case {'D2V', 'S2I'}
        zdir = 'normal';
    otherwise
        zdir = 'normal'; % Default.
end