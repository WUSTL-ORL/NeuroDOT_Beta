%% Script for model generation given an initial mesh and optode set


meshname='';
gridname='Adult_96x92';
gridfiletype='ND2'; % 'ND1', 'ND2', 

%% Load initial mesh
mesh=load_mesh([meshname]);
pM.orientation='coord';pM.Cmap.P='gray';
PlotMeshSurface(mesh,pM)


%% Load initial grid file depending on data structure:

switch gridfiletype
    case 'ND2'  % Grid positions are in Pad file (NeuroDOT_2 format)
        load(['Pad_',gridname,'.mat']); % Pad file
        tpos=cat(1,info.optodes.spos3,info.optodes.dpos3);
        Ns=size(info.optodes.spos3,1);
        Nd=size(info.optodes.dpos3,1);
        rad=info;
        
    case 'ND1'  % Grid file contains 3D information
        grid=load(['grid',gridname,'.mat']);
        rad=load(['radius_',gridname,'.mat']);
        tpos=cat(1,grid.spos3,info.optodes.dpos3);
        Ns=size(grid.spos3,1);        
        Nd=size(grid.dpos3,1);        
        
end

PlotSD(tpos(1:Ns,:),tpos((Ns+1):end,:),'norm');


%% View cap position with and without mesh

PlotMeshSurface(mesh,pM);PlotSD(tpos(1:Ns,:),tpos((Ns+1):end,:),'norm',gcf);


%% Move grid from arbitrary location to approximate target on mesh

% Adjust parameters by hand, update position, check
tpos2=tpos;
dx=0;
dy=0;
dz=0;
dS=1.0;
dxTh=0;
dyTh=0;
dzTh=0;

tpos2=scale_cap(tpos2,dS);
tpos2=rotate_cap(tpos2,[dxTh,dyTh,dzTh]);
tpos2(:,1)=tpos2(:,1)+dx;
tpos2(:,2)=tpos2(:,2)+dy;
tpos2(:,3)=tpos2(:,3)+dz;

PlotMeshSurface(mesh,pM);PlotSD(tpos2(1:Ns,:),tpos2((Ns+1):end,:),'norm',gcf);


%% Relax grid on head
m0.nodes=mesh.nodes;
m0.elements=mesh.elements;
spos3=tpos2(1:Ns,:);
dpos3=tpos2((Ns+1):end,:);
tposNew=gridspringfit_ND2(m0,rad,spos3,dpos3);


%% PREPARE! --> mesh and grid in coord space
mesh=PrepareMeshForNIRFAST(mesh,[meshname,'_',gridname],tposNew);
PlotMeshSurface(mesh,pM);PlotSD(mesh.source.coord(1:Ns,:),...
    mesh.source.coord((Ns+1):end,:),'render',gcf);

% One last visualization check...
m3=CutMesh(mesh,find(mesh.nodes(:,3)>0));
[Ia,Ib]=ismember(m3.nodes,mesh.nodes,'rows');Ib(Ib==0)=[];
m3.region=mesh.region(Ib);
PlotMeshSurface(m3,pM);PlotSD(mesh.source.coord(1:Ns,:),...
    mesh.source.coord((1+Ns):end,:),'render',gcf);



%% Calculate Sensitivity Profile
% Parameters
flags.tag='';
flags.gridname=gridname;
flags.meshname=meshname;
flags.head='info';
flags.info=infoT1;                  % Your T1 info file
flags.gthresh=1e-3;                 % Voxelation threshold in G
flags.voxmm=1;                      % Voxelation resolution (mm)
flags.labels.r1='csf';             % Regions for optical properties
flags.labels.r2='white';
flags.labels.r3='gray';
flags.labels.r4='bone';
flags.labels.r5='skin';
flags.op.lambda=[685,830];          % Wavelengths (nm)
flags.op.mua_skin=[0.0170,0.0190];  % Baseline absorption
flags.op.mua_bone=[0.0116,0.0139];
flags.op.mua_csf=[0.0040,0.0040];
flags.op.mua_gray=[0.0180,0.0192];
flags.op.mua_white=[0.0167,0.0208];
flags.op.musp_skin=[0.74,0.64];     % Baseline reduced scattering coeff
flags.op.musp_bone=[0.94,0.84];
flags.op.musp_csf=[0.3,0.3];
flags.op.musp_gray=[0.8359,0.6726];
flags.op.musp_white=[1.1908,1.0107];
flags.op.n_skin=[1.4,1.4];          % Index of refration
flags.op.n_bone=[1.4,1.4];
flags.op.n_csf=[1.4,1.4];
flags.op.n_gray=[1.4,1.4];
flags.op.n_white=[1.4,1.4];
flags.srcnum=Ns;                    % Number of sources
flags.t4=[0.013773,-0.950527,-0.017870,1.1041;... % T1/dim to MNI atlas
 -0.047220,-0.093750, 0.868421,9.8222;...
 -0.881163,-0.036030,-0.061248,-2.3832;...
  0,0,0,1]; % t4 to atlas - label which
flags.t4_target='MNI'; % string
flags.makeA=1; % don't make A, just make G
flags.Hz=0;
if flags.Hz, flags.tag = [flags.tag,'FD']; end

Ti=tic;[A,dim]=makeAnirfast(mesh,flags); % size(A)= [Nwl, Nmeas, Nvox]
disp(['<makeAnirfast took ',num2str(toc(Ti))])



%% Visualize aspects of sensitivity profile
t1=affine3d_img(T1n,infoT1,dim,eye(4)); % put anatomical volume in dim space

keep=info.pairs.WL==1 & info.pairs.Src==1 & info.pairs.Det==1;
foo=squeeze(A(2,keep,:));              % Single meas pair
fooV=Good_Vox2vol(foo,dim);
fooV=fooV./max(fooV(:));
fooV=log10(1e2.*fooV);                  % top 2 o.o.m.
pA.PD=1;pA.Scale=2;pA.Th.P=0;pA.Th.N=-pA.Th.P;
PlotSlices(t1,dim,pA,fooV)

% FFR
keep=find(info.WL==1 & info.pairs.r2d<=40);
a=squeeze(A(2,keep,:));
iA=Tikhonov_invert_Amat(a,0.01,0.1);
iA=smooth_Amat(iA,dim,1);
ffr=makeFlatFieldRecon(a,iA);

fooV=Good_Vox2vol(ffr,dim);
fooV=fooV./max(fooV(:));
pA.PD=1;pA.Scale=1;pA.Th.P=1e-2;pA.Th.N=-pA.Th.P;
PlotSlices(t1,dim,pA,fooV)






