% Post processing for jitter_kmeans.
%
% After clustering either jittered images or cuboids, the item from the jittered set that
% was used in the final clustering can be retrieved.  This function does exactly that.
% IJT and descJT are the images/cuboids jittered and their associated descriptors
% jittered, where IDXr was returned by jitter_kmeans.
%
% INPUTS
%   IDXr    - see jitter_kmeans
%   IJT     - ... xNxR  array   
%   descJT  - [optional] NxPxR  array
%
% OUTPUTS
%   I       - ...xN  array
%   desc    - NxP  array
%
% See also JITTER_KMEANS

function [I,desc] = jitter_rectify( IDXr, IJT, descJT )
    siz = size(IJT); nd = ndims(IJT);   n = siz(end-1);
    if( nd~=4 && nd~=5 ) error('I must have 4 or 5 dimensions');  end;
    inds = {':'}; inds = inds(ones(nd-2,1));

    % create I 
    I = repmat( IJT(1), [siz(1:end-1)] );
    for i=1:n
        I(inds{:},i) = IJT(inds{:},i,IDXr(i)); 
    end;

    % create desc [optionally]
    if( nargin>=3 )
        [n2 p r] = size( descJT );
        if( n~=n2 ) error( 'Dimensions of IJT and descJT do not match (n).' ); end;
        if( siz(end)~=r ) error( 'Dimensions of IJT and descJT do not match (r).' ); end;
        desc = zeros( n, p );
        for i=1:n
            desc(i,:) = descJT(i,:,IDXr(i)); 
        end;
    end;
