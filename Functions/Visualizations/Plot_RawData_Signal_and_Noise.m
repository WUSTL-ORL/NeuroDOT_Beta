function Plot_RawData_Signal_and_Noise(data,info,params)
%
% This function generates a plot of raw data time traces separated by
% wavelength (columns). The top row shows time traces for all measurements
% within a source-detector distance range (defaults as 0.1 - 5.0 cm). The
% bottom row shows the same measurements but including only measurements
% passing a variance threshold (default: 0.075) as well as vertical lines
% correspondong to the stimulus paradigm.
%
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
Nwl=length(unique(info.pairs.WL));
[Nm,Nt]=size(data);
if ~isreal(data),data=abs(data);end
if isfield(info.system,'init_framerate')
    fr=info.system.init_framerate;
else
    fr=info.system.framerate;
end
    
dt=1/fr;                          
t=[1:1:Nt].*dt;

if ~exist('params','var'), params=struct;end
if ~isfield(params,'bthresh'),params.bthresh=0.075;end
if ~isfield(params,'rlimits'),params.rlimits=[1,40];end
if ~isfield(params, 'yscale'),params.yscale = 'log';end
lambdas=unique(info.pairs.lambda,'stable');
WLs=unique(info.pairs.WL,'stable');

params.fig_handle=figure('Units','Normalized',...
    'Position',[0.1,0.1,0.8,0.8],'Color','k');

%% Check for good measurements
if ~istablevar(info,'MEAS') || ~istablevar(info.MEAS,'GI')
    lmdata=logmean(data);
    info = FindGoodMeas(lmdata, info, params.bthresh);
end


%% 

Nm=size(data,1);
if ~isreal(data)
    dataR=abs(data);
    lmdataR=logmean(dataR);    
    info = FindGoodMeas(lmdataR, info, 0.075);
else
    lmdata=logmean(data);
    info = FindGoodMeas(lmdata, info, 0.075);
end

Phi_0=mean(abs(data),2);
N_Phi_0=std(abs(data),[],2);
lmdata=logmean(data);
Nm_lm=size(lmdata,1);
% if Nm ~= Nm_lm, then data is complex
Ny=std(lmdata,[],2);

cols=[0,0,1;0,0,1;1,0,0;0,1,0;1,0,1;0,1,1];
figure('Color','w');
subplot(2,2,1);
loglog(Phi_0,N_Phi_0,'k*')
xlabel(['\Phi_0']);ylabel(['\sigma (|\Phi|)']);hold on
subplot(2,2,2);
loglog(Phi_0,Ny,'k*');hold on;
loglog(get(gca,'XLim'),[1,1].*0.075,'r')
xlabel(['\Phi_0']);ylabel(['\sigma (|Y|)']);hold on
subplot(2,2,3);
loglog(info.pairs.r2d,N_Phi_0,'k*')
xlabel(['Rsd']);ylabel(['\sigma (|\Phi|)']);hold on
subplot(2,2,4);
loglog(info.pairs.r2d,Ny,'k*')
xlabel(['Rsd']);ylabel(['\sigma (|Y|)']);hold on
loglog(get(gca,'XLim'),[1,1].*0.075,'r')

for j=1:5
    keep=info.MEAS.GI & info.pairs.r2d>10*(j-1) & info.pairs.r2d<=10*j;   
    subplot(2,2,1);
    loglog(Phi_0(keep),N_Phi_0(keep),'o','Color',cols(j,:))    
    subplot(2,2,2);    
    loglog(Phi_0(keep),Ny(keep),'o','Color',cols(j,:))
    subplot(2,2,3);
    loglog(info.pairs.r2d(keep),N_Phi_0(keep),'o','Color',cols(j,:))
    subplot(2,2,4);
    loglog(info.pairs.r2d(keep),Ny(keep),'o','Color',cols(j,:))
end
subplot(2,2,1);
legend([{'All','Rsd<20 GI','Rsd<30 GI','Rsd<40 GI','Rsd<50 GI',...
    'threshold'}],'Location','northwest')














