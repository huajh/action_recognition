% Demo to show how imagedesc works.
% 
% This is a script, tweak to see how things work.
%
% See also IMAGEDESC, IMAGEDESC_GENERATE

addpath('../recognition');
addpath('../stfeatures');
    %%% use imdesc_create to create descritptor, 
    %%% choose if working with images / cuboids
    ccc;  show =1; % figure for display
    iscuboid = 1;  histFLAG = -1;  jitterFLAG = 0;
    imdesc = imagedesc_generate( iscuboid, 'APR', histFLAG, jitterFLAG );
    disp('------------start imagedesc_demo --------------');
    
    %%% load test data [[optionally]]
    if( 1 && ~exist('I','var') )
        if( iscuboid==1 ) % cuboids
            load testcuboids; I = cuboids; 
        elseif( 1 ) % images
            load testcuboids; I = images; 
        else % get images from cuboids 
            load testcuboids; 
            I=reshape(cuboids,size(cuboids,1),size(cuboids,2),[]);  
            n=size(I,3); rperm=randperm(n); I=I(:,:,rperm(1:min(end,10000)));
        end;
        clear cuboids cuboids2 cuboidsrect images images2 imagesrect
    end;
    
    %%% optionally get PCA coefficients 
    if( 0 && ~isfield( imdesc, 'par_pca' ) ) 
        imdesc = imagedesc_getpca( I, imdesc, 100, 1 ); end; 

    %%% get descriptor for all elements of I
    disp('get desc..'); 
    desc = imagedesc( I, imdesc, 0 ); 
    
    %%% cluster I 
    disp( 'cluster...' );
    par_kmeans={'replicates',5,'minCsize',1,'display',1,'outlierfrac',0 }; 
    if( ~jitterFLAG )
        [IDX, clusters] = kmeans2( desc, 3, par_kmeans{:} ); 
        I2 = I;
    else
        [IDX,IDXr,clusters] = jitter_kmeans( desc, 3, par_kmeans{:} );
        if( iscuboid )
            IJT = jitter_video( I, imdesc.par_jitter{:} ); 
        else
            IJT = jitter_image( I, imdesc.par_jitter{:} ); 
        end;
        I2 = jitter_rectify( IDXr, IJT );
    end
        
    
    %%% show dist matrix
    figure(show); show=show+1;
    distmatrix_show( jitter_dist(desc,desc), IDX );
    
    %%% show clusters
    Iclustered = clustermontage( I2, IDX, 20, 0 );
    figure(show); show=show+1;
    if( iscuboid )
        M = makemoviesets( Iclustered );
        clipname = 'mouse';
        hf = figure;  
        movie2avi(M, [OutputDir() '\descriptors_' clipname '.avi'], 'compression', 'None');
        movie(hf,M,5,12,[0,0,0,0]);
    else
        montages( Iclustered );
    end;
