function [data, info] = Load_HOMER(filename, pn)

% LOAD_HOMER Converts and loads a HOMER2 ".nirs" file into ND2.
% 
%   [data, info] = LOAD_HOMER(filename, pn) loads a HOMER2 file specified
%   by "filename" and path "pn", and converts it into the ND2 format output
%   as "data" and "info".
% 
% Dependencies: CONVERTER_HOMER_TO_ND2.
% 
% See Also: SAVE_HOMER.

%% Parameters and Initialization.
data = [];
info = [];

if ~exist('pn', 'var')  ||  isempty(pn)
    [pn, filename, ext] = fileparts(filename);
else
    [pn, filename, ext] = fileparts(fullfile(filename, pn));
end

%% Load HOMER .nirs file.
nirs = load(fullfile(pn, [filename, ext]), '-mat');
% We want to load it into a structure, not into the workspace directly.

%% Convert to ND2 format.
[data, info] = converter_HOMER_to_ND2(nirs);



%
