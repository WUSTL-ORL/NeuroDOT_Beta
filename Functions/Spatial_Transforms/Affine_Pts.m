function Pts_new=Affine_Pts(Pts_old,Affine)

% This function transforms 3D data with a given affine transform matrix.

in=[Pts_old,ones(size(Pts_old,1),1)];
out=Affine * in';

Pts_new=out(1:3,:)';