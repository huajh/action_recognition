
function Multi_action_display(clipname,cliptypes, sigma, tau)
    if (nargin < 4) return; end;
    
    clipObj = load( [TestDir() '\clip_' clipname '.mat'] );
    featureObj = load( [TestDir() '\features_' clipname '.mat'] );

    I = clipObj.I;
    subs = featureObj.subs;   
    action_idx = featureObj.action_idx;
    
    I=padarray(I,[5 5 15],'both','replicate'); %small/short clips, pad! 
      
    %if( isempty(cuboids_rs) ) % pad a bit for filtering etc.
    cuboids_rs = ceil( [sigma*3 sigma*3 tau*3] );   
    
    %%% convert I_sm to double in range [-1,1]
    if( isa(I,'uint8') ) I = double(I)/255 * 2 -1; end
    if( ~isa(I,'double') ) I = double(I); end
    if( max(abs(I(:)))>1 ) I=I-min(I(:)); I=I/(max(I(:))/2) - 1; end;            
    
    %%% extract cuboids [to get cuboid locations]
    [ ~, cuboid_starts, cuboid_ends, subs] = cuboid_extract( I, cuboids_rs, subs, 0 );    
    
    nPoints = size( subs, 1 );  
    siz=size(I);
    nframes = siz(3);
    ntype = length(cliptypes);
    
    %%% create color version of V
    I = double(I); I = I - min(I(:)); I = I / max(I(:)); 
    V = permute(I, [1,2,4,3] );
    V = repmat( V, [1,1,3,1] );

    %%% overlay maxes (colored cuboids) on V
    cols = .15 * [ 1 1 0.8; 0 1 0; 0 0 1; 
                  1 1 0; 1 0 1; 0 1 1; 
                  .5 0 0; 1 0.620 .40;  0.49 1 0.83 ];
              
    colormap = [1,1,0.6; 0,1,0; 0,0,1;
                1,1,0; 0,1,1; 1,0,1;
                1,1,0.4; 1,0,0; 1,0.6,0;
                0.2,1,0.8];
          
    %cliptypes = { 'bend','jack','jump','pjump','run','side','skip','walk','wave1','wave2' };
    
    % (top, botton,left, right) * nframes
    
    is_cols = 1;
   if (is_cols)
        for i=1:nPoints        
            % colorfull
            c = mod(i-1,length(cols))+1;
            for d=1:3 
                extract{d} = cuboid_starts(i,d):cuboid_ends(i,d); 
            end;
            for j=1:3 
                if(cols(c,j)>0)
                    locs={ extract{1:2}, j, extract{3} };
                    V(locs{:}) =  V(locs{:}) + cols(c,j); 
                end; 
            end;              
        end;
   end
    V = V / max(V(:));    
    
    action_hist = zeros(1,ntype);
    rect = zeros(4,nframes);    
    rect([1,3],:) = inf;    
    for i=1:nPoints        
        for d=1:3 
            extract{d} = cuboid_starts(i,d):cuboid_ends(i,d); 
        end;
        ACTION_TYPE = action_idx(i);
        action_hist(ACTION_TYPE) = action_hist(ACTION_TYPE)+1;
        color = colormap(ACTION_TYPE,:);
        % rectangle of each cuboid
        r = 0;
        str = max(1, cuboid_starts(i,1)-r); endr = min( cuboid_ends(i,1)+r, siz(1));
        stc = max(1, cuboid_starts(i,2)-r); endc = min( cuboid_ends(i,2)+r, siz(2));
        for j=1:3
            if color(j) > 0 
                line = {[str:(str+2*r),(endr-2*r):endr],extract{2},j,extract{3}};
                line2 = {extract{1},[stc:(stc+2*r),(endc-2*r):endc],j,extract{3}};        
                V(line{:}) = color(j);
                V(line2{:}) = color(j);
            end
        end
        
        % find rectangle location for every frame
        deep = extract{3};
        sets = repmat([str,endr,stc,endc]',1, length(deep));
        rect([1,3],deep) = min(rect([1,3],deep),sets([1,3],:));
        rect([2,4],deep) = max(rect([2,4],deep),sets([2,4],:));
        
        %%%              
    end    
    
    action_hist
    
    % all points = interest points * deepth
    deepth = 2*ceil(3*tau)+1;    
    all_points = [];
    for i=1:nPoints        
        deep = cuboid_starts(i,3):cuboid_ends(i,3);
        % x,y,action_ix,frame
        subs_rep = repmat([subs(i,1:2),action_idx(i),subs(i,3)],deepth,1);
        subs_rep(:,4) = deep';
        all_points = [all_points;subs_rep];
    end
    
    for i=1:nframes
        % points in current frame        
        frame_points = all_points(all_points(:,4)==i,1:3);        
        total_cnts = size(frame_points,1);
        
        if total_cnts < 4 continue; end;
        
        type_cnts = histc(frame_points(:,3),1:ntype);
        type_prob = type_cnts./total_cnts;
        
        % how many action categories ?
        categ_idx = [];
        k = 0;
        for j=1:ntype
            if type_prob(j)>0.5 ||...
                (type_prob(j)>0.4 && type_cnts(j) > 10) ||... 
                (type_prob(j)>0.3 && type_cnts(j) > 24) ||...
                (type_prob(j)>0.2 && type_cnts(j) > 23) ||...
                (type_prob(j)>0.1 && type_cnts(j) > 25)            
                categ_idx = [categ_idx,j];
                k = k + 1;
            end
        end
        if k == 0 continue; end;
        %k = 2;
        [idx,cent] = kmeans(frame_points(:,1:2),k);
        
        for j=1:k
            clust = frame_points(idx==j,:);           
            %svd
            %[~,s,v] = svd(clust(:,1:2),0);
            %eigv = sqrt(s(1,1))*v(:,1);
            %eigv2 = sqrt(s(2,2))*v(:,2);
            %w = abs(eigv(1)) + abs(eigv2(1));
            %h = abs(eigv(2)) + abs(eigv2(2));
          
            % simple variance
            %sigma = sqrt(var(clust(:,1:2)));
            %h = sigma(1)*2; w = sigma(2)*2;
            %xy = mean(clust(:,1:2)) - [w/2,h/2];            
            
            % which type
            [~,ACTION_TYPE] = max(histc(clust(:,3),1:ntype));
            clu_idx = find(clust(:,3) == ACTION_TYPE);            
            % max min
            x = min(clust(clu_idx,1))-cuboids_rs(1);  y = min(clust(clu_idx,2))-cuboids_rs(2);            
            x2 = max(clust(clu_idx,1))+cuboids_rs(1);  y2 = max(clust(clu_idx,2))+ cuboids_rs(2);            
            
            % rectangle
            % (top, botton,left, right)
            %rect = uint8([xy(1),xy(1)+h,xy(2),xy(2)+w]);
            rect = uint16([x,x2,y,y2]);           
            
            TypeStr = cliptypes{ACTION_TYPE};
            color = colormap(ACTION_TYPE,:);
            V(:,:,:,i) = add_rectangle(V(:,:,:,i),rect,TypeStr,color);
        end                
    end
    
    
    % add an rectangle and type
    
%     ACTION_TYPE = 1;
%     TypeStr = cliptypes{ACTION_TYPE};
%     color = colormap(ACTION_TYPE,:);
%     type_map = logical(1-text2im(TypeStr));
%     type_map = type_map(1:2:end,1:2:end);
%     for i=1:nframes
%         if( rect(1,i) < rect(2,i) && rect(3,i) < rect(4,i))         
%             % text
%             % top,left
%             [len,wid] = size(type_map);
%             len2 = min(len,rect(1,i));
%             wid2 = min(wid,siz(2)-rect(3,i));
%             clip_mask = type_map((1+len-len2):end,1:wid2);
%             for j=1:3
%                 if  color(j) > 0 
%                     line = {[rect(1,i),rect(2,i)],rect(3,i):rect(4,i),j,i};
%                     line2 = {rect(1,i):rect(2,i),[rect(3,i),rect(4,i)],j,i};
%                     V(line{:}) = color(j);
%                     V(line2{:}) = color(j);
%                     tmp = V((rect(1,i)-len2):(rect(1,i)-1),rect(3,i):(rect(3,i)+wid2-1),j,i);
%                     tmp(clip_mask == 1) = color(j);
%                     V((rect(1,i)-len2):(rect(1,i)-1),rect(3,i):(rect(3,i)+wid2-1),j,i) = tmp;                    
%                 end
%             end                       
%         end
%     end
            
    %%% add white dot at location of response
    r = 1;        
%     for i=1:nPoints
%         str = max(1, subs(i,1)-r ); endr = min( subs(i,1)+r, siz(1) );
%         stc = max(1, subs(i,2)-r ); endc = min( subs(i,2)+r, siz(2) );
%         zloc = subs(i,3);
%         if ( ~(zloc>0 && zloc<siz(3)) ) continue; end;
%         V( str:endr, stc:endc, :, zloc ) = .5; 
%     end;    
    V = uint8( V * 255 );
            
    
    Mov(siz(3)) = struct('cdata',[],'colormap',[]);    
    for i=1:siz(3)
        Mov(i).cdata = V(:,:,:,i);
    end
    
    hf = figure;    
    movie2avi(Mov, [OutputDir() '\output_' clipname '.avi'], 'compression', 'None');
    movie(hf,Mov,5,12,[0,0,0,0]);
           
end


function I = add_rectangle(I,rect,text,color)

    type_map = logical(1-text2im(text));
    type_map = type_map(1:2:end,1:2:end);
    if( rect(1) >= rect(2) || rect(3) >= rect(4)) return; end;
    siz = size(I);
    % text
    % top,left
    [len,wid] = size(type_map);
    len2 = min(len,rect(1));
    wid2 = min(wid,siz(2)-rect(3));
    clip_mask = type_map((1+len-len2):end,1:wid2);
    for j=1:3
        if  color(j) > 0
            line = {[rect(1),rect(2)],rect(3):rect(4),j};
            line2 = {rect(1):rect(2),[rect(3),rect(4)],j};
            I(line{:}) = color(j);
            I(line2{:}) = color(j);            
            tmp = I((rect(1)-len2+1):(rect(1)),rect(3):(rect(3)+wid2-1),j);
            tmp(clip_mask == 1) = color(j);
            I((rect(1)-len2+1):(rect(1)),rect(3):(rect(3)+wid2-1),j) = tmp;
        end
    end
end
