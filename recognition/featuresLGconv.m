% Convert features to DATASETS format so output is same as after featuresSM.
%
% Loads each features_[activity].mat, for each clip in each set, and merges the results
% into DATASETS format. Does not try to add cuboids to the datasets as potentially this
% could take too much memory. 
%
% INPUTS
%   nsets           - number of sets
%   cliptypes       - types of clips (cell of strings)
%
% OUTPUTS
%   DATASETS    - array of structs, will have additional fields:
%           .IDX        - length N vector of clip types
%           .ncilps     - N: number of clips
%           .cubcount   - length N vector of cuboids counts for each clip clip
%           .subs       - length N cell vector of sets of locations of cuboids
%           .desc       - length N cell vector of cuboid descriptors
%
% See also FEATURESLG, FEATURESSM

function DATASETS = featuresLGconv( nsets, cliptypes )
    % convert to DATASETS format
    DATASETS = [];
    for s=0:(nsets-1)
        srcdir = datadir(s);
        matcontents = {'clipname','cliptype','desc','subs'}; 
        params = {srcdir, cliptypes};
        X = feval_mats( @featuresLGconv1, matcontents, params, srcdir, 'features' );
        nclips = length(X);
        for i=1:nclips
            DATASETS(s+1).IDX(i,1) = X(i).IDX;
            DATASETS(s+1).cubcount(i) = X(i).cubcount;
            DATASETS(s+1).subs{i} = X(i).subs;
            DATASETS(s+1).desc{i,1} = X(i).desc;
        end;
        DATASETS(s+1).nclips = nclips;
    end;

function x = featuresLGconv1( vals, params ) 
    [clipname, cliptype, desc, subs] = deal( vals{:} ); 
    [destdir, cliptypes] = deal( params{:} );
    [disc, IDX] = ismember(cliptype, cliptypes);
    x.IDX = uint8(IDX);
    x.subs = subs;
    x.cubcount = size(subs,1);
    x.desc = desc;
    
    
    
    
    
        
        
    
    
    