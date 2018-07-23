function [A,Gsd]=g2a_CW(Gs,Gd,dc,dim,flags)

% g2a(): Make A-Matrix with Adjoint Method and Rytov Approximation
% Gs    Green's functions for sources
% Gd    Green's functions for detectors
% dc    Diffusion coefficient
% dim   space meta data structure
%
% 
% Copyright (c) 2017 Washington University 
% Created By: Adam T. Eggebrecht
% Eggebrecht et al., 2014, Nature Photonics; Zeff et al., 2007, PNAS.
%
% Washington University hereby grants to you a non-transferable, 
% non-exclusive, royalty-free, non-commercial, research license to use 
% and copy the computer code that is provided here (the Software).  
% You agree to include this license and the above copyright notice in 
% all copies of the Software.  The Software may not be distributed, 
% shared, or transferred to any third party.  This license does not 
% grant any rights or licenses to any other patents, copyrights, or 
% other forms of intellectual property owned or controlled by Washington 
% University.
% 
% YOU AGREE THAT THE SOFTWARE PROVIDED HEREUNDER IS EXPERIMENTAL AND IS 
% PROVIDED AS IS, WITHOUT ANY WARRANTY OF ANY KIND, EXPRESSED OR 
% IMPLIED, INCLUDING WITHOUT LIMITATION WARRANTIES OF MERCHANTABILITY 
% OR FITNESS FOR ANY PARTICULAR PURPOSE, OR NON-INFRINGEMENT OF ANY 
% THIRD-PARTY PATENT, COPYRIGHT, OR ANY OTHER THIRD-PARTY RIGHT.  
% IN NO EVENT SHALL THE CREATORS OF THE SOFTWARE OR WASHINGTON 
% UNIVERSITY BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, OR 
% CONSEQUENTIAL DAMAGES ARISING OUT OF OR IN ANY WAY CONNECTED WITH 
% THE SOFTWARE, THE USE OF THE SOFTWARE, OR THIS AGREEMENT, WHETHER 
% IN BREACH OF CONTRACT, TORT OR OTHERWISE, EVEN IF SUCH PARTY IS 
% ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.


%% Parameters and Initialization
if ~isfield(flags,'Hz'),flags.Hz=0;end
numc=size(Gs,1);
srcnum=size(Gs,2);
detnum=size(Gd,2);
numpt=size(Gd,3);

measnum=srcnum*detnum;
A=zeros(numc,srcnum,detnum,numpt,'single');


%% Adjoint Formulation and Normalization: Acw_numerator = Gs*Gd
for lambda=1:numc
    disp(['Creating Adjoint for Lambda ',num2str(lambda)])
    A(lambda,:,:,:)=bsxfun(@times,...
        reshape(squeeze(Gs(lambda,:,:)),srcnum,1,numpt),...
        reshape(squeeze(Gd(lambda,:,:)),1,detnum,numpt));
end

A=reshape(A,numc,measnum,numpt);


%% Calculate Gsd
% Acw_denominator = Gs(d)
disp('Calculating Gsd')
[~,Gdidx]=max(Gd,[],3); %Gs(d)
Gsd=zeros(numc,measnum);
for lambda=1:numc
    for j=1:srcnum
        Gsd(lambda,j:srcnum:end)=Gs(lambda,j,Gdidx(lambda,:));
    end
end

%% Normalize Rytov with Gsd and interp with vol and diff coef
for lambda=1:numc
    disp(['Normalizing Rytov, Lambda ',num2str(lambda)])
    for i=1:measnum
        A(lambda,i,:)=A(lambda,i,:)./Gsd(lambda,i);
    end
    
    disp(['>Normalizing Discretized Space, Lambda ',num2str(lambda)])
    tic
    f=dim.sV^3./dc(lambda,:);
    A(lambda,:,:)=bsxfun(@times,f,squeeze(A(lambda,:,:)));
    toc
end


%% Remove NaN's
A(isnan(A))=0;