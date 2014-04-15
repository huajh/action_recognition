% Version of kmeans that allows for jittered vectors.
%
% For usage see kmeans2.
% See jitter_dist for explanation of jitter.
%
% [IDX,IDXr,C,sumd] = jitter_kmeans( descJT, k, varargin )
% descJT  -  Nxpxr, where N is number of samples, p is dimensionality, and r is jitter
%
% See also JITTER_DIST, KMEANS2

function [IDX,IDXr,C,sumd] = jitter_kmeans( descJT, k, varargin )

    %%% get input args   (NOT SUPPORTED:  distance, emptyaction, start )
    pnames = {  'replicates' 'maxiter' 'display' 'randstate' 'outlierfrac' 'minCsize'};
    dflts =  {       1        200         0           []          0                1        };
    [errmsg,replicates,maxiter,display,randstate,outlierfrac,minCsize] = getargs(pnames, dflts, varargin{:});
    error(errmsg);
    if (k<=1) error('k must be greater than 1'); end;
    if (outlierfrac<0 || outlierfrac>=1) error('fraction of outliers must be between 0 and 1'); end;
    noutliers = floor( size(descJT,1)*outlierfrac );

    % initialize seed if it was not specified by user, otherwise set it.
    if (isempty(randstate)) randstate = rand('state'); else rand('state',randstate); end;

    % run kmeans2_main replicates times
    msg = ['Running kmeans2 with k=' num2str(k)]; 
    if (replicates>1) msg=[msg ', ' num2str(replicates) ' times.']; end;
    if (display) disp(msg); end;
    
    bestsumd = inf; 
    for i=1:replicates
        tic
        msg = ['kmeans iteration ' num2str(i) ' of ' num2str(replicates) ', step: '];
        if (display) disp(msg); end;
        [IDX,IDXr,C,sumd,niters] = kmeans2_main(descJT,k,noutliers,minCsize,maxiter,display);
        if (sum(sumd)<sum(bestsumd)) bestIDX = IDX; bestIDXr=IDXr; bestC = C; bestsumd = sumd; end
        msg = ['\nCompleted kmeans iteration ' num2str(i) ' of ' num2str(replicates)];
        msg = [ msg ';  number of kmeans steps= ' num2str(niters) ';  sumd=' num2str(sum(sumd)) '\n']; 
        if (display && replicates>1) fprintf(msg); toc, end;
    end
    
    IDX = bestIDX; IDXr = bestIDXr;  C = bestC; sumd = bestsumd; k = max(IDX);  
    msg = ['Final number of clusters = ' num2str( k ) ';  sumd=' num2str(sum(sumd))]; 
    if (display) disp(msg); end;    
    
    
    % sort IDX to have biggest clusters have lower indicies (no need to alter IDXr)
    clustercounts = zeros(1,k); for i=1:k clustercounts(i) = sum( IDX==i ); end
    [ids,order] = sort( -clustercounts );  C = C(order,:);  sumd = sumd(order);
    IDX2 = IDX;  for i=1:k IDX2(IDX==order(i))=i; end; IDX = IDX2; 
    
    
    
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [IDX,IDXr,C,sumd,niters] = kmeans2_main(descJT,k,noutliers,minCsize,maxiter,display)    

    % initialize the vectors containing the IDX assignments
    % and set initial cluster centers to be k random X points
    [N p r] = size(descJT);
    IDX = ones(N,1); oldIDX = zeros(N,1); 
    IDXr = ones(N,1); oldIDXr = zeros(N,1);
    index = randperm2(N,k); 
    C = descJT(index,:,randint2(1,1,[1 r])); 
    
    
    % MAIN LOOP: loop until the cluster assigments do not change
    niters = 0;  ndisdigits = ceil( log10(maxiter-1) );
    if( display ) fprintf( ['\b' repmat( '0',[1,ndisdigits] )] ); end;
    while( (sum(abs(oldIDX - IDX))+sum(abs(oldIDXr - IDXr)))~=0  &&  niters < maxiter)

        % calculate the Euclidean distance between each point and each cluster mean
        % and find the closest cluster mean for each point and assign it to that cluster
        oldIDX = IDX;  oldIDXr = IDXr;  [IDX, IDXr, mind] = jitter_kmeans_dist( descJT, C );

        % do not use most distant noutliers elements in computation of cluster centers
        mindsort = sort( mind ); thr = mindsort( end-noutliers );  IDX( mind > thr ) = -1; 

        % discard small clusters [place in outlier set, will get included next time around]
        i=1; while(i<=k) if (sum(IDX==i)<minCsize) IDX(IDX==i)=-1; 
                if(i<k) IDX(IDX==k)=i; end; k=k-1; else i=i+1; end; end
        if( k==0 ) IDX( randint2( 1,1, [1,N] ) ) = 1; k=1; end;
        for i=1:k if ((sum(IDX==i))==0)
                error('should never happen - empty cluster!'); end; end;        

        % Recalculate the cluster means based on new assignment (loop is compiled hence fast!)
        % Actually better then looping over k, because X(IDX==i) is slow. Add 2 to k for outliers.  
        C = zeros(k,p);  counts = zeros(k,1);
        for i=find(IDX>0)' IDx = IDX(i); counts(IDx)=counts(IDx)+1; 
            C(IDx,:) = C(IDx,:) + descJT(i,:,IDXr(i)); end
        C = C ./ counts(:,ones(1,p));
        
        niters = niters+1;
        if( display ) 
            fprintf( [repmat('\b',[1 ndisdigits]) int2str2(niters,ndisdigits)] ); end;
    end

    % record within-cluster sums of point-to-centroid distances 
    sumd = zeros(1,k); for i=1:k sumd(i) = sum( mind(IDX==i) ); end

    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [IDX, IDXr, mind] = jitter_kmeans_dist( descJT, C )
    [N p r] = size(descJT); k = size(C,1);
    DS = feval_arrays( descJT, @dist_euclidean, C );
    [D IDXr] = min( DS, [], 3 );  
    [mind IDX] = min( D, [], 2 );
    IDXr = IDXr( sub2ind2( size(IDXr), [(1:N)' IDX ] ) );
