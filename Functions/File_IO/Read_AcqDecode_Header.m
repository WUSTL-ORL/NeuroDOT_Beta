function [Nd, Ns, Nwl, Nt] = Read_AcqDecode_Header(fid)

% READ_ACQDECODE_HEADER Reads the header section of a binary NIRS file.
%
%   [Nd, Ns, Nwl, Nt] = READ_ACQDECODE_HEADER(fid) reads the first bytes of
%   an open binary NIRS file identified by "fid", and selects the correct
%   format to load the rest of the header.
%
% See Also: LOADMULTI_ACQDECODE_DATA, LOAD_ACQDECODE_DATA, FOPEN, FREAD.

%% Read header and select correct format.
switch fread(fid, 1, 'uint16') % Read the format string.
    case 44801 % Original
        % 0xAF01
        fseek(fid, 1, 'cof');
        Nd = fread(fid, 1, 'uint16', 2);
        Ns = fread(fid, 1, 'uint16');
        Nwl = 2;
        Nt = [];
    case 44802 % Old
        % 0xAF02
        fseek(fid, 1, 'cof');
        null_bytes = fread(fid, 1, 'uint16', 2);
        Nd = fread(fid, 1, 'uint16', 2);
        Ns = fread(fid, 1, 'uint16');
        Nwl = 2;
        Nt = [];
    case {44803, 44804} % Current
        % 0xAF04
        null_bytes = fread(fid, 1, 'uint16');
        Nd = fread(fid, 1, 'uint16');
        Ns = fread(fid, 1, 'uint16');
        Nwl = fread(fid, 1, 'uint16', 2); % OLD NOTE: the extra bit here has a meaning, but I don't remember it
        Nt = fread(fid, 1, 'uint32');
end



%
