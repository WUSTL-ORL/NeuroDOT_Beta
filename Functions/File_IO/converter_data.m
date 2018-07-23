function data_out = converter_data(data_in, conversion, info)

% CONVERTER_DATA Reshapes data between ND1 and ND2 formats.
% 
%   data_out = CONVERTER_DATA(data_in, conversion, info) reshapes any ND1 array
%   "data_in" to ND2 array format in "data_out", or vice versa. The
%   direction is determined by the string "conversion", and in the 'ND2 to
%   ND1' direction, "info" is needed.
% 
%   "conversion" can be either 'ND2 to ND1' or 'ND1 to ND2'.
% 
% See Also: CONVERTER_ND1_TO_ND2, CONVERTER_ND2_TO_ND1, CONVERTER_INFO.

%% Reshape to new format.
switch conversion
    case 'ND1 to ND2'
        [Nm, Nwl, Nt] = size(data_in);
        if isstruct(data_in)
            data_out.sin = reshape(data_in.sin, [], Nt);
            data_out.cos = reshape(data_in.cos, [], Nt);
        else
            data_out = reshape(data_in, [], Nt);
        end
    case 'ND2 to ND1'
        Nwl = length(unique(info.pairs.WL));
        [Nm, Nt] = size(data_in);
        if isstruct(data_in)
            data_out.sin = reshape(data_in.sin, Nm/2, Nwl, Nt);
            data_out.cos = reshape(data_in.cos, Nm/2, Nwl, Nt);
        else
            data_out = reshape(data_in, Nm/2, Nwl, Nt);
        end
end



%
