% Detects features for each set of cuboids using stfeatures.
%
% INPUTS
%   DATASETS    - struct array contains all behavior data in dataset, should have fields:
%           .IS         - the N behavior clips
%           .IDX        - length N vector of clip types
%   par_stfeatures - parameters for feature detection, see stfeatures
%
% OUTPUTS
%   DATASETS    - array of structs, will have additional fields [IS will be removed]:
%           .ncilps     - N: number of clips
%           .cubcount   - length N vector of cuboids counts for each clip clip
%           .cuboids    - length N cell vector of sets of cuboids
%           .subs       - length N cell vector of sets of locations of cuboids
%
%
% See also FEATURESSM, STFEATURES 

function DATASETS = featuresSMdetect( DATASETS, par_stfeatures )
    reqfs = {'IS','IDX'};
    if( ~isfield2( DATASETS, reqfs, 1) ) 
        ermsg=[]; for i=1:length(reqfs) ermsg=[ermsg reqfs{i} ', ']; end
        error( ['Each DATASET must have: ' ermsg 'initialized'] ); end;
    
    %%% get number of clips of each type (nclips)
    nsets = length(DATASETS);
    for i=1:nsets
        IS = DATASETS(i).IS;
        DATASETS(i).nclips = length(DATASETS(i).IDX);
        if(iscell(IS))  nclips=numel(IS);  else  nclips=size(IS,4);  end;
        if(nclips~=DATASETS(i).nclips)
            error( 'Number of IDXs does not correspond to number of IS' ); end;
    end;
    
    %%% detect cuboids
    nclips = cell2mat({DATASETS.nclips});
    nclipsall = sum(nclips);  cnt=1;
    ticstatusid = ticstatus('featuresSM: detecting cuboids;',[],10 ); 
    for i=1:nsets
        IS = DATASETS(i).IS;  DATASETS(i).IS=[];
        cuboids = cell(1,nclips(i));  
        subs = cell(1,nclips(i));
        cubcount = zeros(1,nclips(i));
        for j=1:nclips(i)  % detect cuboids for each I of IS
            if(iscell(IS)) I=IS{j}; else I=IS(:,:,:,j); end;
                I=padarray(I,[5 5 15],'both','replicate'); %small/short clips, pad!
            [d,subs{j},d,cuboids{j}] = stfeatures(I,par_stfeatures{:} ); 
            cubcount(j) = size(cuboids{j},4);
            tocstatus( ticstatusid, cnt/nclipsall ); cnt=cnt+1;
        end;
        cuboids=permute(cuboids,[1 3 4 2]); % can now convert to array using cell2mat
        DATASETS(i).cuboids = cuboids;
        DATASETS(i).subs = subs;
        DATASETS(i).cubcount = cubcount;
    end;
        
    %%% discard IS for memory consideration
    DATASETS = rmfield(DATASETS,'IS');
        
    
    