function [synchpts, synchtype] = InterpretSynchBeeps(synch)

% INTERPRETSYNCHBEEPS Automated synch file analysis.
% 
%   [synchpts, synchtype] = INTERPRETSYNCHBEEPS(synch) uses the MATLAB
%   function FINDPEAKS to convert the stim synch array "synch" into a set
%   of pulse timepoints and pulse heights, which are returned in "synchpts"
%   and "synchtype" respectively.
% 
% See Also: LOAD_ACQDECODE_DATA, READAUX, INTERPRETSTIMSYNCH, FINDPEAKS.

%% Parameters and initialization.
% The 1st row contains the std of signal intensity in each frame.
synch1 = squeeze(synch(1, :)) - mean(synch(1, :)); 

% Set peak threshold.
thresh = 0.25;
m = thresh * max(synch1);
dt = 5;

jitter_factor = 5;

%% Peak finding.
[~, synchpts] = findpeaks(synch1, 'minpeakheight', m, 'minpeakdistance', dt);

% If we have frequency info (2nd row), then look at peak times.
if size(synch, 1) > 1
    synchtype = synch(2, synchpts);
    
    % Fix any frequency space jitter by quantizing to 5.
    synchtype = jitter_factor * round(synchtype / jitter_factor);
else
    synchtype = [];
end



%
