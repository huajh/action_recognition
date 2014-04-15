% Cuboid descriptor based on histogrammed brightness values.
%
% INPUTS
%   I               - MxNxT double array (cuboid) with most vals in range [-1,1]
%   sigmas          - vector of spatial scales at which to look at gradient
%   taus            - vector of temporal scales at which to look at gradient
%   ch2params       - see imagedesc_ch2desc
%
% OUTPUTS
%   desc            - 1xp feature vector
%
% See also IMAGEDESC,IMAGEDESC_CH2DESC

function desc = desccuboid_APR( I, sigmas, taus, ch2params )
    if( ndims(I)~=3 ) error('I must be MxNxT'); end;
    if( ~isa(I,'double') ) error('I must be of type double'); end;

    %%% create smoothed images
    nsigmas = length(sigmas);
    for s=1:nsigmas
        L = gauss_smooth( I, [sigmas(s) sigmas(s) taus(s)], 'same', 2 ); 
        if(s==1) LS=repmat(L,[1 1 1 1 nsigmas]); else LS(:,:,:,:,s)=L; end;
    end;

    %%% call imagedesc_ch2desc  [will always have 1 channel!]
    desc = imagedesc_ch2desc( LS, ch2params, 1, 1, nsigmas );
    