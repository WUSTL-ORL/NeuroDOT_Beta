function iA = Tikhonov_invert_Amat(A, lambda1, lambda2)

% TIKHONOV_INVERT_AMAT Inverts a sensitivity matrix.
%
%   iA = TIKHONOV_INVERT_AMAT(A, lambda1, lambda2) allows the user to
%   specify the values of the "lambda1" and "lambda2" parameters in the
%   inversion calculation. lambda2 for spatially-variant regularization,
%   is optional.
%
% See Also: SMOOTH_AMAT, RECONSTRUCT_IMG, FINDGOODMEAS.

%% Parameters and Initialization.
[Nm, Nvox] = size(A);
if exist('lambda2','var')
    svr=1;
else
    svr=0;
end


%% Spatially variant regularization
if svr
    ll_0=sum(A.^2,1); % diag(L) = diag(A'A) (shortcut)
    ll=sqrt(ll_0+lambda2*max(ll_0)); % Adjust with Lambda2 cut-off value
    A=bsxfun(@rdivide,A,ll);
end

%% Take the pseudo-inverse.
if Nvox < Nm
    Att = zeros(Nvox, 'single'); % Preallocate
    Att = single(A' * A);
    ss = normest(Att); % normest used because Nvox x Nvox "Att" array is very large.
    penalty = sqrt(ss) .* lambda1;
    iA = (Att + penalty .^ 2 .* eye(Nvox, 'single')) \ A';
else
    Att = zeros(Nm, 'single'); % Preallocate
    Att = single(A * A');
    ss = norm(Att);
    penalty = sqrt(ss) .* lambda1;
    iA = A' / (Att + penalty .^ 2 .* eye(Nm, 'single'));
end


clear Att A ss

%% Undo spatially variant regularization 
if svr
    iA=bsxfun(@rdivide,iA,ll');
end


%
