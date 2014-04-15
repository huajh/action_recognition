% Calculates the minumum distance between two sets of possibly 'jittered' feature vectors.
%
% Normally a feature vector is a p element vector.  If there is jitter that means an
% object is described by r such p element vectors, taken from different 'views'. The
% distance between a jittered vector (r 1xp vectors) and a 1xp vector is simply taken as
% the minimum of the r distances.  
%
% If both desc1 and desc2 are jittered vectors, than a full search is not performed -
% instead the following is used to obtain the distance:
%   D = min( jitter_dist(desc1(middle),desc2), jitter_dist(desc1,desc2(middle)) ).
% 
% INPUTS
%   desc1       - m x p x r1 array of m rxp jittered vectors (r1=1 ok) 
%   desc1       - n x p x r2 array of m rxp jittered vectors (r2=1 ok) 
%   dist_func   - [optional] distance function that regular non jittered vectors
%
% OUTPUTS
%   D           - m x n array of distances
%
% EXAMPLE
%   load testimages;
%   A = double(squeeze(reshape( images, [], size(images,3) )))';
%   figure(1); im( jitter_dist(A,A) ); 
%   B = jitter_image(images,1,0,3,3);
%   B = reshape( B, [], size(B,3), size(B,4) );
%   B = double(squeeze(permute(B,[2 1 3])));
%   figure(2); im( jitter_dist(B,B) ); 
%
% See also DIST_EUCLIDEAN

function D = jitter_dist( desc1, desc2, distfun )
    if( nargin<3 ) distfun=@dist_euclidean; end;
    [n1 p1 r1] = size(desc1);  [n2 p2 r2] = size(desc2);
    if( p1~=p2 ) error( 'dimensionality of desc must match' ); end;

    if( r1==1 && r2==1 )
        D = distfun( desc1, desc2 );
    elseif( r1==1 && r2~=1 )
        D = jitter_dist( desc2, desc1, distfun )';
    elseif( r1~=1 && r2==1 )
        DS = feval_arrays( desc1, distfun, desc2 );
        D = min( DS, [], 3 );  
    else %r1~=1 && r2~=1
        if( r1~=r2 ) error( 'amount of jitter must match' ); end; % optional
        D1 = jitter_dist( desc1, desc2(:,:,round(r2/2)), distfun );
        D2 = jitter_dist( desc1(:,:,round(r1/2)), desc2, distfun );
        D = min( D1, D2 );
    end
            
        
