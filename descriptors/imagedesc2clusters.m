% Assignment of descriptors to clusters. 
%
% For each descriptor desci (1xp vector), assigns desci to the closest cluster in
% clusters.  desc2i is thus a scalar that indicates the cluster membership of desci, or a
% 1xnclusters vector which is the result of a soft assign of desc1 to clusters (see
% softmin for more information).
%
% Note that imagedesc may have already called this function, if so make sure not to call
% it again.
%
% INPUTS
%   desc        - nxp array of n p-dimensional descriptors 
%                 nxpxr array of n p-dimensional descriptors, r jittered versions of each
%   clusters    - nclusters x p array of cluster centers
%   csigma      - [optional] soft assign to clusters, see softmin
%
% OUTPUTS
%   desc2       - nxp array of cluster memberships (p==1 if csigma not given)
%
% See also SOFTMIN

function desc2 = imagedesc2clusters( desc, clusters, csigma )
    if( nargin<3 || isempty(csigma) ) csigma=0; end;
    if( size(desc,2)~=size(clusters,2))
        error('dimensionality of desc and clusters does not match' ); end;
    
    %%% get distance matrix
    if( size(desc,3) == 1 ) % no jitter
        D = dist_euclidean( desc, clusters );
    else % jitter
        D = jitter_dist( desc, clusters );
    end
    
    %%% apply clustering
    if(csigma>0) 
        desc2=softmin(D,csigma); 
    else 
        [d,desc2]=min(D,[],2); 
    end;
