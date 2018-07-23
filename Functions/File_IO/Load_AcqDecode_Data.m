function [data, info, synch, aux, framepts] = Load_AcqDecode_Data(filename)

% LOAD_ACQDECODE_DATA Loads a single AcqDecode file.
%
%   [data, info, synch, aux, framepts] = LOAD_ACQDECODE_DATA(filename)
%   reads a raw data file and all secondary files scan files in the
%   directory specified by "filename". The raw data is validated and
%   checked for missing frames, then reshaped into the ND2 format.
%
%   All secondary files must be located in the same folder as "filename".
%
%   The information is returned as a raw light level array "data", a
%   metadata structure "info", stimulus synchronization information
%   "synch", raw auxiliary file data "aux", and frame time point array
%   "framepts".
% 
%   Currently supports ".mag" and ".iq" files.
%
% Dependencies: READ_ACQDECODE_HEADER, READAUX, READINFOTXT,
% CHECK4MISSINGDATA, INTERPRETSTIMSYNCH, INTERPRETSYNCHBEEPS,
% INTERPRETPULSES.
%
% See Also: LOADMULTI_ACQDECODE_DATA.

%% Parameters and Initialization.
% This is the sample rate of the MOTU system ORL uses. Can be changed
% manually as needed, but we have no formal plans just yet to elaborate
% upon this code.
sample_rate = 96000;

% Parse filename.
[pn, fn, ext] = fileparts(filename);

if isempty(ext)
    ext = '.mag';
end

disp(['> Loading AcqDecode data file ', fullfile(pn, [fn, ext])])

%% Open and read .mag file and header.
fid = fopen(fullfile(pn, [fn, ext]), 'rb');
[Nd, Ns, Nwl, Nt] = Read_AcqDecode_Header(fid);
data = fread(fid, 'double');
fclose(fid);

%% Read info file.
info.io = ReadInfoTxt(fullfile(pn, [fn, '-info.txt']));

%% Read frame-synch file.
framepts = dlmread(fullfile(pn, [fn, '.fs']));

%% Compatibility.
% Check for non-integer frames.
Nmeas = Nd * Ns * Nwl;
if strcmp(ext, '.iq')
    Nmeas = Nmeas * 2;
end
TTL = numel(data) / Nmeas; % Total time length (in MOTU samples)
if strcmp(ext, '.mag')  &&  rem(TTL, 1)
    disp('*** Decoding error: recorded non-integer number of frames ***')
    TTL = floor(TTL);
    dKeep = TTL * Nmeas;
    data = data(1:dKeep);
    framepts(end) = [];
    info.io.frames_acquired = TTL;
end

% Check for file compatibility
if Nt ~= info.io.unix_time
    error('** The Unix Times of the .mag and info files do not match **')
elseif (Nd ~= info.io.Nd  ||  Ns ~= info.io.Ns  ||  Nwl ~= info.io.Nwl)
    error('** One of the Numbers of detectors, sources, or colors does not match **')
end

%% Reshaping.
switch ext
    case '.mag'
        % OLD COMMENT: Shape raw stream into Colors x Sources x Detectors x
        % Time (fastest -> slowest looping, see encoding scheme).
        data = reshape(data, Nwl, Ns, Nd, TTL);
        
        % Rearrange to original standard orientation: Sources x Detectors x
        % Colors x Time
        data = permute(data, [2, 3, 1, 4]);
        
        % Remove first frame from data and framesynch.
        data = data(:, :, :, 2:end);
        framepts = framepts(2:end);
        
        %% Checking for missing data.
        [data, info, framepts] = Check4MissingData(data, info, framepts);
    case '.iq'
        sdata = data(1:2:end);
        cdata = data(2:2:end);
        
        sdata = reshape(sdata, Nwl, Ns, Nd, TTL);
        cdata = reshape(cdata, Nwl, Ns, Nd, TTL);
        
        % Rearrange to standard orientation: Sources x Detectors x Colors x Time.
        data = [];
        data.sin = permute(sdata, [2, 3, 1, 4]);
        data.cos = permute(cdata, [2, 3, 1, 4]);
        
        %% Checking for missing data.
        [data.sin, info, framepts] = Check4MissingData(data.sin, info, framepts);
        [data.cos, info, framepts] = Check4MissingData(data.cos, info, framepts);
        
end

%% Set frame fields.
info.io.nframe = numel(framepts); % number of acquired frames
info.system.framerate = sample_rate / info.io.framesize; % calculate empirical frame rate (MOTU @ 96kHz)
info.system.init_framerate = info.system.framerate;

if strcmp(ext, '.iq')  &&  (TTL ~= info.io.nframe)
    error('** The total number of frames in the files do not match **')
end

%% If there are auxiliary files, get them.
if info.io.naux
    aux = ReadAux(info, fn, pn);
else
    aux = [];
end

%% Get stim synch and interpret it.
if info.io.naux
    synch = InterpretStimSynch(squeeze(aux.aux1), framepts, info);
    
    if ~isempty(synch)
        [info.paradigm.synchpts, info.paradigm.synchtype] = InterpretSynchBeeps(synch);
        info.paradigm = InterpretPulses(info.paradigm);
    end
    
    % Save the initial value of synchpts.
    info.paradigm.init_synchpts = info.paradigm.synchpts;
    
else
    synch = [];
end

%% Load up pad info files.
if isfield(info.io, 'pad')
    info.system.PadName = ['Pad_', info.io.pad];
    if isletter(info.system.PadName(end)) % If loading dual or more files, omits the trailing letter.
        info.system.PadName(end) = [];
    end
    
    S = load([info.system.PadName, '.mat']);
    
    info.optodes = S.info.optodes;
    info.pairs = S.info.pairs;
    info.tissue = S.info.tissue;
end

%% Reorder info structure.
info = orderfields(info);
info.io = orderfields(info.io);

%% Save original data dimensions.
[info.io.Ns, info.io.Nd, info.io.Nwl, info.io.Nt] = size(data);

%% If .mag, reshape data.
if strcmp(ext, '.mag')
    data = reshape(data, [], info.io.Nt);
end



%
