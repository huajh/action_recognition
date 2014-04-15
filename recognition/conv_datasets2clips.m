% Converts between representations of behavior (DATASETS -> mat).
%
% See RECOGNITION_DEMO for general info.
%   DATASETS --> [datadir(set_ind)/namei.mat]
%
% INPUTS
%   DATASETS    - struct array contains all behavior data in dataset, should have fields:
%           .IS         - the N behavior clips
%           .IDX        - length N vector of clip types
%   cliptypes       - types of clips (cell of strings)
%
% See also RECOGNITION_DEMO, CONV_MOVIES2CLIPS, CONV_CLIPS2DATASETS

function conv_datasets2clips( DATASETS, cliptypes )
    reqfs = {'IS','IDX'};
    if( ~isfield2( DATASETS, reqfs, 1) ) 
        ermsg=[]; for i=1:length(reqfs) ermsg=[ermsg reqfs{i} ', ']; end
        error( ['Each DATASET must have: ' ermsg 'initialized'] ); end;

    ntypes = length( cliptypes );
    for s=0:(length( DATASETS )-1)
        srcdir = datadir(s);
        if(~exist(srcdir,'dir')) mkdir( srcdir ); end;
        nclips = length( DATASETS(s+1).IDX );
        counts = zeros( ntypes, 1 );
        for c=1:nclips
            type = DATASETS(s+1).IDX(c);
            clipname = [cliptypes{type} int2str2(counts(type),3)];
            cliptype = clipname(1:end-3);
            counts(type) = counts(type) + 1;
            I = DATASETS(s+1).IS(:,:,:,c);
            save( [srcdir '\clip_' clipname '.mat'], 'I', 'clipname','cliptype' );
        end;
    end;

