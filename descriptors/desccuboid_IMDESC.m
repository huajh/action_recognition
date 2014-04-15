% Cuboid descriptor based on a concatentation of the types of frames present.
%
% That is imdesc must be an image (ie frame) descriptor, furthermore it must contain
% clusters, so that the descriptor of the frame is a clusters assignment.  Hence each
% frame gets assigned to a cluster, and then the cuboid descriptor is simply a histogram
% of the frames present (alternatively, implementation could preserve order).
%
% INPUTS
%   I               - MxNxT double array (cuboid) with most vals in range [-1,1]
%   imdesc          - frame descriptor
%
% OUTPUTS
%   desc            - 1xp feature vector
%
% See also IMAGEDESC, DESCCUBOID_GRAD, DESCCUBOID_WW

function desc = desccuboid_IMDESC( I, imdesc )
    if( ndims(I)~=3 ) error('I must be MxNxT'); end;
    if( ~isa(I,'double') ) error('I must be of type double'); end;

    if(~isfield(imdesc,'clusters'))  
        error( 'imdesc must have clusters' ); end;
     
    % get descriptor for frames of cuboids, will be of size TxP
    fdesc = imagedesc( I, imdesc ); 
    if( size(fdesc,2)==1 )
        k = size(imdesc.clusters,1);
        desc = histc1D( fdesc, [.5:(k+.5)] ); 
    else
        desc = sum( fdesc, 1 );
    end;
        
        