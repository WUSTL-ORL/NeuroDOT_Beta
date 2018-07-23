function info_out = operate_optodes(info_in, ops)

% OPERATE_OPTODES Performs the CAP_FITTER operations on a cap grid.
% 
%   info_out = OPERATE_OPTODES(info_in, ops) takes the structure "info_in"
%   and performs the operations defined by the "ops" structure on the
%   optode positions contained within. The results are output as
%   "info_out".
% 
% Dependencies: ROTATE_CAP, ROTATION_MATRIX, SCALE_CAP.
% 
% See Also: CAP_FITTER.

%% Parameters and Initialization.
% Reset current info to initial, and initialize some variables.
info_out = info_in;
info_out.optodes.tpos = [info_in.optodes.spos3; info_in.optodes.dpos3];
Ns = size(info_in.optodes.spos3, 1);
Nd = size(info_in.optodes.dpos3, 1);

% Perform operations: Rotate, Translate, Flip, and Scale.
info_out.optodes.tpos = rotate_cap(info_out.optodes.tpos, [ops.rot_x, ops.rot_y, ops.rot_z]);

info_out.optodes.tpos(:, 1) = info_out.optodes.tpos(:, 1) + ops.trans_x;
info_out.optodes.tpos(:, 2) = info_out.optodes.tpos(:, 2) + ops.trans_y;
info_out.optodes.tpos(:, 3) = info_out.optodes.tpos(:, 3) + ops.trans_z;

if ops.flip_x
    % Flip S's and D's inside of tpos separately.
    info_out.optodes.tpos(1:Ns, 1) = info_out.optodes.tpos(Ns:-1:1, 1);
    info_out.optodes.tpos(Ns+1:Ns+Nd, 1) = info_out.optodes.tpos(Ns+Nd:-1:Ns+1, 1);
end
if ops.flip_y
    info_out.optodes.tpos(1:Ns, 2) = info_out.optodes.tpos(Ns:-1:1, 2);
    info_out.optodes.tpos(Ns+1:Ns+Nd, 2) = info_out.optodes.tpos(Ns+Nd:-1:Ns+1, 2);
end
if ops.flip_z
    info_out.optodes.tpos(1:Ns, 3) = info_out.optodes.tpos(Ns:-1:1, 3);
    info_out.optodes.tpos(Ns+1:Ns+Nd, 3) = info_out.optodes.tpos(Ns+Nd:-1:Ns+1, 3);
end

info_out.optodes.tpos = scale_cap(info_out.optodes.tpos, ops.scale_m);
info_out.optodes.spos3 = info_out.optodes.tpos(1:Ns, :);
info_out.optodes.dpos3 = info_out.optodes.tpos(Ns+1:Ns+Nd, :);