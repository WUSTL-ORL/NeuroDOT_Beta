function PlotGrayData(data, params)

% PLOTGRAYDATA A basic scaled image plotting function.
%
%   PLOTGRAYDATA(data) plots the input "data" as a scaled image.
%
%   PLOTGRAYDATA(data, params) allows the user to specify parameters for
%   plot creation.
%
%   "params" fields that apply to this function (and their defaults):
%       fig_size    [200, 200, 560, 420]    Default figure position vector.
%       fig_handle  (none)                  Specifies a figure to target.
%                                           If empty, spawns a new figure.
%       climits     [data min and max]      Limits of color axis.
%
% See Also: PLOTGRAY.

%% Parameters and Initialization.
BkgdColor = 'k';
LineColor = 'w';

dims = size(data);
Nt = dims(end);
NDtf = (ndims(data) > 2);
Nm = prod(dims(1:end-1));

if ~exist('params', 'var')
    params = [];
end

if ~isfield(params, 'fig_size')  ||  isempty(params.fig_size)
    params.fig_size = [200, 200, 560, 420];
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
if ~isfield(params, 'climits')  ||  isempty(params.climits)
    params.climits = [min(data(:)), max(data(:))];
end

%% N-D Input.
if NDtf
    data = reshape(data, [], Nt);
end

%% Plot Data.
hold on

imagesc(data, params.climits)

%% Format Plot.
box on
colormap(gray)

a = gca;
a.XColor = LineColor;
a.YColor = LineColor;
a.Color = LineColor;



%
