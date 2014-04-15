
% Feature detection and description applied to .mat behavior data. 
%
% See RECOGNITION_DEMO / FEATURESSM for general steps of detection / description and
% differences between this function and FEATURESSM.
% 
% INPUTS
%   nsets           - number of sets
%   cliptypes       - types of clips (cell of strings)
%   par_stfeatures  - parameters for feature detection [see featuresLGdetect]
%   cubdesc         - cuboid descriptor [see featuresLGdesc]
%   ncuboids        - number of cuboids to grab per .mat file [see featuresLGpca]
%   kpca            - number of dimensions to reduce data to [see featuresLGpca]
%
% OUTUPTS
%   DATASETS    - array of structs, will have fields:
%           .IDX        - length N vector of clip types
%           .ncilps     - N: number of clips
%           .cubcount   - length N vector of cuboids counts for each clip clip
%           .subs       - length N cell vector of sets of locations of cuboids
%           .desc       - length N cell vector of cuboid descriptors
%   cubdesc         - output of featuresLGpca
%   cuboids         - output of featuresLGpca
%   
% See also FEATURESLGDETECT, FEATURESLGPCA, FEATURESLGDESC, FEATURESLGCONV

function [DATASETS,cubdesc,cuboids] = featuresLG( nsets, cliptypes, ... 
                                par_stfeatures, ncuboids, cubdesc, kpca )
    
    % Detects features for each set of cuboids using stfeatures
    % Load data from clip_*.mat (I, clipname, cliptype)
    % for every video(or clip images)                  
    %    stfeatures(clip_images) 
    %       1. shrink images;
    %       2. range [-1,1]
    %       3. feature extraction 
    %           strength response at each loc = periodic (I, sigma, tau)
    %           or harris
    %       4. subs(subscripts), vals = nonmaximal suppression 
    %       5. extract cuboids:     
    %           cuboids (pixel x pixels x deepth x size) <= (I,subs,..)    
    %       output: subs, cuboids     
    % save result into cuboids_[activity].mat (clipname,cliptype, cuboids, subs)
    %  
    featuresLGdetect( nsets, cliptypes, par_stfeatures  );
    %
    % Dimensionality reduction for cuboids descriptors.
    %
    % Load data from cuboids_*.mat
    %   convert proper format of cuboids, at most (n <= ncuboids) cuboids.
    %   random sample the cuboids, at most (n <= k*30) number
    %
    % get descriptors = imagedesc()
    %   % 1. Patch descriptor based on histogrammed gradient [Lowe's SIFT descriptor].: descpatch_GRAD()     
    %         create gradient images : gauss_smooth (sigma)
    %         converts descriptor in array format to vector or histogram. imagedesc_ch2desc(GS)
    %         Creates a series of locally position dependent histograms: 
    %               desc ( 1 x p [feature]) = histc_sift() / histc_sift_nD() 
    %               Inspired by David Lowe's SIFT descriptor.  Takes I, divides it into a number of regions,
    %               and creates a histogram for each region.
    %    2. optionally jitters    
    %    return   desc   - nxpxr array of n p-dimensional descriptors, r jittered versions of each
    %
    %ingore jitter
    %
    % running [ U, mu, variances ] = pca( desc vector)  %  thresh = 00000001^2
    %           U: principal component,
    %           variance: sorted eigenvalues
    %
    %@return cubdesc (   + .par_pca   ), cuboids
    %
    [cubdesc,cuboids]  = featuresLGpca( nsets, ncuboids, cubdesc, kpca );
    %
    % Applies descriptor to every cuboid of every clip of every set.
    % Load data from cuboids_*.mat
    %    desc
    %    apply_pca using par_pca
    % save feature to features_*.mat (clipname, cliptype, subs,desc)
    featuresLGdesc( nsets, cubdesc ); 
    %
    % convert to DATASETS format
    % Load data from features_*.mat
    % convert DATASETS:  2* (48*(IDX, cubcount, subs (319* x 3),desc (319* x 100))
    %
    DATASETS = featuresLGconv( nsets, cliptypes );
    