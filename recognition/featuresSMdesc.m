% Applies descriptor to every cuboid of every clip of every set.
%
% INPUTS
%   DATASETS    - array of structs, should have the fields:
%           .ncilps     - N: number of clips
%           .cuboids    - length N cell vector of sets of cuboids
%   cubdesc     - cuboid descriptor
%
% OUTPUTS
%   DATASETS    - array of structs, will have additional fields:
%           .desc       - length N cell vector of cuboid descriptors
%
% See also FEATURESSM, IMAGEDESC, IMAGEDESC_GENERATE

function DATASETS = featuresSMdesc( DATASETS, cubdesc )
    reqfs = {'nclips','cuboids'};
    if( ~isfield2( DATASETS, reqfs, 1) ) 
        ermsg=[]; for i=1:length(reqfs) ermsg=[ermsg reqfs{i} ', ']; end
        error( ['Each DATASET must have: ' ermsg 'initialized'] ); end;

    
    %%% apply descriptor to cuboids
    nsets = length(DATASETS);
    nclips = cell2mat({DATASETS.nclips});
    nclipsall = sum(nclips);  cnt=1;
    ticstatusid = ticstatus('featuresSM: describing cuboids;',[],10 ); 
    for i=1:nsets
        cuboids = DATASETS(i).cuboids;
        desc = cell(nclips(i),1);  
        for j=1:nclips(i)  % describe cuboids for each I of IS
            desc{j} = imagedesc( cuboids{j}, cubdesc ); 
            tocstatus( ticstatusid, cnt/nclipsall ); cnt=cnt+1;
        end;
        DATASETS(i).desc = desc;
    end;


