function PlotCap(info, params)

% PLOTCAP A visualization of the cap grid.
%
%   PLOTCAP(info) plots a basic diagram of the cap based on the cap
%   metadata stored in "info.optodes". All optodes are numbered; sources
%   are colored light red, and detectors light blue.
%
%   PLOTCAP(info, params) allows the user to specify parameters for
%   plot creation.
%
%   "params" fields that apply to this function (and their defaults):
%       fig_size    [20, 200, 1240, 420]    Default figure position vector.
%       fig_handle  (none)                  Specifies a figure to target.
%                                           If empty, spawns a new figure.
%       dimension   '2D'                    Specifies either a 2D or 3D
%                                           plot rendering.
%
% Dependencies: PLOTCAPDATA.
% 
% See Also: PLOTCAPGOODMEAS, PLOTCAPMEANLL.

%% Parameters and Initialization.
Ns = length(unique(info.pairs.Src));
Nd = length(unique(info.pairs.Det));
LineColor = 'w';
BkgdColor = 'k';
SMarkerColor = [1, 0.75, 0.75];
DMarkerColor = [0.55, 0.55, 1];

params.mode = 'textpatch';

if ~isfield(params, 'dimension')  ||  isempty(params.dimension)
    params.dimension = '2D'; % '2D' | '3D'
end
if ~isfield(params, 'fig_size')  ||  isempty(params.fig_size)
    switch params.dimension
        case '2D'
            params.fig_size = [20, 200, 1240, 420];
        case '3D'
            params.fig_size = [20, 200, 560, 560];
    end
end
if ~isfield(params, 'fig_handle')  ||  isempty(params.fig_handle)
    params.fig_handle = figure('Color', BkgdColor, 'Position', params.fig_size);
    new_fig = 1;
else
    switch params.fig_handle.Type
        case 'figure'
            set(groot, 'CurrentFigure', params.fig_handle);
        case 'axes'
            set(gcf, 'CurrentAxes', params.fig_handle);
    end
end

SrcRGB = repmat(SMarkerColor, Ns, 1);
DetRGB = repmat(DMarkerColor, Nd, 1);

%% Send to PlotCapData.
PlotCapData(SrcRGB, DetRGB, info, params)

%% Add title.
if new_fig
    title('Cap Grid Layout Diagram', 'Color', LineColor)
end



%
