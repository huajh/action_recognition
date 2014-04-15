% Fancy cuboid visualization.
%
% Extracts cuboids of given size from the array I at specified locations, using
% cuboid_extract.  It then displays a fancy visualiztion of the cuboids.  Only works if I
% is MxN or MxNxK (2 or 3 dimensional data).  Tends to work well only if not too much
% overlap between cuboids (otherwise V is very dark).
%
% INPUTS
%   I               - d dimension array
%   cuboids_rs      - the dimensions of the cuboids to find (d x 1)
%   subs            - subscricts of max locations (n x d)
%   show            - [optional] figure to use for display (no display if == 0)
%
% OUTPUTS
%   V           - color version of I with each cuboid being a different color
%   Imasked     - I with everything blocked out except regions belonging to cuboids
%
% See also CUBOID_EXTRACT, CUBOID_DISPLAY_STV

function [ V, Imasked ] = cuboid_display( I, cuboids_rs, subs, show )
    n = size( subs, 1 );  nd = ndims(I);  siz=size(I);  
    if( n==0 ) warning('no cuboid specified'); V=[]; Imasked=[]; return; end;
    if( ~(nd==2 || nd==3)) error('no visualization avialable for dims>3'); end             
    if( nargin<4 ) show=0; end;
    make_Imasked = (nargout>1);
    
    
    %%% extract cuboids [to get cuboid locations]
    [ cuboids, cuboid_starts, cuboid_ends, subs] = cuboid_extract( I, cuboids_rs, subs, 0 );    
    n = size( subs, 1 );  
    
    %%% create color version of V
    I = double(I); I = I - min(I(:)); I = I / max(I(:));
    if (nd==2)  
        V = repmat( I, [1,1,3] ); 
    else 
        V = permute(I, [1,2,4,3] );
        V = repmat( V, [1,1,3,1] );
    end; 
    
    %%% overlay maxes (colored cuboids) on V
    cols = .4 * [ 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; .5 0 0; ...
                  1 0.620 .40; 0.49 1 0.83 ];
    % (top, botton,left, right) * nframes
    nframes = siz(3);
%     rect = zeros(4,nframes);    
%     rect([1,3],:) = inf;
    for i=1:n
        c = mod(i-1,length(cols))+1;

        for d=1:nd extract{d} = cuboid_starts(i,d):cuboid_ends(i,d); end;
        if (nd==2) extract{3} = 1; end;
        for j=1:3 
            if(cols(c,j)>0) 
                locs={ extract{1:2}, j, extract{3} };
                V(locs{:}) =  V(locs{:}) + cols(c,j); 
            end; 
        end;

        % green 0 1 0
%         colors = [0,1,0];
%         r = 0;
%         str = max(1, cuboid_starts(i,1)-r); endr = min( cuboid_ends(i,1)+r, siz(1));
%         stc = max(1, cuboid_starts(i,2)-r); endc = min( cuboid_ends(i,2)+r, siz(2));
%         for j=1:3
%             if colors(j) > 0 
%                 line = {[str:(str+2*r),(endr-2*r):endr],extract{2},j,extract{3}};
%                 line2 = {extract{1},[stc:(stc+2*r),(endc-2*r):endc],j,extract{3}};        
%                 V(line{:}) = colors(j);
%                 V(line2{:}) = colors(j);
%             end
%         end
%         % find rectangle location for every frame
%         deep = extract{3};
%         sets = repmat([str,endr,stc,endc]',1, length(deep));
%         rect([1,3],deep) = min(rect([1,3],deep),sets([1,3],:));
%         rect([2,4],deep) = max(rect([2,4],deep),sets([2,4],:));
        
    end;
    V = V / max(V(:));
    
    % add an rectangle and type

%     type = 'walking';
%     type_map = logical(1-text2im(type));
%     type_map = type_map(1:2:end,1:2:end);
%     colors = [0,1,0];    
%     for i=1:nframes
%         if( rect(1,i) < rect(2,i) && rect(3,i) < rect(4,i))         
%             % text
%             % top,left
%             [len,wid] = size(type_map);
%             len2 = min(len,rect(1,i));
%             wid2 = min(wid,siz(2)-rect(3,i));
%             clip_mask = type_map((1+len-len2):end,1:wid2);            
%          %   V(:,:,:,i) = AddTextToImage(V(:,:,:,i),'hello',[rect(1,i)-len2+1,rect(3,i)],[0,1,0],'Arial',16);
%             for j=1:3
%                 if  colors(j) > 0 
%                     line = {[rect(1,i),rect(2,i)],rect(3,i):rect(4,i),j,i};
%                     line2 = {rect(1,i):rect(2,i),[rect(3,i),rect(4,i)],j,i};
%                     V(line{:}) = colors(j);
%                     V(line2{:}) = colors(j);
%                     tmp = V((rect(1,i)-len2):(rect(1,i)-1),rect(3,i):(rect(3,i)+wid2-1),j,i);
%                     tmp(clip_mask == 1) = colors(j);
%                     V((rect(1,i)-len2):(rect(1,i)-1),rect(3,i):(rect(3,i)+wid2-1),j,i) = tmp;                    
%                 end
%             end                       
%         end
%     end
            
    %%% add white dot at location of response
    r = 1;        
    for i=1:n
        str = max(1, subs(i,1)-r ); endr = min( subs(i,1)+r, siz(1) );
        stc = max(1, subs(i,2)-r ); endc = min( subs(i,2)+r, siz(2) );
        if (nd==2) zloc = 1; else zloc = subs(i,3); end;
        if (nd==3 && ~(zloc>0 && zloc<siz(3)) ) continue; end;
        V( str:endr, stc:endc, :, zloc ) = .5; 
    end;    
    V = uint8( V * 255 );
            
    
%     Mov(siz(3)) = struct('cdata',[],'colormap',[]);    
%     for i=1:siz(3)
%         Mov(i).cdata = V(:,:,:,i);
%     end
%     hf = figure;    
%     movie2avi(Mov, 'Vnone.avi', 'compression', 'None');
%     movie(hf,Mov,5,12,[0,0,0,0]);
    
    
    %%% [optional] create Imasked
    if( make_Imasked )
        Imasked = I-I;
        for i=1:n
            for d=1:nd extract{d} = cuboid_starts(i,d):cuboid_ends(i,d); end;
            Imasked( extract{:} ) = 1;
        end
        Imasked = I .* Imasked;
        Imasked = uint8(Imasked * 255);
    end;        
    
    % [optional] display
    if (1) 
        if (nd==2)                 
            figure(show);    clf;  im( I );
            figure(show+1);  clf;  im( V );
            figure(show+2);  clf;  montage2( cell2array( cuboids ) );
            if (make_Imasked) figure(show+3);  clf; im( make_Imasked ); end;
        else
            figure(show);    clf;  montage2( I,1 );            
            figure(show+1);  clf;  montage2( V,1 );
            figure(show+2);  clf;  montages2( cell2array(cuboids(1:5))); %, {0,0,[0,1]} );  modified at 2014/3/20
            if (make_Imasked) figure(show+3);  clf;  montage2( Imasked ); end;
        end
    end;