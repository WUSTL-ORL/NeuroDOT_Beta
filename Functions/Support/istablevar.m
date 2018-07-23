function tf = istablevar(table, varname)

% ISTABLEVAR Checks if a variable or list of variables exist in a table.
% 
%   ISTABLEVAR(table, varname) performs the same logical check on tables as
%   ISFIELD does for structure arrays, by checking if the variable(s)
%   "varname" exist within the table "table". "varname" must be either a
%   string or a 1D cell array of strings. A horizontal cell array will give
%   a logical array for each cell array element, while a vertical array
%   will be equivalent to "ALL(ISTABLEVAR)".
% 
%   Example: If info.iRad is a table with variable names 'Src', 'Det',
%   'WL', 'NN', and 'r', then,
% 
%       ISTABLEVAR(info.iRad, {'WL'})
%       
%       gives
%       
%       ans = 
%           1
% 
%       and with a horizontal cell array,
% 
%       ISTABLEVAR(info.iRad, {'WL', 'NN'})
% 
%       gives
% 
%       ans = 
%           1   1
% 
%       However, note that the component function STRCMP in ISTABLEVAR is
%       case-sensitive, so,
% 
%       ISTABLEVAR(info.iRad, {'wL', 'Nn'})
% 
%       will give 
%
%       ans =
%           0   0
% 
%       and with a vertical input array will result in a single output,
%       only returning "true" if both strings are matches.
% 
%       ISTABLEVAR(info.iRad, {'WL'; 'NN'})
% 
%       ans =
%           1
% 
% See Also: IS*, ISFIELD.

if ~istable(table)
    error('Input "table" is not a table.')
end

if ~ischar(varname)  &&  ~iscellstr(varname)
    error('Input "varname" is not a cell array of strings.')
end

if ischar(varname)
    tf = istablevar(table, {varname});
    return
end

tf = [];
for var = varname
    tf(end+1) = any(strcmp(varname{1}, table.Properties.VariableNames));
end



%
