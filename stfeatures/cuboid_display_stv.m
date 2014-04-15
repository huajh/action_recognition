% Fancy 3D spatiotemporal cuboid visualization.
%
% Extracts cuboids of given size from the array I at specified locations, using
% cuboid_extract.  It then displays a fancy visualiztion of the cuboids.  Only works if I
% is MxNxK (3 dimensional data).
%
% INPUTS
%   I               - d dimension array
%   cuboids_rs      - the dimensions of the cuboids to find (d x 1)
%   subs            - subscricts of max locations (n x d)
%
% See also CUBOID_DISPLAY, CUBOID_EXTRACT

function cuboid_display_stv2( I, cuboids_rs, subs )
    %%% show I in 3D
    I = double(I); 
    figure(1); clf; axis vis3d;
    stvolume_I( I );
    stvolume_cameraset;

    %%% show cuboids in 3D
    n = size(subs,1);
    if( n>60 ) error('Too many cuboids to display using this method!'); end;
    figure(2); clf; axis vis3d;
    I = double(I); siz = size(I); 
    ticstatusid = ticstatus('Drawing cuboids;');
    colors=colorcube(8); colors=colors(1:5,:);
    for i=1:n 
        %stvolume_cuboid( I, subs(i,:), cuboids_rs );
        stvolume_cuboidsolid( subs(i,:), cuboids_rs, colors(mod(i,5)+1,:) );
        tocstatus( ticstatusid, i/n ); 
    end;
    
    %%% add a couple of sliced frames
    stvolume_I( ones(size(I))+rand(size(I))/100, .05 ); 
    stvolume_bnds( [1 size(I,2); 1 size(I,1); 1 size(I,3) ] );
    hold on; 
    hslice=slice( I, [], [], siz(3) ); 
    set(hslice,'EdgeColor', 'none'); set(hslice,'FaceAlpha', 1.0 );
    hslice=slice( I, [], [], siz(3)*.66 ); 
    set(hslice,'EdgeColor', 'none'); set(hslice,'FaceAlpha', .75 );
    hslice=slice( I, [], [], siz(3)/3 ); 
    set(hslice,'EdgeColor', 'none'); set(hslice,'FaceAlpha', .5 );
    hslice=slice( I, [], [], 1 ); 
    set(hslice,'EdgeColor', 'none'); set(hslice,'FaceAlpha', .25 );
    hold off;  
    stvolume_cameraset;

    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       

%%% used to display the spatiotemporal volume I, with transperancy set by alpha
function stvolume_I( I, alpha )
    if( nargin<2 || isempty(alpha) ) alpha=1; end;
    siz=size(I);
    hold on; hslice=slice( I, [1 siz(2)-1], [1 siz(1)-1], [ 1 siz(3)-1] );
    set(hslice,'EdgeColor', 'none'); set(hslice,'FaceAlpha', alpha ); hold off;
    bnds = [1 siz(2); 1 siz(1); 1 siz(3) ];
    stvolume_bnds( bnds );

    
%%% used to draw boundaries around a stvolume - the black lines
function stvolume_bnds( bnds, color )
    if( nargin<2 ) color = 'k'; end;
    hold on;
    for i=1:2 for j=1:2
        h=line( [bnds(1,1) bnds(1,2)], [bnds(2,i) bnds(2,i)], [bnds(3,j) bnds(3,j)] );
        set(h,'Color',color); set(h,'LineWidth',1.2); 
        h=line( [bnds(1,i) bnds(1,i)], [bnds(2,1) bnds(2,2)], [bnds(3,j) bnds(3,j)] );
        set(h,'Color',color); set(h,'LineWidth',1.2);
        h=line( [bnds(1,i) bnds(1,i)], [bnds(2,j) bnds(2,j)], [bnds(3,1) bnds(3,2)] );
        set(h,'Color',color); set(h,'LineWidth',1.2);
    end; end;
    hold off;

    
