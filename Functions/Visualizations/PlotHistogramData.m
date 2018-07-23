function h = PlotHistogramData(hist_data, params)

% PLOTHISTOGRAMDATA A basic histogram plotting function.
%
%   PLOTHISTOGRAMDATA(hist_data) plots a histogram of the input data.
%
%   PLOTHISTOGRAMDATA(hist_data, params) allows the user to specify
%   parameters for plot creation.
%
%   h = PLOTHISTOGRAMDATA(...) passes the handles of the plot line objects
%   created.
% 
%   "params" fields that apply to this function (and their defaults):
%       fig_size    [200, 200, 560, 420]    Default figure position vector.
%       fig_handle  (none)                  Specifies a figure to target.
%                                           If empty, spawns a new figure.
%       xlimits     'auto'                  Limits of x-axis.
%       ylimits     'auto'                  Limits of y-axis.
%       bins        200                     Number or array of histogram
%                                           bins.
%
% See Also: PLOTHISTOGRAMSTD, FINDGOODMEAS, PLOTCAPGOODMEAS, HISTOGRAM.

%% Parameters and Initialization.
LineColor = 'w';
BkgdColor = 'k';
FaceAlpha = 0.5;
EdgeAlpha = 0.25;

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
    params.xlimits = 'auto'; % STD (as a %)
end
if ~isfield(params, 'ylimits')  ||  isempty(params.ylimits)
    params.ylimits = 'auto'; % Meas per bin.
end
if ~isfield(params, 'bins')  ||  isempty(params.bins)
    params.bins = 200;
end

%% Plot Data.
hold on

% DOES NOT NEED ND INPUT SUPPORT. "histogram" always uses entire input,
% whether matrix or vector.
h = histogram(hist_data, params.bins, 'FaceAlpha', FaceAlpha,...
    'EdgeColor', LineColor, 'EdgeAlpha', EdgeAlpha);

%% Format axes.
box on

a = gca;
a.Color = BkgdColor;
a.XColor = LineColor;
a.YColor = LineColor;

%% Resize.
ylim(params.ylimits)
xlim(params.xlimits)



%
