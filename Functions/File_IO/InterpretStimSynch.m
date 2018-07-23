function synch = InterpretStimSynch(raw_synch, framepts, info)

% INTERPRETSTIMSYNCH Reads stimulus from frame synch file.
% 
%    synch = INTERPRETSTIMSYNCH(raw_synch, framepts, info) reads the frames
%    "framepts" of an auxiliary synch file "raw_synch", then calculates and
%    returns synch block standard deviation and frequency information in
%    "synch".
% 
% See Also: LOAD_ACQDECODE_DATA, READAUX, INTERPRETSYNCHBEEPS.

%% Parameters and Initialization.
synch = zeros(2, info.io.nframe);

%% Cycle over all frames in recording
for f = 1:info.io.nframe - 1
    % Pick out a frame from synch channel.
    synchblock = raw_synch(framepts(f):(framepts(f) + floor(info.io.framesize) - 1));
    
    % Take std to look for beeps.
    synch(1, f) = std(synchblock);
    
    % Find frequency at peak.
    fsynch = abs(fft(synchblock));
    [~, synch(2, f)] = max(fsynch(1:floor(info.io.framesize / 2)));
end



%
