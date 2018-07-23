function [volume, header] = LoadVolumetricData(filename, pn, file_type)

% LOADVOLUMETRICDATA Loads a volumetric data file.
%
%   [volume, header] = LOADVOLUMETRICDATA(filename, pn, file_type) loads a
%   file specified by "filename", path "pn", and "file_type", and returns
%   it in two parts: the raw data file "volume", and the header "header",
%   containing a number of key-value pairs in 4dfp format.
%
%   [volume, header] = LOADVOLUMETRICDATA(filename) supports a full
%   filename input, as long as the extension is included in the file name
%   and matches a supported file type.
% 
%   Supported File Types/Extensions: '.4dfp' 4dfp, '.nii' NIFTI.
% 
%   NOTE: This function uses the NIFTI_Reader toolbox available on MATLAB
%   Central. This toolbox has been included with NeuroDOT 2.
% 
% Dependencies: READ_4DFP_HEADER, READ_NIFTI_HEADER, MAKE_NATIVESPACE_4DFP.
% 
% See Also: SAVEVOLUMETRICDATA.

%% Parameters and Initialization
volume = [];
header = [];
if ~exist('file_type', 'var')  &&  ~exist('pn', 'var')
    [pn, filename, file_type] = fileparts(filename);
    file_type = file_type(2:end);
end

switch lower(file_type)
    case '4dfp'
        %% Read 4dfp file.
        % Read .ifh header.
        header = Read_4dfp_Header(fullfile(pn, [filename, '.', file_type, '.ifh']));
        
        % Read .img file.
        fid = fopen(fullfile(pn, [filename, '.', file_type, '.img']), 'r', header.byte);
        volume = fread(fid, header.nVx * header.nVy * header.nVz * header.nVt, header.format);
        fclose(fid);
        
        %% Put header into native space if not already.
        header = Make_NativeSpace_4dfp(header);
        
        %% Format for output.
        volume = squeeze(reshape(volume, header.nVx, header.nVy, header.nVz, header.nVt));
        
        switch header.acq
            case 'transverse'
                volume = flip(volume, 2);
            case 'coronal'
                volume = flip(volume, 2);
                volume = flip(volume, 3);
            case 'sagittal'
                volume = flip(volume, 1);
                volume = flip(volume, 2);
                volume = flip(volume, 3);  % Is this wrong???
        end
    case {'nifti', 'nii'}
        %% Call NIFTI_Reader functions.
        %%% NOTE: When passing file types, if you have the ".nii" file
        %%% extension, you must use that as both the "ext" input AND add it
        %%% as an extension on the "filename" input.
        nii = load_nii(fullfile(pn, [filename, '.', file_type]));
        
        header = Read_NIFTI_Header(nii);
        
        volume = flip(nii.img, 1); % NIFTI loads in RAS orientation. We want LAS, so we flip first dim.
        
end



%
