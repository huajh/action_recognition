% Runs descriptor on a set of images, optionally jitters, and optionally applies PCA.
%
% Parameters are passed in w struct imdesc.  Use imagedesc_generate to quickly generate
% this struct. 
%
% If clusters (and optionally csigma) are provided, imagedesc2clusters is applied to each
% resulting desc (giving a new descriptor).  See imagedesc2clusters for more information.
%
% INPUTS
%   I               - 2D or 3D array of images, or 3D or 4D array of cuboids
%   imdesc          - struct containing the following fields:
%       iscuboid        - specifies whether desc is designed for image or cuboid
%       fun_desc        - (fhandle) descriptor to apply to each image or cuboid
%       par_desc        - parameters for above descriptor
%       par_jitter      - [optional] parameters for jittering images or cuboids
%       par_pca         - [optional] parameters for PCA to reduce dim of descriptor
%       clusters        - [optional] see imagedesc2clusters 
%       csigma          - [optional] see imagedesc2clusters 
%   show            - [optional] figure to use for display (no display if == 0)
%   
% OUTPUTS
%   desc        - nxpxr array of n p-dimensional descriptors, r jittered versions of each
%               - nxp array if par_jitter is not given or clusters is given
%
% See also IMAGEDESC_GENERATE, IMAGEDESC_DEMO, IMAGEDESC2CLUSTERS

function desc = imagedesc( I, imdesc, show )
    if( isempty(I) ) desc=[]; return; end;
    if( nargin<3 || isempty(show))  show=[]; end;    
    if(~isfield(imdesc,'iscuboid') || ~isfield(imdesc,'fun_desc') || ...
                        ~isfield(imdesc,'par_desc') )
        error('imdesc lacking crucial field.'); end;
    if(~isfield(imdesc,'par_jitter')) imdesc.par_jitter={}; end;
    if(~isfield(imdesc,'par_pca')) imdesc.par_pca={}; end;
    if(~isfield(imdesc,'clusters')) imdesc.clusters={}; end;
    if(~isfield(imdesc,'csigma')) imdesc.csigma={}; end;
    
    %%% some checking of dimension
    nd=ndims(I);  iscuboid = imdesc.iscuboid;
    if( (iscuboid && nd~=3 && nd~=4) || (~iscuboid && nd~=2 && nd~=3))
        error('Unsupported dimension for I'); end;
    
    %%% convert to double between [-1,1] unless uint8 in which case do nothing
    %if(~isa(I,'uint8') && ~isa(I,'double')) 
    %    I=double(I); end;
    %if( isa(I,'double') && abs(max(I(:)))>1 ) 
    %    I=I-min(I(:));  I=I/(max(I(:))/2)-1; end;
    
    %%% apply discriptor, should give nxp or nxpxr vector, where n=size(I,3);
    if( (nd==2 && ~iscuboid) || (nd==3 && iscuboid))
        desc = imagedesc1( I, imdesc );
    else
        desc = feval_arrays( I, @imagedesc1, imdesc );
        dnd=ndims(desc); desc=permute(desc,[dnd 2:(dnd-1) 1]);
    end

    % optionally show
    if( show )
        Deuc = jitter_dist(desc,desc);
        figure(show); show=show+1; im( Deuc ); 
        title( func2str(imdesc.fun_desc) );
    end
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Apply descriptor to a single image.
% Returns desc which is either 1xp or 1xpxr
function desc = imagedesc1( I, imdesc )
    I = imnormalize(I,1)/4; % similar to blow normalization, most vals fall between [-1,1]
    %if( isa(I,'uint8') ) I = double(I)/255 * 2 -1; end;
    
    par_jitter = imdesc.par_jitter;
    clusters = imdesc.clusters; csigma = imdesc.csigma;
    
    if( isempty(par_jitter) ) % no jitter
        desc = imdesc.fun_desc( I, imdesc.par_desc{:} ); % apply basic descriptor
        if( size(desc,1)~=1 || ndims(desc)~=2 ) 
            error(['desc returned by ' func2str(imdesc.fun_desc) ' is not 1xp']); end
        if( ~isempty(imdesc.par_pca) ) % apply PCA
            desc=pca_apply( desc', imdesc.par_pca{:} )'; end;
        if( ~isempty(clusters) ) % apply clustering
            desc=imagedesc2clusters(desc,clusters,csigma); end;
        
    else % jitter, apply descriptor recursively to each 
        imdesc.par_jitter={}; clusters=imdesc.clusters;  imdesc.clusters=[];
        if( ndims(I)==2 )
            %warning off; IJT = jitter_image( I, par_jitter{:}, size(I) ); warning on;
            IJT = jitter_image( I, par_jitter{:} );
        else
            IJT = jitter_video( I, par_jitter{:} );            
        end
        
        % run imagedesc1 recursively on each image, for efficiency no use feval_arrays 
        nd=ndims(IJT);  siz = size(IJT);  r=siz(end);
        inds={':'};  inds=inds(:,ones(1,nd-1));   
        desc = repmat( imagedesc1(IJT(inds{:},1),imdesc), [1 1 r] );
        for i=2:r desc(1,:,i)=imagedesc1(IJT(inds{:},i),imdesc); end;
        if( ~isempty(clusters) ) % apply clustering 
            desc=imagedesc2clusters(desc,clusters,csigma); end;
    end;
    

    
    
    
    