function [CodeProb,CodeIDX,Clusters_Centers] = CreateCodeBook(DATASETS,ncodebook,nclasses)
    
    % soft assign see clipdesc
    csigma=0.5;
    par_kmeans={'replicates',5,'minCsize',1,'display',0,'outlierfrac',0 };
    
    Clusters_Centers = recog_cluster(DATASETS, ncodebook, par_kmeans );   
    if size(Clusters_Centers,1) ~= ncodebook
        ncodebook = size(Clusters_Centers,1);
    end
    %  - length N cell vector of (nclips x p) arrays of data  which block it belongs to.
    Data = recog_clipsdesc( DATASETS, Clusters_Centers, csigma );
    nsets = length(DATASETS);
    nclips = cell2mat({DATASETS.nclips});
    CodeBook = zeros(nclasses,ncodebook);
    for i =1:nsets
        tmp = Data{i};
        for j=1:nclips
            type_idx = DATASETS(i).IDX(j);
            CodeBook(type_idx,:) = CodeBook(type_idx,:) + tmp(j,:);
        end
    end
    CodeProb = CodeBook./repmat(sum(CodeBook,1),nclasses,1);
    [~,CodeIDX] = max(CodeBook);