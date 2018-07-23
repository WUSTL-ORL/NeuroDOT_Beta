function [data_out, info_out] = converter_ND2_to_ND1(data_in, info_in)

% CONVERTER_ND2_TO_ND1 Converts both data and info from ND2 format to ND1.
% 
%   [data_out, info_out] = CONVERTER_ND2_TO_ND1(data_in, info_in) is a
%   container function for CONVERTER_DATA and CONVERTER_INFO. This function
%   is only intended for use with ND1 and ND2 data structures.
% 
% Dependencies: CONVERTER_DATA, CONVERTER_INFO.
% 
% See Also: CONVERTER_ND1_TO_ND2.

%% Parameters and initialization.
conversion = 'ND2 to ND1';

%% Convert data and info.
data_out = converter_data(data_in, conversion, info_in);
info_out = converter_info(info_in, conversion);



%
