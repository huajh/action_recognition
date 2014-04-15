%
%   @author: Junhao Hua
%   @Contant: huajh7@gmail.com
%
%   2014/3/31
%   Latest update: 2014/4/8
%
%Reference:
%   Doll¨¢r, Piotr, et al. "Behavior recognition via sparse spatio-temporal features." 
%   Visual Surveillance and Performance Evaluation of Tracking and Surveillance, 
%   2005. 2nd Joint IEEE International Workshop on. IEEE, 2005.
%
%   Niebles, Juan Carlos, Hongcheng Wang, and Li Fei-Fei. 
%   "Unsupervised learning of human action categories using spatial-temporal words." 
%   International journal of computer vision 79.3 (2008): 299-318.
%

ccc;
close all;

addpath('../descriptors');
addpath('../stfeatures');
addpath('../my_svm');

cliptypes = { 'bend','jack','jump','pjump','run','side','skip','walk','wave1','wave2' };
%cliptypes = {'walking','jogging','running','boxing','handwaving','handclapping'};

is_Feature_extract    = 0 ;
is_Action_knn_Classif = 0 ;
is_Action_svm_Classif = 0 ;
isCreateCodeBook      = 0 ;
is_SingleAction_train = 0 ;
is_SingleAction_Recog = 0 ;
is_vote_Action_Recog  = 0;
is_vote_recog_test    = 1 ;

%% Feature Extraction
if (is_Feature_extract)
    
    nsets = 25;
    ncuboids = 20;
    % components size
    kpca  = 200;

    % parameters for cuboid descriptor
    % iscuboid, str_desc, histFLAG, jitterFLAG
    cubdesc = imagedesc_generate( 1, 'GRAD', -1 ); 
    
    %sigma, tau, periodic, thresh, maxn, overlap_r, shr_spt, shr_tmp, show 
    par_stfeatures = {2, 2.5, 1, 2e-4, 300, 1.85, 1, 1, 0};
    
%    for i=0:(nsets-1)
%         conv_movies2clips( i );
%    end;
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
	%featuresLGdetect( nsets, cliptypes, par_stfeatures );

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
    savefields = {'DATASETS', 'cubdesc', 'cuboids', 'cliptypes'};
    save( [datadir() '/DATASETSprLG.mat'], savefields{:} );	
end;

