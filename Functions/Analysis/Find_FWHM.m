function [fwhm,stats]=Find_FWHM(Vin,prior,th,type)
%
% This function calculates the full width half maximum of an activation
% given a prior. If desired, a threshold can be defined (default = 0.05).
% Inputs:
%   Vin     Volumetric data
%   prior   Matlab indices of spatial prior to initialize FWHM search
%   th      Relative threshold multiplier (0.5 = 50%)
%   type    1=largest, 2=strongest continuous region


%% Parameters and Initialization

if ~exist('th','var'), th=0.5;end

if exist('prior','var')
pVal=Vin(prior(1),prior(2),prior(3));
pIdx= sub2ind(size(Vin),prior(1),prior(2),prior(3));
else
    [pVal,pIdx]=max(Vin(:));
end
if ~exist('type','var'), type=1;end % 1 for biggest; 2 for strongest


%% Find islands
test0=+(Vin>(th*pVal)); % Threshold and Binarize
test1=bwconncomp(test0); % find islands
if test1.NumObjects>1
keep=zeros(test1.NumObjects,2);
for j=1:test1.NumObjects 
    keep(j,1)=sum(ismember(test1.PixelIdxList{j},pIdx)); % large
    keep(j,2)=sum(Vin(test1.PixelIdxList{j})); % strong
end
test2=zeros(size(test0));
test2(test1.PixelIdxList{keep(:,type)==1})=1; % 1 island w prior
test2=test2.*Vin; % find max of Vin.*test2 and set new prior
fwhm=Find_FWHM(test2);
else
    fwhm=zeros(size(test0));
    fwhm(test1.PixelIdxList{1})=Vin(test1.PixelIdxList{1});
end


%% Centroid and peak locations
keep=find(fwhm==max(fwhm(:)));
[x,y,z]=ind2sub(size(Vin),keep);
stats.peak=[x,y,z]; % peak

keep=find(fwhm~=0);
fu=Vin(keep);
[x,y,z]=ind2sub(size(Vin),keep);
r=[x,y,z];
stats.fwhm=max(max(pdist2(r,r)));              % fwhm
stats.Cent=[mean((x-mean(x)).*fu)+mean(x),... % Centroid
            mean((y-mean(y)).*fu)+mean(y),...
            mean((z-mean(z)).*fu)+mean(z)];

stats.fvhm=length(keep); % fvhm