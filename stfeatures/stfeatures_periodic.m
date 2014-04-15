% Piotr's spatiotemporal feature detector  - interface through stfeatures.
%
% INPUTS
%   I       - 3D double input image
%   sigma   - spatial scale
%   tau     - temporal scale (must be >~1.1)
%
% OUTPUTS
%   R       - detector strength response at each image location
%
% See also STFEATURES

function Lquad = stfeatures_periodic( I, sigma, tau )
    
    %%% apply spatial filter 
    L = gauss_smooth( I, [sigma,sigma,0], 'valid' ); %*sigma; 
    
    %%% apply temporal filters and get quadrature energy
    [feven,fodd] = filter_gabor_1D(2*tau,2*tau,.5/tau);
    feven = permute( feven, [3 1 2] ); fodd = permute( fodd, [3 1 2] );  
    Leven = convn_fast( L, feven, 'valid' );
    Lodd = convn_fast( L, fodd, 'valid' );
    Lquad = Leven.^2 + Lodd.^2;
    clear L Leven Lodd feven fodd
    Lquad = arraycrop2dims( Lquad, size(I) );

    

%%% OLD VERSION OF CODE HAD OPTION FOR 
%%% ADDITIONAL SPATIAL DERIVATIVES    
%     % apply spatial filter (construct f for norm(f,1) )
%     [L,filters] = gauss_smooth( I, [sigma,sigma,0], 'valid' ); 
%     f = filters{1} * filters{2}; 
%     spderivs = [1 0]; % spderivs = [0 0];
%     dx = .5*[-1 0 1]; dy = dx'; 
%     for i=1:spderivs(1) 
%         L = convn_fast( L, dx, 'valid' );
%         f = conv2( f, dx, 'full' );
%     end
%     for i=1:spderivs(2) 
%         L = convn_fast( L, dy, 'valid' );
%         f = conv2( f, dy, 'full' );
%     end
%     L = L / norm(f(:),1); 
