function SaveVolumetricData(volume, header, filename, pn, file_type)

% SAVEVOLUMETRICDATA Saves a volumetric data file.
%
%   SAVEVOLUMETRICDATA(volume, header, filename, pn, file_type) saves
%   volumetric data defined by "volume" and "header" into a file specified
%   by "filename", path "pn", and "file_type".
%
%   SAVEVOLUMETRICDATA(volume, header, filename) supports a full
%   filename input, as long as the extension is included in the file name
%   and matches a supported file type.
%
%   Supported File Types/Extensions: '.4dfp' 4dfp, '.nii' NIFTI.
%
%   NOTE: This function uses the NIFTI_Reader toolbox available on MATLAB
%   Central. This toolbox has been included with NeuroDOT 2.
%
% Dependencies: WRITE_4DFP_HEADER, WRITE_NIFTI.
%
% See Also: LOADVOLUMETRICDATA, MAKE_NATIVESPACE_4DFP.

%% Parameters and Initialization
if ~exist('file_type', 'var')  &&  ~exist('pn', 'var')
    [pn, filename, file_type] = fileparts(filename);
    file_type = file_type(2:end);
end

switch lower(file_type)
    case '4dfp'
        %% Write 4dfp header.
        switch header.acq
            case 'transverse'
                volume = flip(volume, 2);
            case 'coronal'
                volume = flip(volume, 2);
                volume = flip(volume, 3);
            case 'sagittal'
                volume = flip(volume, 1);
                volume = flip(volume, 2);
                volume = flip(volume, 3);
        end
        
        Write_4dfp_Header(header, fullfile(pn, filename))
        
        %% Write 4dfp image file.
        volume = squeeze(reshape(volume, header.nVx * header.nVy * header.nVz * header.nVt, 1));
        fid = fopen([fullfile(pn, filename), '.4dfp.img'], 'w', 'l');
        fwrite(fid, volume, header.format);
        fclose(fid);
        
    case {'nifti', 'nii'}
        %% Call NIFTI_Reader functions.
        volume = flip(volume, 1); % Convert back from LAS to RAS for NIFTI.
        
        nii = Write_NIFTI(volume, header, fullfile(pn, filename));
        
        save_nii(nii, [fullfile(pn, filename), '.nii']);
        
end



%
