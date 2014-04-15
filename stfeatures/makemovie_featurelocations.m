% Creates visualization of detected feature locations over multiple scales.
% 
% Takes scales as inputs to determine radii for detected cuboids. subs_cell should be an
% nsgimasxntaus cell array where each element is a set of subscripts denoting the
% locations of the feature at the given spatial/temporal scale.
%
% INPUTS
%   I           - 3D input image
%   sigmas      - spatial scales
%   taus        - temporal scales
%   subs_cell   - see above
%   moviename   - base name for movie
%   fps         - [optional] frames per second
%
% See also STFEATURES_ALLSCALES

function makemovie_featurelocations( I, sigmas, taus, subs_cell, moviename, fps )
    if( nargin<6 ) fps=10; end;
    if( ndims(I)~=3 ) error('I must a MxNxK array'); end;
    
    % amount to shrink image by in spatial and temporal directions
    reduce_s= 2; reduce_t = 1;  
    reduce = [reduce_s reduce_s reduce_t];
    
    % shrink everything [so movies don't take too much memory]
    [nsigmas,ntaus] = size(subs_cell);
    for s=1:nsigmas*ntaus
        subs = subs_cell{s};
        for i=1:3 subs(:,i) = round(subs(:,i)/reduce(i)); end;
        subs_cell{s} = subs;
    end;
    sigmas = sigmas / reduce_s;  taus = taus / reduce_t;
    I = imshrink( I, reduce );  I=double(I);

    % create R from Vs and Ws
    siz = size(I); h = siz(1); w = siz(2);  bw = 4;
    R = repmat( uint8(0), [siz(1)*2*nsigmas+bw*(nsigmas+1), siz(2)*ntaus+bw*(ntaus+1), 3, siz(3)] );
    R(:,:,1,:) = uint8(50); R(:,:,2,:) = uint8(180); R(:,:,3,:) = uint8(50); % border color
    for s=1:nsigmas  
        for t=1:ntaus  
            sigmas_st = [sigmas(s) sigmas(s) taus(t)];
            disp( ['sigmas = ' num2str(sigmas_st) ] );
            cuboids_rs = max( ceil(2.5*sigmas_st),[3,3,3] );
            [V,W] = cuboid_display( I, cuboids_rs, subs_cell{s,t}, 0 );
            W = repmat( W, [1,1,1,3] ); W = permute(W, [1,2,4,3] );  
            R( (1:h)+(s-1)*2*h +bw*s, (1:w)+(t-1)*w+bw*t, :, : ) = V;
            R( (1:h)+(s-1)*2*h+h +bw*s, (1:w)+(t-1)*w+bw*t, :, : ) = W;
        end
    end

    % make movie
    %moviename = [moviename '_featurelocations.avi'];
    disp( ['making movie: ' moviename] );
    M = makemovie(R);  clear R;
    movie2avi(M, moviename, 'compression','Cinepak','FPS',fps); 