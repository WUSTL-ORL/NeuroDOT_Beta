function header_out = Make_NativeSpace_4dfp(header_in)

% MAKE_NATIVESPACE_4DFP Calculates native space of incomplete 4dfp header.
% 
%   header_out = MAKE_NATIVESPACE_4DFP(header_in) checks whether
%   "header_in" contains the "mmppix" and "center" fields (these are not
%   always present in 4dfp files). If either is absent, a default called
%   the "native space" is calculated from the other fields of the volume.
% 
% See Also: LOADVOLUMETRICDATA, SAVEVOLUMETRICDATA.

%% Parameters and Initialization.
header_out = header_in;

%% Check for mmppix, calculate if not present.
if ~isfield(header_out, 'mmppix')
    if all(~isfield(header_out, {'mmx', 'mmy', 'mmz'}))
        error(['*** Error: Required field(s) ''mmx'', ''mmy'', or ''mmz''',...
            ' not present in input header. ***'])
    end
    
    header_out.mmppix = [header_out.mmx, -header_out.mmy, -header_out.mmz];
    
end

%% Check for center, calculate if not present.
if ~isfield(header_out, 'center')
    if all(~isfield(header_out, {'nVx', 'nVy', 'nVz'}))
        error(['*** Error: Required field(s) ''nVx'', ''nVy'', or ''nVz''',...
            ' not present in input header. ***'])
    end
    
    header_out.center = header_out.mmppix .* ( [header_out.nVx,...
        header_out.nVy, header_out.nVz] / 2 + [0, 1, 1]);
    
end



%
