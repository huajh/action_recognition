% Creates movies of cuboids (normalizes each to [0,1] first).
%
% INPUTS
%   cuboids     - 4D array or cell array of cuboids
%   moviename   - [optional] base name for movie
%   fps         - [optional] frames per second
%
% OUTPUTS
%   M           - created movie
% 
% See also STFEATURES_ALLSCALES

function M = makemovie_features( cuboids, moviename, fps )
    if( iscell(cuboids) ) cuboids = cell2array(cuboids); end;
    if( ndims(cuboids)~=4 ) error('cuboids must a MxNxKxR array'); end;
    if( nargin<2 ) moviename=[]; end;
    if( nargin<3 ) fps=10; end;
    
    % standardize cuboids (for display)
    % cuboids = feval_arrays( cuboids, @imnormalize, 2 );    
    
    % make movie
    figure2( .8, 10); M = makemovie2( cuboids ); close(10);
    if( ~isempty(moviename) )
        moviename = [moviename '_features.avi'];
        movie2avi( M, moviename,'compression','Cinepak','FPS',fps);
    end
