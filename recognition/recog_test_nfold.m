% Test the performance of behavior recognition using cross validation.
%
% Training occurs on all but (n-1) of the sets and testing on the remaining one, giving a
% total of (n) training/testing scenarios.  One simplification is used here: clustering is
% done only once, using all of the data.  When reporting final results, clustering needs
% to be done each time separately, as in recog_test.
%
% Parameters for clustering and classification can be specified inside this file.
%
% INPUTS
%   DATASETS    - array of structs, should have the fields:
%           .IDX        - length N vector of clip types
%           .desc       - length N cell vector of cuboid descriptors
%           .ncilps     - N: number of clips
%   k           - number of clusters
%   nreps       - number of repetitions
%   
% OUTPUTS
%   ER      - error  - averaged over nreps
%   CM      - confusion matrix - averaged over nreps
%
% See also RECOGNITION_DEMO, RECOG_TEST, NFOLDXVAL, RECOG_CLUSTER, RECOG_CLIPSDESC

function [ER,CM] = recog_test_nfold( DATASETS, k, nreps )
    % parameters
    csigma=0; clfinit = @clf_knn; clfparams = {1,@dist_chisquared};
    par_kmeans={'replicates',5,'minCsize',1,'display',0,'outlierfrac',0 };

    nsets = length( DATASETS );
    nclasses = max( DATASETS(1).IDX );
    CMS = zeros(nclasses,nclasses,nreps);
    ticstatusid = ticstatus('recog_test;',[],10 ); cnt=1;
    for h=1:nreps
        clusters = recog_cluster( DATASETS, k, par_kmeans );
        data = recog_clipsdesc( DATASETS, clusters, csigma );
        IDX = {DATASETS.IDX};
        CMS(:,:,h) = nfoldxval( data, IDX, clfinit, clfparams );
    end;
    CM = mean(CMS,3);
    ER = 1- sum(diag(CM))/sum(CM(:));