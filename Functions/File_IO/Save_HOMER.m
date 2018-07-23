function Save_HOMER(data, info, filename, pn)

% SAVE_HOMER Converts an ND2 workspace to HOMER2 ".nirs" format to save.
% 
%   SAVE_HOMER(data, info, filename, pn) converts the ND2 variables "data"
%   and "info" into HOMER2's ".nirs" format, and saves into a file
%   specified by "filename" and path "pn".
% 
% Dependencies: CONVERTER_ND2_TO_HOMER.
% 
% See Also: LOAD_HOMER.

%% Parameters and Initialization.
if ~exist('pn', 'var')  ||  isempty(pn)
    [pn, filename, ext] = fileparts(filename);
else
    [pn, filename, ext] = fileparts(fullfile(filename, pn));
end

%% Convert to HOMER format.
nirs = converter_ND2_to_HOMER(data, info);

%% Save HOMER .nirs file.
save(fullfile(pn, [filename, ext]), '-struct', 'nirs', '-mat');



%
