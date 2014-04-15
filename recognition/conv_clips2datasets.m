% Converts between representations of behavior (mat -> DATASETS).
%
% See RECOGNITION_DEMO for general info.
%   [datadir(set_ind)/namei.mat] --> DATASETS
%
% INPUTS
%   nsets       - number of sets
%   cliptypes       - types of clips (cell of strings)
%
% OUTPUTS
%   DATASETS    - array of structs, will have fields:
%           .IS         - the N behavior clips 
%           .IDX        - length N vector of clip types
%
% See also RECOGNITION_DEMO, CONV_DATASETS2CLIPS

function DATASETS = conv_clips2datasets( nsets, cliptypes )
    matcontents = {'I','clipname'};
    for s=0:(nsets-1)
        srcdir = datadir(s);
        X = feval_mats( @clips2datasets1, matcontents, {}, srcdir, 'clip' );
        clipnames = {X.clipname};
        IS = cell2array( {X.I} );
        [disc, IDX] = ismember(clipnames, cliptypes);
        IDX = uint8(IDX)';
        DATASETS(s+1).IS = IS;
        DATASETS(s+1).IDX = IDX;
    end;

function x = clips2datasets1( vals, params ) 
    [I,clipname] = deal( vals{:} );
    x.clipname = clipname(1:end-3);
    x.I = I;

    
    
