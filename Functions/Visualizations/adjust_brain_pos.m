function [Lnodes, Rnodes] = adjust_brain_pos(meshL, meshR, params)

% ADJUST_BRAIN_POS Repositions mesh orientations for display.
%
%   [Lnodes, Rnodes] = ADJUST_BRAIN_POS(meshL, meshR) takes the left and
%   right hemispheric meshes "meshL" and "meshR", respectively, and
%   repositions them to the proper perspective for display.
%
%   [Lnodes, Rnodes] = ADJUST_BRAIN_POS(meshL, meshR, params) allows the
%   user to specify parameters for plot creation.
%
%   "params" fields that apply to this function (and their defaults):
%       ctx         'std'       Defines inflation of mesh.
%       orientation 't'         Select orientation of volume. 't' for
%                               transverse, 's' for sagittal.
%       view        'lat'       Sets the view perspective.
% 
% Dependencies: ROTATE_CAP, ROTATION_MATRIX.
% 
% See Also: PLOTLRMESHES.

%% Parameters and Initialization
dy = -5;

if ~exist('params', 'var')  ||  isempty(params)
    params = [];
end

if ~isfield(params, 'ctx')  ||  isempty(params.ctx)
    params.ctx = 'std';
end
if ~isfield(params, 'orientation')  ||  isempty(params.orientation)
    params.orientation = 't';
end
if ~isfield(params, 'view')  ||  isempty(params.view)
    params.view = 'lat';
end

%% Choose inflation.
switch params.ctx
    case 'std'
        str = 'nodes';
    case 'inf'
        str = 'Inodes';
    case 'vinf'
        str = 'VInodes';
end
Lnodes = meshL.(str);
Rnodes = meshR.(str);

%% Standardize orientation.
% If volume is not in transverse orientation, put it there
if strcmp(params.ctx, 'std')
    switch params.orientation 
        case 's'
            Nln = size(Lnodes, 1);
            temp = cat(1, Lnodes, Rnodes);
            temp = rotate_cap(temp, [-90, 0, 90]);
            Lnodes = temp(1:Nln, :);
            Rnodes = temp((Nln + 1):end, :);
        case 'c'
            % Not yet supported.
        case 't'
            % Not yet supported.
    end
end

%% Normalize L and R nodes to their max and min, respectively.
Lnodes(:, 1) = Lnodes(:, 1) - max(Lnodes(:, 1));
Rnodes(:, 1) = Rnodes(:, 1) - min(Rnodes(:, 1));

%% Rotate if necessary
if strcmp(params.view, 'lat')  ||  strcmp(params.view, 'med')
    cmL = mean(Lnodes, 1); % rotate right hemi  for visualization
    cmR = mean(Rnodes, 1);
    rm = rotation_matrix('z', pi);
    
    switch params.view % Rotate
        case 'lat'
            Rnodes = (Rnodes - (repmat(cmR, size(Rnodes, 1), 1))) *...
                rm + (repmat(cmR, size(Rnodes, 1), 1));
        case 'med'
            Lnodes = (Lnodes - (repmat(cmL, size(Lnodes, 1), 1))) *...
                rm + (repmat(cmL, size(Lnodes, 1), 1));
    end
    Rnodes(:, 1) = Rnodes(:, 1) + (cmL(:, 1) - cmR(:, 1)); % Shift over to same YZ plane
    Rnodes(:, 2) = Rnodes(:, 2) - max(Rnodes(:, 2)) + min(Lnodes(:, 2)) + dy;
end



%
