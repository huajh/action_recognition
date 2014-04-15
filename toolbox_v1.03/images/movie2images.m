% Creates a stack of images from a matlab movie M.
%
% Repeatedly calls frame2im. 
% Useful for playback with playmovie.
% 
% INPUTS
%   M   - a matlab movie
%   
% OUTPUTS
%   I   - MxNxT array (of images)
%
% EXAMPLE
%   load( 'images.mat' );
%   M = makemovies( videos );
%   playmovie(movie2images(M));
%
% DATESTAMP
%   29-Sep-2005  2:00pm
%
% See also PLAYMOVIE

% Piotr's Image&Video Toolbox      Version 1.03   
% Written and maintained by Piotr Dollar    pdollar-at-cs.ucsd.edu 
% Please email me if you find bugs, or have suggestions or questions! 
 
%function I = movie2images( M )
%    I = feval_arrays( M, @frame2Ii );

function I = movie2images( Mobj )
    nFrames = Mobj.NumberOfFrames;
    vidHeight = Mobj.Height;
    vidWidth = Mobj.Width;    
    mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
           'colormap', []);
    for k = 1 : nFrames
        mov(k).cdata = read(Mobj, k);
    end
    I = feval_arrays( mov, @frame2Ii );

function I = frame2Ii( F )
    [I,map] = frame2im( F );
    if( isempty(map) )
        if( size(I,3)==3 )
            classname = class( I );
            I = sum(I,3)/3;
            I = feval( classname, I );
        end
    else
        I = ind2gray( I, map ); 
    end
