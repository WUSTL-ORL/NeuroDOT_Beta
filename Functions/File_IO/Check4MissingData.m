function [data_out, info_out, framepts_out] = Check4MissingData(data_in, info_in, framepts_in)

% CHECK4MISSINGDATA Validates framesynch file against key file info.
%
%   [data_out, info_out, framepts_out] = CHECK4MISSINGDATA(data_in,
%   info_in, framepts_in) takes the -info.txt key file information and
%   compares it to the .fs framesynch file. If any frames are missing
%   samples, the user is asked to abort, exclude incomplete frame(s), or
%   cut all samples after the first incomplete frame.
%
% See Also: LOAD_ACQDECODE_DATA.

%% Parameters and initialization.
data_out = data_in;
info_out = info_in;
framepts_out = framepts_in;

% Approximate frame length = (time steps) * (flashing time + buffer time)
fguess = info_out.io.nts * (info_out.io.nsamp + info_out.io.nblank);

% Actual frame lengths.
fsizes = diff(framepts_out);

%% Check for missing data
bad_frames = (fsizes < fguess - 3)  |  (fsizes > fguess + 3);

%% Discuss with user.
if any(bad_frames)
    figure
    plot(fsizes, 'ok')
    ylabel('Frame Size')
    xlabel('Frame Number')
    disp('** The frame'' sizes exceed expected deviation: samples likely missing **')
    switch input('1: Abort, 2: Exclude All, 3: Keep Previous')
        case 1
            error('** Aborted due to error in data recording **')
        case 2
            data_out = data_in(:, :, :, ~bad_frames); % Note: This is significantly different from the ND1 version, but does the same thing.
            framepts_out = framepts_out(~bad_frames);
            disp(['The following frames were excluded: ', num2str(find(bad_frames))])
        case 3
            stoppt = find(bad_frames, 'first') - 2;
            data_out = data_in(:, :, :, 1:stoppt);
            framepts_out = framepts_out(1:stoppt);
            fsizes = fsizes(1:stoppt);
            disp(['The data was terminated after frame: ', num2str(stoppt)])
    end
end

%% Save information.
info_out.io.framesize = mean(fsizes); % mean frame length



%
