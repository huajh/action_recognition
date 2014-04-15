% Laptev & Lindeberg spatiotemporal feature detector - interface through stfeatures.
%
% INPUTS
%   I       - 3D double input image
%   sigma   - spatial scale
%   tau     - temporal scale
%
% OUTPUTS
%   R       - detector strength response at each image location
%
% See also STFEATURES

function H = stfeatures_harris( I, sigma, tau )

    %%% smooth by 3d kernel and compute temporal and spatial derivatives
    I = I*255; %otherwise I becomes ill conditioned
    sigmas = [sigma sigma tau];
    L = gauss_smooth( I, sigmas, 'valid' );
    if( ndims(L)<3 ) error( 'Filters too large for image.' ); end;
    dx = [-1 0 1]; dy = dx'; dt = cat(3, cat(3,-1,0), 1);
    Lx = convn_fast(L, dx, 'same'); Lx = arraycrop2dims( Lx, size(Lx)-2 );
    Ly = convn_fast(L, dy, 'same'); Ly = arraycrop2dims( Ly, size(Ly)-2 );
    Lt = convn_fast(L, dt, 'same'); Lt = arraycrop2dims( Lt, size(Lt)-2 );
    
    %%% compute elements of second moment matrix over integration window
    %%% Would be faster if used localsum
    sigmas_i = 2*sigmas; %integration sacle=2*spatial scale
    
    Lx2 = gauss_smooth(Lx.^2,  sigmas_i, 'same'); 
    Ly2 = gauss_smooth(Ly.^2,  sigmas_i, 'same');
    Lt2 = gauss_smooth(Lt.^2,  sigmas_i, 'same');
    Lxy = gauss_smooth(Lx.*Ly, sigmas_i, 'same');
    Lxt = gauss_smooth(Lx.*Lt, sigmas_i, 'same');
    Lyt = gauss_smooth(Ly.*Lt, sigmas_i, 'same');
    
    %%% calculate determinant and trace
    det_mu = Lx2.*Ly2.*Lt2 + 2.*Lxt.*Lyt.*Lxy - 2*( Lx2.*(Lyt.^2) +Ly2.*(Lxt.^2) + Lt2.*(Lxy.^2));
    trace_mu = (Lx2 + Ly2 + Lt2 + eps);
    k=.005;  H = det_mu - k * trace_mu.^2;
    H = arraycrop2dims( H, size(I) );
    H( H<0 ) = 0;
