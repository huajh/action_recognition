% Runs descriptor on a subset of cuboids or images to get PCA coefficients.
%
% INPUTS
%   I               - 3D array of images or 4D array of cuboids
%   imdesc          - descriptor to apply to each image or cuboid
%   k               - number of PCA coefficients to use [note: k can be later reduced]
% 
% OUTPUTS
%   imdesc          - new imdesc with PCA information

function imdesc = imagedesc_getpca( I, imdesc, k, show )
    if( nargin<4 || isempty(show))  show=[]; end;
    nd=ndims(I);  inds={':'};  inds=inds(:,ones(1,nd-1));   
    iscuboid = imdesc.iscuboid;
    if( (iscuboid && nd~=4) || (~iscuboid && nd~=3) )
        error('Unsupported dimension for I'); end;
    if(isfield(imdesc,'par_pca')) imdesc.par_pca=[];
        warning('Removing old PCA info'); end;
    
    % get number of bytes per descriptor / I, sample I in proportion
    desc = imagedesc( I(inds{:},1), imdesc ,show);
    s1=whos('desc'); I1=I(inds{:},1); s2=whos('I1');
    ratio = s1.bytes / s2.bytes;  oldn = size(I,nd);   
    I = randomsample( I, 80/ratio );  n=size(I,nd); %val here should reflect val in pca
    if(n>k*30) rperm=randperm(n); I=I(inds{:},rperm(1:(k*30))); end; n=size(I,nd);
    if( n~=oldn ) 
        disp( ['Sampled I from ' int2str(oldn) ' to ' int2str(n) ' elements.']); end;

    % get descriptors
    desc = imagedesc( I, imdesc,show );
    
    % ignore jitter if there is jitter.
    if( size(desc,3)>1 ) 
        desc = reshape( permute( desc, [1 3 2] ), [], size(desc,2) ); end;

    % run pca
	[ par_pca{1}, par_pca{2}, par_pca{3} ] = pca( desc' ); 
    
    % optionally show
    show = 1;
    if( show ) figure(show); show=show+1; plot( par_pca{3} ); end;
    
    % set k
    k = min( k, size(par_pca{1},2) ); 
    par_pca{1} = par_pca{1}(:,1:k); %save on memory
	par_pca{4} = k;
    imdesc.par_pca = par_pca;
