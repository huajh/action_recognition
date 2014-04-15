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

function [ER,CM] = recog_vote_test( DATASETS, ncodebook, nreps )
    % parameters
    % clf_knn clf_svm
    csigma=0; 
    par_kmeans={'replicates',5,'minCsize',1,'display',0,'outlierfrac',0 };
    nsets = length( DATASETS );
    nclasses = max( DATASETS(1).IDX );
    ERS = zeros(1,nreps);
    CMS = zeros(nclasses,nclasses,nreps);
    
    ticstatusid = ticstatus('recog_test3;',[],10 ); cnt=1;    
    for h=1:nreps
        for i=1:nsets 
            % leave-one-out
            idx = [1:i-1,i+1:nsets];
            trainDATESETS = DATASETS(idx);            
            [CodeProb,CodeIDX,Clusters_Centers] = CreateCodeBook(DATASETS,ncodebook,nclasses);
            IDXpred = [];
            for j=1:DATASETS(i).nclips
                assigned_clust = imagedesc2clusters( DATASETS(i).desc{j}, Clusters_Centers, csigma );                
                action_ix = CodeIDX(assigned_clust');                
                [~,ACTION_TYPE] = max(histc(action_ix,1:nclasses));                
                IDXpred = [IDXpred;ACTION_TYPE];
            end                        
            cm = confmatrix( DATASETS(i).IDX, IDXpred, nclasses);
            e = 1- sum(diag(cm))/sum(cm(:));            
            ERS(h)=ERS(h) + e;  CMS(:,:,h)=CMS(:,:,h) + cm;                
            tocstatus( ticstatusid, cnt/(nsets*nreps) ); cnt=cnt+1;
        end;
    end;
    CM = mean(CMS,3);
    ER = mean(ERS);
    correct = 1-ER/nsets

