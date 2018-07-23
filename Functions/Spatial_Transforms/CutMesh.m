function mesh2=CutMesh(mesh1,kill)

% This function removes a set of nodes (kill) from mesh1, adjusts the
% elements, and outputs the new mesh in mesh2.

disp(['Removing ',num2str(length(kill)),' of ',...
    num2str(size(mesh1.nodes,1)),' nodes from mesh'])

%% Remove kill nodes 
keep=setdiff([1:size(mesh1.nodes,1)],kill);


%% Determine which elements are holding these nodes together
tf=ismember(mesh1.elements,keep);
tf=sum(tf,2)==4; % find complete tetrahedra
mesh2.elements=mesh1.elements(tf,:);


%% Remove disconnected nodes
idx = unique(mesh2.elements(:)); 
keep2=intersect(keep,idx);


%% Place nodes in new mesh
mesh2.nodes=mesh1.nodes(keep2,:); % Things looks cool here.


%% Fix numbering of nodes referenced in elements array
keepIdx=1:length(keep2);
[junk,Locb]=ismember(mesh2.elements,keep2);
mesh2.elements=reshape(keepIdx(Locb),size(mesh2.elements));


%% Keep only largest contiguous mesh nodes and elements

% Generate surface mesh(es)
TR = TriRep(mesh2.elements,mesh2.nodes);
[elemb,nodesb] = freeBoundary(TR);
groupID=connectivityTri(elemb);

Ug=unique(groupID);
Ng=length(Ug);

disp([num2str(Ng),' islands found. Isolating largest node set.'])

if Ng>1 % Find nodes that are connected to surface nodes of largest set
    Sg=zeros(Ng,1);
    for j=1:Ng
        Sg(j)=sum(groupID==Ug(j));
    end
    
    % Find unique nodes on surface of largest island
    [junk,Gidx]=max(Sg);
    Unodesb=unique(elemb(groupID==Gidx,:)); 
    
    % IbX are unique nodes in largest volume
    [junk,keep3]=ismember(nodesb(Unodesb,:),mesh2.nodes,'rows');
    
    % Find network-connected nodes
    go=1;
    while go==1
        tf=sum(ismember(mesh2.elements,keep3),2)>0;
        I0=length(keep3);
        keep3=unique(union(keep3,unique(mesh2.elements(tf,:))));
        if ((length(keep3)-I0)==0), go=0;end
    end
    kill2=setdiff([1:size(mesh2.nodes,1)],keep3);
    
    % Remove nodes not in largest volume
    if ~isempty(kill2)
        mesh2=CutMesh(mesh2,kill2);
    end
end




