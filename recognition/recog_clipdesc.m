% Creates a clip descriptor that is simply a histogram of cuboids present. 
%
% INPUTS
%   desc_cuboids    - output from imagedesc2clusters
%   nclusters       - total number of clusters
%   nframes         - [optional] number to normalize by
%
% OUTPUTS
%   clipdesc        - 1xnclusters histogram of cuboid counts
%
% See also IMAGEDESC2CLUSTERS

function clipdesc  = recog_clipdesc( desc_cuboids, nclusters, nframes )
    if( nargin<3 || isempty(nframes) ) nframes=[]; end;
    
    % get descriptor for behavior (1xnclusters)
    if( size(desc_cuboids,2)==1 ) % histogram hard assigned cuboids
        clipdesc  = histc( desc_cuboids, [.5:(nclusters+.5)] ); 
        clipdesc  = clipdesc(1:end-1)';
    elseif( size(desc_cuboids,2)==0 ) % no cuboids
        clipdesc  = zeros( 1, nclusters );
    else % combine soft assigned cuboids (sum histograms)
        clipdesc  = sum( desc_cuboids, 1 );        
    end
    
    % normalize by number of frames
    if( ~isempty(nframes) ) clipdesc  = clipdesc  / nframes; end;