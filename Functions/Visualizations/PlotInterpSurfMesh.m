function PlotInterpSurfMesh(volume, meshL, meshR, dim, params)

% PLOTINTERPSURFMESH Interpolates volumetric data onto hemispheric meshes for
% display.
%
%   PLOTINTERPSURFMESH(volume, meshL, meshR, dim) takes functional imaging
%   data "volume" and interpolates it onto the left and right hemispheric
%   surface meshes given in "meshL" and "meshR", respectively, using the
%   spatial information in "dim". The result is a bilateral sagittal view
%   of the activations overlain onto the surface of the brain represented
%   by the meshes.
%
%   PLOTINTERPSURFMESH(volume, meshL, meshR, dim, params) allows the user to
%   specify parameters for plot creation.
%
%   "params" fields that apply to this function (and their defaults):
%       Scale       (90% max)       Maximum value to which image is scaled.
%       Th                          Thresholds.
%           .P      (25% max)       Value of min threshold to display
%                                   positive data values.
%           .N      (-Th.P)         Value of max threshold to display
%                                   negative data values.
%
% Dependencies: VOL2SURF_MESH, PLOTLRMESHES, ADJUST_BRAIN_POS, ROTATE_CAP,
% ROTATION_MATRIX.
%
% See Also: PLOTSLICES.

%% Parameters and Initialization.
if (ndims(volume) >= 4)  &&  (size(volume, 4) > 1)
    % If volume is >=4D, or if so, and the time dimension > 1...
    error(['*** "volume" input has more than one time point.',...
        ' PlotInterpSurfMesh can only image one time point. ***'])
end

if ~exist('params', 'var')  ||  isempty(params)
    params = [];
end

if ~isfield(params, 'Scale')  ||  isempty(params.Scale)
    params.Scale = 0.9 * max(volume(:));
end
if ~isfield(params, 'Th')  ||  isempty(params.Th)
    params.Th.P = 0.25 * params.Scale;
    params.Th.N = -params.Th.P;
end

%% Interpolate surface mesh into maps.
mapL = vol2surf_mesh(meshL, volume, dim, params);
mapR = vol2surf_mesh(meshR, volume, dim, params);

%% Image the left and right maps.
PlotLRMeshes(mapL, mapR, params);



%
