% Feature detection and description applied to DATASETS behavior data. 
%
% 1) First, detect features for every clip in every dataset. This leads to a large
% reduction in the size of the dataset (the original clips are discarded). 
%    DATASETS = featuresSMdetect( DATASETS, par_stfeatures );
%
% 2) Next create a descriptor, and call featuresSMpca for dimensionality reduction: 
%    cubdesc = imagedesc_generate( 1, ... ); %with proper parameters
%    cubdesc = featuresSMpca( DATASETS, cubdesc, kpca );
%
% 3) Apply the descriptor to cuboids, again leading to a reduction of size of dataset:
%    DATASETS = featuresSMdesc( DATASETS, cubdesc );
%
% See RECOGNITION_DEMO / FEATURESLG for general steps of detection / description and
% differences between this function and FEATURESLG.
%
% INPUTS
%   DATASETS    - array of structs, should have the fields:
%           .IS         - the N behavior clips
%           .IDX        - length N vector of clip types
%   par_stfeatures  - parameters for feature detection [see featuresSMdetect]
%   cubdesc         - cuboid descriptor [see featuresSMdesc]
%   kpca            - number of dimensions to reduce data to [see featuresSMpca]
%
% OUTUPTS
%   DATASETS    - array of structs, will have additional fields:
%           .IDX        - length N vector of clip types
%           .ncilps     - N: number of clips
%           .cubcount   - length N vector of cuboids counts for each clip clip
%           .cuboids    - length N cell vector of sets of cuboids
%           .subs       - length N cell vector of sets of locations of cuboids
%           .desc        - length N cell vector of cuboid descriptors
%   cubdesc         - output of featuresSMpca
%   cuboids         - output of featuresSMpca
%   
% See also FEATURESSMDETECT, FEATURESSMPCA, FEATURESSMDESC, FEATURESLG

function [DATASETS,cubdesc,cuboids] = featuresSM( DATASETS, par_stfeatures, cubdesc, kpca)
    DATASETS = featuresSMdetect( DATASETS, par_stfeatures );
    [cubdesc,cuboids]  = featuresSMpca( DATASETS, cubdesc, kpca );
    DATASETS = featuresSMdesc( DATASETS, cubdesc );

    
    