%%
if (is_SingleAction_train)    
    TrainDataObj = load([datadir() '/DATASETSprLG.mat']);  
    csigma=0; 
    k = 20;    
    par_kmeans={'replicates',5,'minCsize',1,'display',0,'outlierfrac',0 };
    DATASETS = TrainDataObj.DATASETS;
    Cluster_centers = recog_cluster( DATASETS, k, par_kmeans );
    data = recog_clipsdesc( DATASETS, Cluster_centers, csigma );
    IDXs = {DATASETS.IDX};
    trainX = cell2mat(data');
    trainIDX = cell2mat(IDXs');
    save([datadir() '/Training_Hist.mat'],'trainX','trainIDX','Cluster_centers');    
end
%% test for single action using simple KNN or SVM

if (is_SingleAction_Recog)                     
    %test
        % shahar_bend lena_jack lena_pjump lyova_run ido_side shahar_skip
    % denis_walk daria_wave1 daria_wave2
    clipname = 'person03_handwaving_d3_uncomp';
    
    %par_stfeatures = {1.2, 1.2, 1, 2e-4, 250, 1.85, 1, 1, 0};
    par_stfeatures = {2, 2.5, 1, 2e-4, 300, 1.85, 1, 1, 0};
    is_extract = 0;
    if (is_extract)
        TrainDataObj = load([datadir() '/DATASETSprLG.mat'],'cubdesc');        
        Mobj = VideoReader( [TestDir() '/' clipname '.avi']);
        I = movie2images(Mobj);
        save( [TestDir() '\clip_' clipname '.mat'], 'I','clipname');        
        I=padarray(I,[5 5 15],'both','replicate'); %small/short clips, pad!        
        [~,subs,~,cuboids] = stfeatures( I,par_stfeatures{:}); 
        destname = [TestDir() '\cuboids_' clipname];
        save( destname, 'clipname', 'cuboids', 'subs' );
        
        desc = imagedesc( cuboids, TrainDataObj.cubdesc );
        destname = [TestDir() '\features_' clipname];
        save( destname, 'clipname', 'subs', 'desc' );        
    else
        featureObj = load( [TestDir() '\features_' clipname '.mat'] );
        desc = featureObj.desc;
    end
    
    
    HistObj = load([datadir() '/Training_Hist.mat']); 
    % feature size
    k = size(HistObj.trainX,2);
    desclust = imagedesc2clusters (desc, HistObj.Cluster_centers, 0);
    Xtest = recog_clipdesc( desclust, k);
    [ntrain,p] = size(HistObj.trainX);
    
    is_knn =1;
    if (is_knn)
        clfinit = @clf_knn; clfparams = {1,@dist_chisquared};                   
        net = feval( clfinit, p, clfparams{:} );
        net = feval( net.fun_train, net, HistObj.trainX, HistObj.trainIDX );
        IDXpred = feval( net.fun_fwd, net, Xtest);
    else
        % use svm classifier 
        ker_func = 'linear'; % chisquared
        [ svmclass ] = mymultisvmtrain( HistObj.trainX,HistObj.trainIDX,ker_func );
        [ IDXpred ] = mymultisvmclassify( svmclass, Xtest );
        
    end
    % single action display

    Single_action_display(clipname,IDXpred,cliptypes, par_stfeatures{1:2});  
end


if (is_Action_knn_Classif)
  %%  Action Classification
    load([datadir() '/DATASETSprLG.mat']);
    nreps = 1;
    nclusters = 50;
	[ER,CMS] = recog_knn_test( DATASETS, nclusters, nreps );
	confmatrix_show( CMS(:,:,1), cliptypes );
end;

if (is_Action_svm_Classif)
    load([datadir() '/DATASETSprLG.mat']);
    nreps = 1;
    nclusters = 50;
	[ER,CMS] = recog_svm_test( DATASETS, nclusters, nreps );
	confmatrix_show( CMS(:,:,1), cliptypes );   
end

%% Create CodeBook using Training Samples
if (isCreateCodeBook)        
    
    TrainDataObj = load([datadir() '/DATASETSprLG.mat'], 'DATASETS');        
    ncodebook = 1000;
    nclasses = size(cliptypes,2);
    DATASETS = TrainDataObj.DATASETS;
    [CodeProb,CodeIDX,Clusters_Centers] = CreateCodeBook(DATASETS,ncodebook,nclasses);    
    save( [datadir() '/CODEBOOK.mat'],'CodeProb','CodeIDX','Clusters_Centers');
end

if (is_vote_Action_Recog)
%% Multi-Action Recogintion
    
    %sigma, tau, periodic, thresh, maxn, overlap_r, shr_spt, shr_tmp, show 
    %par_stfeatures = {1.2, 1.2, 1, 2e-4, 250, 1.85, 1, 1, 0};
    par_stfeatures = {2, 2.5, 1, 2e-4, 300, 1.85, 1, 1, 0};
    isExtract = 0;
    isAssgin =  0;
    isDisplay = 1;
    % Feature Extraction
    
    if (isExtract)
        cubdesc = imagedesc_generate( 1, 'GRAD', -1 );
        kpca = 100;
        Test_moives2clips();
        TestFeatureDetect(cliptypes, par_stfeatures);
        TrainDataObj = load([datadir() '/DATASETSprLG.mat'], 'cubdesc');    
        TestFeaturePCA(TrainDataObj.cubdesc); 
        %TestFeaturePCA2(cubdesc,kpca);
    end
    
    % Assgin Topic
    
    if (isAssgin)
        CodeBookObj = load([datadir() '/CODEBOOK.mat']);
        CodeProb = CodeBookObj.CodeProb;
        CodeIDX  = CodeBookObj.CodeIDX;
        Clusters_Centers = CodeBookObj.Clusters_Centers;
        AssginTopics(CodeProb, CodeIDX, Clusters_Centers);
    end
    %Display Moive    
    
    if (isDisplay)  
        % shahar_bend lena_jack lena_pjump lyova_run ido_side shahar_skip
        % denis_walk daria_wave1 moshe_wave2
        
        %good  original_view_00 
        %soso: original_view_05
        %bad:  original_skirt original_normwalk
        
        % mine
        
        % other :
        %   person15_jogging_d1_uncomp  person15_walking_d1_uncomp
        %   person15_handwaving_d1_uncomp
        %   person01_jogging_d1_uncomp
        %   person01_walking_d4_uncomp
        
        % IMG_0163 IMG_0165 IMG_0168 IMG_0171
        % bad    IMG_0165
        % soso IMG_0168  IMG_0166
        % good 
         clipname = 'IMG_0163';      
         Multi_action_display(clipname,cliptypes,par_stfeatures{1:2});
    end    
end

if is_vote_recog_test
    load([datadir() '/DATASETSprLG.mat']);
    nreps = 1;
    ncodebook = 1000;
    [ER,CMS] = recog_vote_test( DATASETS, ncodebook, nreps );
	confmatrix_show( CMS(:,:), cliptypes );
end

