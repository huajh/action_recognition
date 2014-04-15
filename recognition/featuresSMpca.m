% Dimensionality reduction for cuboids descriptors.
%
% Samples cuboids from all datasets, and uses this sample to get the pca coefficient for
% the descriptor (see imagedesc_getpca).  Should be run after features are detected (of
% course), and before descriptor is applied to all the cuboids.  This step is optional,
% but it is probably a good idea since otherwise descriptor can potentially have very
% large dimension.
%
% INPUTS
%   DATASETS    - array of structs, should have the fields:
%           .cuboids    - length N cell vector of sets of cuboids
%   cubdesc     - cuboid descriptor [see imagedesc_getpca]
%   kpca        - number of dimensions to reduce data to [see imagedesc_getpca]
%
% OUTPUTS
%   cubdec      - cuboid descriptor with pca info [see imagedesc_getpca]
%   cuboids     - sampled cuboids 
%
% See also FEATURESSM, PCA, IMAGEDESC_GETPCA

function [cubdesc,cuboids] = featuresSMpca( DATASETS, cubdesc, kpca )
    reqfs = {'cuboids'};
    if( ~isfield2( DATASETS, reqfs, 1) ) 
        ermsg=[]; for i=1:length(reqfs) ermsg=[ermsg reqfs{i} ', ']; end
        error( ['Each DATASET must have: ' ermsg 'initialized'] ); end;

    %%% sample cuboids from each dataset
    nsets = length(DATASETS);
    maxcub = round( 1200 / nsets );
    cuboids = cell(1,nsets);
    for i=1:nsets
        cuboidsi = cell2mat( DATASETS(i).cuboids );
        if( maxcub < size(cuboidsi,4) )
            rperm = randperm(size(cuboidsi,4));
            cuboidsi = cuboidsi(:,:,:,1:maxcub);
        end;
        cuboids{i} = cuboidsi;
    end;
    cuboids = cell2mat( permute(cuboids,[1 3 4 2]) ); 

    %%% getpca
    cubdesc = imagedesc_getpca( cuboids, cubdesc, kpca, 0 );
    
    