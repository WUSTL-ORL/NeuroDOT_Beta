function aux = ReadAux(info, filename, pn)

% READAUX Reads auxiliary channel files.
% 
%	aux = READAUX(info, filename, pn) reads auxiliary channel files contained
%	in the -info.txt key specified by "info.io.run", "filename", and path
%	"pn". The channel files must be located in the same directory as the
%	raw data.
% 
% See Also: LOADMULTI_ACQDECODE_DATA, LOAD_ACQDECODE_DATA, READINFOTXT.

%% Find all files that match in this folder.
pn_new = pn;
while ~isletter(pn_new(1))
    pn_new = pn(2:end);
end

if isempty(pn_new)
    pn_new = pn;
end
% pn

temp = what(pn_new); % Strips out the '\'.

name = fullfile(temp.path,...
    [filename(1:6), '-run', num2str(info.io.run, '%03g'), '*.raw']);

aux_chan = dir(name);

if isempty(aux_chan)
    error(['** ReadAux: No .raw files were found for ', name, ' ***'])
end

%% Load files.
n = 0;
for chan = aux_chan
    n = n + 1;
    fid = fopen(fullfile(temp.path, chan.name));
    aux.(['aux', num2str(n)]) = fread(fid, 'float32');
    fclose(fid);
end



%
