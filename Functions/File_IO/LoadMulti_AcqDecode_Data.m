function [data, info, synch, aux] = LoadMulti_AcqDecode_Data(filename, pn, flags)

% LOADMULTI_ACQDECODE_DATA Loads and combines data from multiple AcqDecode
% files for a single scan.
%
%   [data, info, synch, aux] = LOADMULTI_ACQDECODE_DATA(filename, pn)
%   finds any acquisitions "filename" located in directory "pn", and loads
%   the raw data files and any other relevant scan files contained therein.
%   The information is returned as a raw light level array "data", a
%   metadata structure "info", stimulus synchronization information
%   "synch", and raw auxiliary file data "aux".
% 
%   It is assumed that all files use the AcqDecode format:
%   "DATE-SUBJECT-TAGletter", with a trailing lowercase letter for multiple
%   acquisitions. Also, separate acquisitions are stored in subfolders
%   named by "DATEletter", EG "150115a" and "150115b".
%
%   Currently supports ".mag" and ".iq" files.
% 
%   [data, info, synch, aux] = LOADMULTI_ACQDECODE_DATA(filename, pn,
%   flags) uses the "flags" structure to specify loading parameters.
% 
%   "flags" fields that apply to this function (and their defaults):
%       Nsys            2           Number of acquisitions.
%
% Dependencies: LOAD_ACQDECODE_DATA, CROP2SYNCH. 

%% Parameters and Initialization.
max_data_trim = 10; % Corresponds to 1 second.
here = pwd;

if ~exist('pn', 'var')  ||  isempty(pn)
    pn = here;
end

if exist('flags', 'var')
    if ~isfield(flags, 'Nsys')
        flags.Nsys = 2;
    end
else
    flags.Nsys = 2;
end

[~, fn, ext] = fileparts(filename);
if isempty(ext)
    ext = '.mag';
end
if ~isempty(fn)
    cel = strsplit(fn, '-');
    if (numel(cel{1}) == 6)  &&  ~any(isletter(cel{1}))
        scan_date = cel{1};
    end
    
end

%% Load a variable number of data sets.
switch flags.Nsys
    case 1
        [data, info, synch, aux, framepts] =...
            Load_AcqDecode_Data(fullfile(pn, [fn, ext]));
        
        [data, info] = Crop2Synch(data, info, flags);
        
    case 2
        %% Load in data set A
        [data_a, info_a, synch.a, aux.a, framepts.a] =...
            Load_AcqDecode_Data(fullfile(pn, [scan_date, 'a'],...
            [fn, 'a', ext]));
        
        % Crop set to outermost synch pulses.
        [data_a, info_a] = Crop2Synch(data_a, info_a, flags);
        
        %% Load in data set B
        [data_b, info_b, synch.b, aux.b, framepts.b] =...
            Load_AcqDecode_Data(fullfile(pn, [scan_date, 'b'],...
            [fn, 'b', ext]));
        
        % Crop set to outermost synch pulses.
        [data_b, info_b] = Crop2Synch(data_b, info_b, flags);
        
        %% Combine data sets.
        % Adopt the info_a as our baseline.
        info = info_a;
        
        % Store io structures for troubleshooting.
        info.io = [];
        info.io.a = info_a.io;
        info.io.b = info_b.io;
        
        % Trim the sets to the same number of frames (to within a second).
        Nts = [size(data_a, 2), size(data_b, 2)];
        L = min(Nts);
        dNt = max(Nts) - L;
        if dNt <= max_data_trim
            data_a = data_a(:, 1:L);
            data_b = data_b(:, 1:L);
        else
            error(['** The decoded data from the systems is inconsistent by ',...
                num2str(dNt), ' too many frames **'])
        end
        
        % Reshape, merge, reshape.
        data = [reshape(data_a, [], info_a.io.Nwl, L);...
            reshape(data_b, [], info_b.io.Nwl, L)];
        data = reshape(data, [], L);
        
    case 3
        %% Load in data set A
        [data_a, info_a, synch.a, aux.a, framepts.a] =...
            Load_AcqDecode_Data(fullfile(pn, [scan_date, 'a'],...
            [fn, 'a', ext]));
        
        % Crop set to outermost synch pulses.
        [data_a, info_a] = Crop2Synch(data_a, info_a, flags);
        
        %% Load in data set B
        [data_b, info_b, synch.b, aux.b, framepts.b] =...
            Load_AcqDecode_Data(fullfile(pn, [scan_date, 'b'],...
            [fn, 'b', ext]));
        
        % Crop set to outermost synch pulses.
        [data_b, info_b] = Crop2Synch(data_b, info_b, flags);
        
        %% Load in data set C
        [data_c, info_c, synch.c, aux.c, framepts.c] =...
            Load_AcqDecode_Data(fullfile(pn, [scan_date, 'c'],...
            [fn, 'c', ext]));
        
        % Crop set to outermost synch pulses.
        [data_c, info_c] = Crop2Synch(data_c, info_c, flags);
        
        %% Combine data sets.
        % Adopt the info_a as our baseline.
        info = info_a;
        
        % Store io structures for troubleshooting.
        info.io = [];
        info.io.a = info_a.io;
        info.io.b = info_b.io;
        info.io.c = info_c.io;
        
        % Trim the sets to the same number of frames (to within a second).
        Nts = [size(data_a, 2), size(data_b, 2), size(data_c, 2)];
        L = min(Nts);
        dNt = max(Nts) - L;
        if dNt <= max_data_trim
            data_a = data_a(:, 1:L);
            data_b = data_b(:, 1:L);
            data_c = data_c(:, 1:L);
        else
            error(['** The decoded data from the systems is inconsistent by ',...
                num2str(dNt), ' too many frames **'])
        end
        
        % Reshape, merge, reshape - this matches the data to ND2's
        % "info.pairs" measurement list.
        data = [reshape(data_a, [], info_a.io.Nwl, L);...
            reshape(data_b, [], info_b.io.Nwl, L);...
            reshape(data_c, [], info_c.io.Nwl, L)];
        data = reshape(data, [], L);
end



%
