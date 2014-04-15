% Extracts cuboids of given size from the array I at specified locations.
%
% extractflag determines how cuboids are extracted near the border of the image.
% Regardless of extractflag, if a certain cuboid contains no array data then it is
% discarded.  If extractflag==0, then extracted cuboids near the borders are cropped to
% contain only image data, under this option cuboids may have irregular sizes.  If
% extractflag==1, then extracted cuboids near the border are zero padded.  This also means
% the cuboid_starts and cuboid_ends may have values outside of the range of I. If
% extractflag==2, then cuboid centers near the border are shifted until they fall fully
% within the image.  When this option is selected the altered subscript locations are
% returned in the output subs. 
%
% Data is returned in a cell array due to possibly irregular sizes of the cuboids (if
% extractflag==0 cuboids may be cropped).  See cell2array.m for converting cell to array
% (by zero padding smaller entries in the cell array).
%
% INPUTS
%   I               - d dimension array
%   cuboids_rs      - the dimensions of the cuboids to find (1 x d)
%   subs            - subscricts of max locations (n x d)
%   extractflag     - [optional] by default==0, see above for usage
%
% OUTPUTS
%   cuboids         - cuboid{i} contains the ith extracted cuboid (n x 1)
%   cuboid_starts   - start locations of cuboids (n x d) [may have vals out of range]
%   cuboid_ends     - end locations of cuboids (n x d) [may have vals out of range]
%   subs            - subscricts of (possibly altered) max locations (n x d)
%
% See also CUBOID_DISPLAY

function [ cuboids, cuboid_starts, cuboid_ends, subs ] = ...
                    cuboid_extract( I, cuboids_rs, subs, extractflag )
    nd = ndims(I);   siz=size(I);  n = size( subs,1 );  
    if( nargin<4 ) extractflag=0; end;

    if( n==0 ) error('no cuboid specified'); end;
    [cuboids_rs,er] = checknumericargs( cuboids_rs, size(siz), 0, 1 ); error(er);    
    if( any(cuboids_rs>siz)) error( ['all cuboids_rs=[' num2str(cuboids_rs)...
             '] must be <= size(I)=[' num2str(siz) '].'] ); end;
 
    cuboids_rs_rep = repmat( cuboids_rs, [n,1] );
    siz_rep = repmat( siz, [n,1] );

    % discard any location that contains no array data
    cuboid_starts = max(1,subs-cuboids_rs_rep);
    cuboid_ends = min( siz_rep, subs+cuboids_rs_rep);
    keeplocs = not( any( cuboid_starts > siz_rep, 2 ) | any( cuboid_ends < 1, 2 ) );
    if (~all(keeplocs)) % recalulate basic objects
        subs = subs( keeplocs, : );
        n = size( subs,1 );
        cuboids_rs_rep = repmat( cuboids_rs, [n,1] );
        siz_rep = repmat( siz, [n,1] );
    end
       
    % see description of extractflag above
    if (extractflag==0) % simply bound starts and ends
        cuboid_starts = max(1,subs-cuboids_rs_rep);
        cuboid_ends = min( siz_rep, subs+cuboids_rs_rep);
    elseif (extractflag==1) % pad and alter starts and ends
        I = padarray( I, cuboids_rs, 0, 'both' );  
        subs_padded = subs + cuboids_rs_rep;          
        cuboid_starts = subs_padded-cuboids_rs_rep;
        cuboid_ends = subs_padded+cuboids_rs_rep;
    elseif (extractflag==2) % shift subs appropriately
        subs = max( subs, cuboids_rs_rep + 1 );
        subs = min( subs, siz_rep - cuboids_rs_rep );
        cuboid_starts = subs-cuboids_rs_rep;
        cuboid_ends = subs+cuboids_rs_rep;
    else
        error('illegal extractflag'); 
    end

    % extract regions of interest from original array (regions will diff in size)
    cuboids = cell( n, 1 );  
    for i=1:n
        for d=1:nd extract{d} = cuboid_starts(i,d):cuboid_ends(i,d); end;
        cuboids{i,1} = I(  extract{:} );
    end;
    
    % undo effects of padding    
    if (extractflag==1)
        cuboid_starts = cuboid_starts - cuboids_rs_rep;
        cuboid_ends = cuboid_ends - cuboids_rs_rep;
    end;
    