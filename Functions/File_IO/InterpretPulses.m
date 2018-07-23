function paradigm_out = InterpretPulses(paradigm_in)

% INTERPRETPULSES Reads synch pulses into an experiment paradigm.
% 
%   paradigm_out = INTERPRETPULSES(paradigm_in) reads the pulse frequencies
%   in "info.paradigm.synchtype" and classifies them into pulses in fields
%   "info.paradigm.Pulse_1", "info.paradigm.Pulse_2", etc.
%
% See Also: LOAD_ACQDECODE_DATA, INTERPRETSYNCHBEEPS.

%% Parameters and Initialization.
paradigm_out = paradigm_in;

%% Interpret pulses.
pulse_types = unique(paradigm_out.synchtype, 'stable');
for k = 1:numel(pulse_types)
    paradigm_out.(['Pulse_', num2str(k)]) = find(paradigm_out.synchtype == pulse_types(k));
end



%
