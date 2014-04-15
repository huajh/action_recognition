function [ ER,CMS ] = recog_svm_test( DATASETS,k,nreps )
    % parameters
    % clf_knn clf_svm
    csigma=0;
    par_kmeans={'replicates',5,'minCsize',1,'display',0,'outlierfrac',0 };
    ker_func = 'rbf';% rbf,chisquared,linear,polynomial
    nsets = length( DATASETS );
    nclasses = max( DATASETS(1).IDX );
    ERS = zeros(1,nreps);
    CMS = zeros(nclasses,nclasses,nreps);           
            
    ticstatusid = ticstatus('recog_svm_test;',[],10 ); cnt=1;        
    for h=1:nreps
        for i=1:nsets 
            % leave-one-out
            idx = [1:i-1,i+1:nsets];
            IDXs = {DATASETS.IDX};
            clusters = recog_cluster( DATASETS(idx), k, par_kmeans );
            data = recog_clipsdesc( DATASETS, clusters, csigma );            
            trainX = cell2mat(data(idx)');
            trainIDX = double(cell2mat(IDXs(idx)'));            
            Xtest = data{i};
            IDXtest = double(IDXs{i});
            [ svmclass ] = mymultisvmtrain(trainX,trainIDX,ker_func );
            [ IDXpred ] = mymultisvmclassify( svmclass, Xtest );
%            model = svmtrain(trainIDX,trainX,'-t 3');
%            [IDXpred] = svmpredict(IDXtest,Xtest,model);            
            cm = confmatrix( IDXtest, IDXpred,nclasses);
            er = 1- sum(diag(cm))/sum(cm(:));
            ERS(1,h)=ERS(1,h) + er;  CMS(:,:,h)=CMS(:,:,h) + cm;             
            tocstatus( ticstatusid, cnt/(nsets*nreps) ); cnt=cnt+1;
        end;
    end;
    CM = mean(CMS,3);
    ER = mean(ERS,2); 
    accuracy = 1-ER(1)/nsets

end

