function data=normrND(data)
%
% This function returns a row-normed matrix. It is assumed that the matrix
% is 2D.

%%
data=bsxfun(@rdivide,data,vecnorm(data,2,2));