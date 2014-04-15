% Patch descriptor based on histogrammed gradient [Lowe's SIFT descriptor].
%
% Descriptor for an image that is fairly robust to small perturbations of the
% image. 
%
% INPUTS
%   I               - MxN double image with most vals in range [-1,1]
%   sigmas          - vector of sigmas, scales at which to look at gradient
%   ch2params       - see imagedesc_ch2desc
%
% OUTPUTS
%   desc            - 1xp feature vector
%
% See also IMAGEDESC, DESCPATCH_FB, IMAGEDESC_CH2DESC

function desc = descpatch_GRAD( I, sigmas, ch2params )
    if( ndims(I)~=2 ) error('I must be MxN'); end;
    if( ~isa(I,'double') ) error('I must be of type double'); end;
    
    %%% create gradient images
    nsigmas = length(sigmas);
    for s=1:nsigmas
        L = gauss_smooth( I, [sigmas(s) sigmas(s)], 'same', 2 );
        [Gx,Gy] = gradient(L);  
        G = cat(3,Gx,Gy);
        if(s==1) GS=repmat(G,[1 1 1 nsigmas]); else GS(:,:,:,s)=G; end;
    end;

    
    %%% call imagedesc_ch2desc  
    desc = imagedesc_ch2desc( GS, ch2params, 0, 2, nsigmas );
    