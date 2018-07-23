function h = PlotTimeTraceData(data, time, params)

% PLOTTIMETRACEDATA A basic time traces plotting function.
%
%   PLOTTIMETRACEDATA(data, info) takes a light-level array "data" of the
%   MEAS x TIME format, and plots its time traces.
%
%   PLOTTIMETRACEDATA(data, info, params) allows the user to specify
%   parameters for plot creation.
% 
%   h = PLOTTIMETRACEDATA(...) passes the handles of the plot line objects
%   created.
%
%   "params" fields that apply to this function (and their defaults):
%       fig_size    [200, 200, 560, 420]    Default figure position vector.
%       fig_handle  (none)                  Specifies a figure to target.
%                                           If empty, spawns a new figure.
%       xlimits     'auto'                  Limits of x-axis.
%       xscale      'linear'                Scaling of x-axis.
%       ylimits     'auto'                  Limits of y-axis.
%       yscale      'linear'                Scaling of y-axis.
%
% See Also: PLOTTIMETRACEALLMEAS, PLOTTIMETRACEMEAN.

%% Parameters and Initialization.
LineColor = 'w';
BkgdColor = 'k';

dims = size(data);
Nt = dims(end);
NDtf = (ndims(data) > 2);

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
if ~isfield(params, 'xlimits')  ||  isempty(params.xlimits)
    params.xlimits = 'auto';
end
if ~isfield(params, 'xscale')  ||  isempty(params.xscale)
    params.xscale = 'linear';
end
if ~isfield(params, 'ylimits')  ||  isempty(params.ylimits)...
        ||  (all(all(data > params.ylimits(2)))...
        &&  all(all(data < params.ylimits(1))))
    params.ylimits = 'auto';
end
if ~isfield(params, 'yscale')  ||  isempty(params.yscale)
    params.yscale = 'linear';
end

if ~exist('time', 'var')
    time = 1:Nt;
end

%% N-D Input.
if NDtf
    data = reshape(data, [], Nt);
end

%% Plot Data.
h = plot(time, data', 'LineWidth', 1); % Plot mean of measurements vs. time.

%% Format Plot.
box on

a = gca;
a.Color = BkgdColor;
a.XColor = LineColor;
a.YColor = LineColor;

%% Scaling.
ylim(params.ylimits)
xlim(params.xlimits)
a.YScale = params.yscale;
a.XScale = params.xscale;



%
