function [b,e,DM,EDM]=GLM_181206(data,hrf,info,params)
%
% This code creates a general linear model (GLM) based on a model of the
% hemodynamic response function (hrf) and a set of stimulus times 
% (info.paradigm.synchpts). 
% The GLM is then applied to the data to generate Beta maps and residuals.
% It is assumed that the data is [voxels X time].
% The hrf is a modelled hemodynamic response.


%*** Set up options
% filtering
% use info.GVTD_filt_rs time trace as regressor
% use info.GVTD_filt_rs time trace with threshold to mask noisy time points
%
% params.events can be passed in to choose a set of info.paradigm.Pulse_X
% event types for which the GLM will include before inverting. For example,
% if there are 10 different pulses types (info.paradigm.Pulse_1 through
% info.paradigm.Pulse_10 are present), but the user only wants to consider
% Pulses 2, 3, 5, 6, and 8, then set params.events=[2,3,5,6,8];

% Type may be 'events' (default) to collapse across trials for each event
% type.
% GVTD can be set to 1 or 0 to use (or not use) GVTD noise as a nuissance
% covariate.
% The info structure contains the event types and times.
% b is the beta map
% e is the residual
% DM is the design matrix (time X events)


%% Set up parameters
Nt=size(data,2);
if ~exist('params','var'),params=struct;end
if ~isfield(params,'type'),params.type='events';end
if ~isfield(params,'GVTDreg'),params.GVTDreg=0;end
if ~isfield(params,'Nuisance_Reg'),params.Nuisance_Reg=0;end
if ~isfield(params,'Nuisance_Regs'),params.Nuisance_Regs=[];end
if ~isfield(params,'GVTD_censor'),params.GVTD_censor=0;end
if ~isfield(params,'GVTD_censor_post_win'),params.GVTD_censor_post_win=0;end
if ~isfield(params,'GVTD_censor_pre_win'),params.GVTD_censor_pre_win=0;end
if ~isfield(params,'GVTD_th'),params.GVTD_th=1e-3;end
if ~isfield(params,'DoFilter'),params.DoFilter=0;end
if isfield(params,'event_length'), EL=params.event_length;else EL=0;end
if ~isfield(info,'flags')
    info.flags=struct;
end
Nevents=length(info.paradigm.synchpts);
if isfield(params,'events')
    events=unique(params.events);
    NuniqueEvents=length(events);
else
    NuniqueEvents=length(unique(info.paradigm.synchtype));
    events=1:NuniqueEvents;
end

if params.DoFilter
    if isfield(params,'omega_hp')           % high pass filter cutoff
        omega_hp=params.omega_hp;
    elseif isfield(info.flags,'omega_hp')
        omega_hp=info.flags.omega_hp;
    else
        omega_hp=0.02;
    end
    
    if isfield(params,'omega_lp')           % low pass filter cutoff
        omega_lp=params.omega_lp;
    elseif isfield(info.flags,'omega_lp')
        omega_lp=info.flags.omega_lp;
    elseif isfield(info.flags,'lowpass3')
        if info.flags.lowpass3
            omega_lp=info.flags.omega_lp3;
        end
    elseif isfield(info.flags,'lowpass2')
        if info.flags.lowpass2
            omega_lp=info.flags.omega_lp2;
        end
    elseif isfield(info.flags,'lowpass1')
        if info.flags.lowpass1
            omega_lp=info.flags.omega_lp1;
        end
    else
        omega_lp=0.5;                       % high pass filter cutoff
    end
    
    if isfield(info,'system')               % framerate of data
        if isfield(info.system,'framerate')
            fr=info.system.framerate;
        end
    elseif isfield(info,'framerate')
        fr=info.framerate;
    else
        fr=1;
    end
    
    if omega_lp>(fr/2)                      % fix if above Nyquist
        omega_lp=fr/2;
    end
    if omega_lp==(fr/2)                     % fix if at Nyquist
        omega_lp=omega_lp.*0.95;
    end
end

if isfield(info,'GVTD_filt_rs')
    GVTD=info.GVTD_filt_rs;
elseif isfield(info,'misc')
    if isfield(info.misc,'GVTD_filt_rs')
    GVTD=info.misc.GVTD_filt_rs;
    end
elseif isfield(params,'GVTD')
    GVTD=params.GVTD;
end


%% Set up Experimental Design matrix
EDM=zeros(Nt,Nevents);
for j=1:(Nevents-1)
    if EL
        if (info.paradigm.synchpts(j)+EL-1)<Nt
        EDM(info.paradigm.synchpts(j):(info.paradigm.synchpts(j)+EL-1),j)=1;
        else
        EDM(info.paradigm.synchpts(j):Nt,j)=1;            
        end
    else
    EDM(info.paradigm.synchpts(j):(info.paradigm.synchpts(j+1)-1),j)=1;
    end
end
EDM(info.paradigm.synchpts(end):end,Nevents)=1;

if strcmp(params.type,'events')
    EDMu=zeros(Nt,NuniqueEvents);
    for j=1:NuniqueEvents
        EDMu(:,j)=sum(EDM(:,info.paradigm.(['Pulse_',num2str(events(j))])),2);
    end
    EDM=EDMu;
end


%% Convolve Event design matrix with HDR
DM=conv2(EDM,hrf(:));
DM=DM(1:Nt,:);


%% Add other 'nuissance' terms here if you like
if params.GVTDreg
    DM=cat(2,DM,GVTD(:));
end
if params.Nuisance_Reg
    DM=cat(2,DM,params.Nuisance_Regs);    
end


%% Standardize  
DM=zscore(DM,[],1);


%% Filter
if params.DoFilter
    DM=detrend_tts(DM')';
    DM = highpass(DM', omega_hp, fr)';
    DM = lowpass(DM', omega_lp, fr)';
end


%% Add constant term
DM=cat(2,ones(Nt,1),DM);


%% Remove noisy timepoints
if params.GVTD_censor
    keep=GVTD<params.GVTD_th;
    if params.GVTD_censor_pre_win
        keep0=keep;
        n=params.GVTD_censor_pre_win;
        while n~=0
            keep=(keep.*circshift(keep0,-n))==1;
            n=n-1;
        end
    end
    if params.GVTD_censor_post_win
        keep0=keep;
        n=params.GVTD_censor_post_win;
        while n~=0
            keep=(keep.*circshift(keep0,n))==1;
            n=n-1;
        end
    end
    
    figure;
    DMscale=max(DM(:))-min(DM(:));
    subplot(2,2,[1,3]);
    imagesc(cat(2,DM,(keep(:)-0.5).*DMscale));colormap('gray');
    set(gca,'XTick',size(DM,2)+1,'XTickLabels',{'keep'})
    subplot(2,2,2);plot([1:Nt],GVTD,'k');hold on
    plot([1,Nt],ones(1,2).*params.GVTD_th,'r')
    xlim([1,Nt]);ylabel('GVTD');xlabel('time')
    DrawColoredSynchPoints(info,1);
    subplot(2,2,4);histogram(GVTD(:),100);hold on
    yLim=get(gca,'YLim');
    plot(ones(1,2).*params.GVTD_th,[0,yLim(2)],'r')
    
    DM=DM(keep,:);
    data=data(:,keep);
end


%% Calculate beta map and residuals
indcc=pinv(DM'*DM);
b=(indcc*DM'*data')';
e=(data'-DM*b')';