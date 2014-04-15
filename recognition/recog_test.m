% Test the performance of behavior recognition using the cuboid representation.
%
% Given n sets of data, each containing multiple data instances, we train on 1 set at a
% time, and then test on each of the remaining sets.  Thus there are (n x n) separate
% training/testing scenarios. [Note: to get performance on set i given training on i we
% use cross validation WITHIN the set].   Note that this is not cross validation where
% training occurs on all but (n-1) of the sets and testing on the remaining one, giving a
% total of (n) training/testing scenarios.  
%
% Clustering is performed (using recog_cluster) on cuboids from the single training set.
% Once the clustering is obtained, each cuboid in all the clips in all the sets is
% assigned a type and each clip is converted to a histogram of cuboid types (using
% recog_clipsdesc).  Afterwards standard classification techniques are used to train/test.
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
%   ER      - error matricies [nsets x nsets] - averaged over nreps
%   CMS     - confusion matricies [nclass x nclass x nsets x nsets] - averaged over nreps
%
% See also RECOGNITION_DEMO, RECOG_TEST_NFOLD, NFOLDXVAL, RECOG_CLUSTER, RECOG_CLIPSDESC

function [ER,CMS] = recog_test( DATASETS, k, nreps )
    % parameters
    csigma=0; clfinit = @clf_knn; clfparams = {1,@dist_chisquared};
    par_kmeans={'replicates',5,'minCsize',1,'display',0,'outlierfrac',0 };

    nsets = length( DATASETS );
    nclasses = max( DATASETS(1).IDX );
    ER = zeros(nsets,nsets,nreps);
    CMS = zeros(nclasses,nclasses,nsets,nsets,nreps);
    ticstatusid = ticstatus('recog_test;',[],10 ); cnt=1;
    for h=1:nreps
        for i=1:nsets 
            clusters = recog_cluster( DATASETS(i), k, par_kmeans );
            data = recog_clipsdesc( DATASETS, clusters, csigma );
            IDXs = {DATASETS.IDX};
            for j=1:nsets 
                if( i==j )
                    [e,cm]=recog_test1( data{i}, IDXs{i}, clfinit, clfparams );
                else
                    [e,cm]=recog_test2( data{i}, IDXs{i}, data{j}, IDXs{j}, ... 
                                               clfinit, clfparams );
                end;
                ER(i,j,h)=e;  CMS(:,:,i,j,h)=cm;
            end;
            tocstatus( ticstatusid, cnt/(nsets*nreps) ); cnt=cnt+1;
        end;
    end;
    CMS = mean(CMS,5);
    ER = mean(ER,3);
    

%%% perform nfoldxval for every clip in dataset
function [e,cm] = recog_test1( X, IDX, clfinit, clfparams )
    [nclips,p] = size(X); nclasses=max(IDX);
    IDXcell = mat2cell(IDX,ones(1,nclips),1);  
    data = mat2cell(X,ones(1,nclips),p);
    data={data{:}}; IDXcell={IDXcell{:}};
    cm = nfoldxval( data, IDXcell, clfinit, clfparams,[],[],[],1 );
    e = 1- sum(diag(cm))/sum(cm(:));

%%% train on 1 dataset, test on other
function [er,cm] = recog_test2( Xtrain, IDXtrain, Xtest, IDXtest, clfinit, clfparams )
    [ntrain,p] = size(Xtrain); 
    net = feval( clfinit, p, clfparams{:} );
    net = feval( net.fun_train, net, Xtrain, IDXtrain );
    IDXpred = feval( net.fun_fwd, net, Xtest );
    cm = confmatrix( IDXtest, IDXpred, max(IDXtrain) );
    er = 1- sum(diag(cm))/sum(cm(:));
