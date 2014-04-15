
function Single_action_display(clipname,ACTION_TYPE,cliptypes, sigma, tau)
    if (nargin < 4) return; end;
    
    clipObj = load( [TestDir() '\clip_' clipname '.mat'] );
    featureObj = load( [TestDir() '\features_' clipname '.mat'] );

    I = clipObj.I;
    subs = featureObj.subs;       
    
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
    cols = .1 * [ 1 1 0.8; 0 1 0; 0 0 1; 
                  1 1 0; 1 0 1; 0 1 1; 
                  .5 0 0; 1 0.620 .40;  0.49 1 0.83 ];
              
    colormap = [1,1,0.6; 0,1,0; 0,0,1;
                1,1,0; 0,1,1; 1,0,1;
                1,1,0.4; 1,0,0; 1,0.6,0;
                0.2,1,0.8];
    color = colormap(ACTION_TYPE,:);
    
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
    
    rect = zeros(4,nframes);    
    rect([1,3],:) = inf;
    
    for i=1:nPoints        
        for d=1:3 
            extract{d} = cuboid_starts(i,d):cuboid_ends(i,d); 
        end;        
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
         
    % add an rectangle and type
    TypeStr = cliptypes{ACTION_TYPE};    
    for i=1:nframes
        V(:,:,:,i) = add_rectangle(V(:,:,:,i),rect(:,i),TypeStr,color);       
    end
               
    V = uint8( V * 255 );
                
    Mov(siz(3)) = struct('cdata',[],'colormap',[]);    
    for i=1:siz(3)
        Mov(i).cdata = V(:,:,:,i);
    end
    
    hf = figure;
%     [movHeight,movWidth,~,~] = size(V);     
%     set( hf, 'position', [150 150 2*movWidth 2*movHeight] );
    movie2avi(Mov, [OutputDir() '\knn\output_' clipname '.avi'], 'compression', 'None');
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
