% Demo of stfeatures on the "oscillating example".
%
% From Laptev & Lindeberg papers.
%
% INPUTS
%   periodic    - if 1 uses periodic detector else uses harris detector

%function stfeatures_demo( 1 )

    
%     sigma = 1.5; % a good range appears to be [.2,1.5]?
%     tau = 2.5; 
%     thresh = .2; maxn = 100; 
%     show = 1;
    
    %%% get parameters for mesh (width must be ints!)
%     xstart = .5; xend = 2.2; xstep = .02;
%     xwidth = round( (xend-xstart) / xstep )+1;
%     tstart = .8; tend = 1.9; tstep = .02;
%     twidth = round( (tend-tstart) / tstep )+1;
%     ystart = -3; yend = 3; ystep = 1/30; 
%     ywidth = round( (yend-ystart) / ystep )+1;
    
    %%% create images
%     [X,Y] = meshgrid( xstart:xstep:xend, ystart:ystep:yend );
%     sinX4 = sin(X.^4);   tvec = tstart:tstep:tend;
%     I = zeros( ywidth, xwidth, twidth );
%     for i=1:length(tvec);
%         t = tvec(i);
%         Z = -sign( Y - sinX4 * sin(t^4) );
%         I(:,:,i) = Z;
%        % imshow(I(:,:,i));
%     end
    addpath('../recognition');
    
    periodic = 1;
    avi_str = [ TestDir() '\' 'denis_walk.avi'];
    info = aviinfo(avi_str);
    
    Mobj = VideoReader(avi_str); %replace             
    I = movie2images(Mobj);
        
     %%% SETTABLE PARAMETERS
    sigma = 1.5;
    tau = 1.5;
    thresh = 2e-4;
    %maxn = info.NumFrames;
    maxn = 200;
    %if (maxn > 200)  maxn = 200; end
    show = 1;
    
    %%% run  corner detector    
    [R,subs,vals] = stfeatures( I, sigma, tau, periodic, thresh, maxn, [],[],[], show );    
%    nfeatures = size(subs,1)

    %%% create and dipslay surface mesh with detected interest points

%     % create surface mesh
%     [X,T] = meshgrid( xstart:xstep:xend, tstart:tstep:tend );
%     Y = sin( X.^4 ) .* sin( T.^4 );
%         
%     % transform X,Y,T to have correct coordinates
%     Y = (Y - ystart) ./ ystep +1;  %rows
%     X = (X - xstart) ./ xstep +1;  %cols
%     T = (T - tstart) ./ tstep +1;  %time
%         
%     % display surface mesh
%     figure(show+4); clf;
%     surf(X,T,Y,'FaceColor','red','EdgeColor','none');
%     set(gca,'YDir','reverse'); set(gca,'ZDir','reverse'); 
%     camlight left; lighting phong; %lighting Gouraud;
%     xlabel('col'); ylabel('time'); zlabel('row');
%     view(-15,55);
%         
%     % plot detected interest points on top of mesh
%     hold('on');
%     for i=1:nfeatures
%         ellipsoid( subs(i,2), subs(i,3), subs(i,1), 2.5*sigma, 2.5*tau, 2.5*sigma, 8 );
%     end
%     hold('off');      
