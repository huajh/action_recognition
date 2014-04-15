% Interface to spatio-temporal feature detectors.
%
% Wrapper for stfeatures detectors that first shrinks I and then resizes outputs
% appropriately.  It also applies nonmaximal supression and finds local maxima of detector
% output.  
%
% INPUTS
%   I           - 3D uint (or double) array - input video
%   sigma       - spatial scale
%   tau         - temporal scale
%   periodic    - if 1 uses periodic detector else uses harris detector
%   thresh      - [optional] abolute threshold for features strength
%   maxn        - [optional] maximum number of featrues (alternative to thresh)
%   overlap_r   - [optional] controls amount of overlap between cuboids, range: [0,2)
%                 (0 -> no overlap, 2 -> minimal restriction on overlap; 1.7 -> default )
%   show        - [optional] figure to use for display (no display if == 0)
%   shr_spt     - [optional] spatial shrink factor.  Must be integer>1
%   tau_spt     - [optional] temporal shrink factor.  Must be integer>1
%
% OUTPUTS
%   R       - detector strength response at each image location
%   subs    - detected features locations    
%   vals    - relative feature strengths
%   cuboids - the detected cuboids (size depends on sigma/tau)
%   V       - location of responses visualization
%
% EXAMPLE
%   load example;
%   [R,subs,vals,cuboids,V] = stfeatures( I, 2, 3, 1, 2e-4, [], 1.85, 2, 1, 1 );
%   [R,subs,vals,cuboids,V] = stfeatures( I, 2, 3, 0, eps, [], 1.85, 2, 1, 5 );
%
% See also STFEATURES_HARRIS, STFEATURES_PERIODIC, NONMAXSUPR_WINDOW

function [R,subs,vals,cuboids,V] = stfeatures( I, sigma, tau, periodic, thresh, maxn, ...
                                   overlap_r, shr_spt, shr_tmp, show )
                                    
    if( ndims(I)~=3 ) error('I must a MxNxK array'); end;
    if( nargin<5 || isempty(thresh)) thresh=eps; end;  
    if( nargin<6 || isempty(maxn)) maxn=-1; end;  
    if( nargin<7 || isempty(overlap_r)) overlap_r=1.7; end;
    if( nargin<8 || isempty(shr_spt)) shr_spt=1; end;
    if( nargin<9 || isempty(shr_tmp)) shr_tmp=1; end;
    if( nargin<10 || isempty(show)) show=0; end;
    thresh = max( thresh, eps );
    
    %if( isempty(cuboids_rs) ) % pad a bit for filtering etc.
    cuboids_rs = ceil( [sigma*3 sigma*3 tau*3] );  %#P

    %%% shrink I [creat I_sm]
    if( show ) disp('Shrink Image'); end;
    shrink_all = [shr_spt shr_spt shr_tmp];
    I_sm = imshrink( I, shrink_all ); 
    sigma_sm = sigma / shr_spt;
    tau_sm = tau / shr_tmp;    
    cuboids_rs_sm = ceil([cuboids_rs(1:2)/shr_spt, cuboids_rs(3)/shr_tmp]);

    %%% convert I_sm to double in range [-1,1]
    if( isa(I_sm,'uint8') ) I_sm = double(I_sm)/255 * 2 -1; end
    if( ~isa(I_sm,'double') ) I_sm = double(I_sm); end
    if( max(abs(I_sm(:)))>1 ) I_sm=I_sm-min(I_sm(:)); I_sm=I_sm/(max(I_sm(:))/2) - 1; end;

    %%% apply feature extraction  
    if( show ) disp('Apply feature detector'); end;
    if( periodic )
        R = stfeatures_periodic( I_sm, sigma_sm, tau_sm );
    else
        R = stfeatures_harris( I_sm, sigma_sm, tau_sm );
    end;
    
    %%% Apply nonmaximal suppression, resize subs appropriately.  Note that
    %%% cuboids_rs_sm is an approximation, so we use cuboids_rs for actual suppression
    if( nargout<3 && show==0 ) return; end;
    if( show ) disp( 'Apply nonmaximal supression'); end
    suprradii_sm = max(1,ceil(cuboids_rs_sm*(2-overlap_r)));
    [subs_sm, vals] = nonmaxsupr( R, suprradii_sm, thresh );    
    subs = round( imsubs_resize( subs_sm, shrink_all ) );
    [subs, vals] = nonmaxsupr_window( subs,vals,1+cuboids_rs,size(I)-cuboids_rs,[],maxn);
    subs_sm = round( imsubs_resize( subs, 1./shrink_all ) );

    %%% extract cuboids
    if( nargout<4 && show==0 ) return; end;
    if( length(subs)==0 ) cuboids=[]; return; end;
    cuboids = cell2array( cuboid_extract( I, cuboids_rs, subs, 0 ) ); 
    if( nargout<5 && show==0 ) return; end;
    
    [V,imasked] = cuboid_display( I_sm, cuboids_rs_sm, subs_sm,show ); %%
    
    %%% optionally display
    
    if( 0 ) 
        disp( ['Create visualization; ' num2str(size(vals,1)) ' features' ]);
        figure(show); clf; montage2( I_sm,1 );
        figure(show+1); clf; montage2( R,1,1 ); colormap jet;
        figure(show+2); clf; montage2( V,1,1  );
        figure(show+3); clf; montages2( cuboids, {1} );
    end;
    
    