%%% used to draw a cuboid located at sub of given dimensions
function stvolume_cuboid( I, sub, cuboids_rs )
    siz = size(I);
    hold on;
    for i=1:3 bnds(i,1:2) = [(sub(i)-cuboids_rs(i)) (sub(i)+cuboids_rs(i))]; end
    tmp = bnds; bnds(1,:)=tmp(2,:);  bnds(2,:)=tmp(1,:);
    [X,Y]=ndgrid( bnds(1,1):bnds(1,2), bnds(2,1):bnds(2,2) ); Z = ones(size(X))*bnds(3,1);
    hslice=slice( I, X, Y, Z );  set(hslice,'EdgeColor', 'none');
    [X,Y]=ndgrid( bnds(1,1):bnds(1,2), bnds(2,1):bnds(2,2) ); Z = ones(size(X))*bnds(3,2);
    hslice=slice( I, X, Y, Z );  set(hslice,'EdgeColor', 'none');
    [X,Z]=ndgrid( bnds(1,1):bnds(1,2), bnds(3,1):bnds(3,2) ); Y = ones(size(X))*bnds(2,1);
    hslice=slice( I, X, Y, Z );  set(hslice,'EdgeColor', 'none');
    [X,Z]=ndgrid( bnds(1,1):bnds(1,2), bnds(3,1):bnds(3,2) ); Y = ones(size(X))*bnds(2,2);
    hslice=slice( I, X, Y, Z );  set(hslice,'EdgeColor', 'none');
    [Y,Z]=ndgrid( bnds(2,1):bnds(2,2), bnds(3,1):bnds(3,2) ); X = ones(size(Y))*bnds(1,1);
    hslice=slice( I, X, Y, Z );  set(hslice,'EdgeColor', 'none');
    [Y,Z]=ndgrid( bnds(2,1):bnds(2,2), bnds(3,1):bnds(3,2) ); X = ones(size(Y))*bnds(1,2);
    hslice=slice( I, X, Y, Z );  set(hslice,'EdgeColor', 'none');
    hold off;   
    stvolume_bnds( bnds );

%%% used to display a solid cuboid (uniform color)
function stvolume_cuboidsolid( sub, cuboids_rs, color )
    for i=1:3 bnds(i,1:2) = [(sub(i)-cuboids_rs(i)) (sub(i)+cuboids_rs(i))]; end
    tmp = bnds; bnds(1,:)=tmp(2,:);  bnds(2,:)=tmp(1,:);
    edgecolor=color; alpha=0; showBack=0;
    %edgecolor='k'; alpha=1; showBack=0;
    hold on; 
    X=[bnds(1,1) bnds(1,1) bnds(1,2) bnds(1,2)];
    Y=[bnds(2,1) bnds(2,2) bnds(2,2) bnds(2,1)];
    Z = repmat(bnds(3,1),4); 
    fill3(X,Y,Z,color,'EdgeColor',edgecolor,'FaceAlpha',alpha);
    X=[bnds(1,1) bnds(1,1) bnds(1,2) bnds(1,2)];
    Z=[bnds(3,1) bnds(3,2) bnds(3,2) bnds(3,1)];
    Y = repmat(bnds(2,1),4); 
    fill3(X,Y,Z,color,'EdgeColor',edgecolor,'FaceAlpha',alpha);
    Y=[bnds(2,1) bnds(2,1) bnds(2,2) bnds(2,2)];
    Z=[bnds(3,1) bnds(3,2) bnds(3,2) bnds(3,1)];
    X = repmat(bnds(1,2),4); 
    fill3(X,Y,Z,color,'EdgeColor',edgecolor,'FaceAlpha',alpha);
    if( showBack==1 )
        Y=[bnds(2,1) bnds(2,1) bnds(2,2) bnds(2,2)];
        Z=[bnds(3,1) bnds(3,2) bnds(3,2) bnds(3,1)];
        X = repmat(bnds(1,1),4); 
        fill3(X,Y,Z,color,'EdgeColor',edgecolor,'FaceAlpha',alpha);
        X=[bnds(1,1) bnds(1,1) bnds(1,2) bnds(1,2)];
        Y=[bnds(2,1) bnds(2,2) bnds(2,2) bnds(2,1)];
        Z = repmat(bnds(3,2),4); 
        fill3(X,Y,Z,color,'EdgeColor',edgecolor,'FaceAlpha',alpha);
        X=[bnds(1,1) bnds(1,1) bnds(1,2) bnds(1,2)];
        Z=[bnds(3,1) bnds(3,2) bnds(3,2) bnds(3,1)];
        Y = repmat(bnds(2,2),4); 
        fill3(X,Y,Z,color,'EdgeColor',edgecolor,'FaceAlpha',alpha);
    end;
    hold off;
 
%%% Used to set camera in a good position to view spatiotemporal volume
function stvolume_cameraset
    colormap gray; axis off;
    camproj('perspective');
    set(gca,'DataAspectRatio',[1 1 1/3] );
    view([30 -50]); camup([0 -1 0])

    