% Cuboid descriptor based on histogrammed gradient.
%
% Adaptation of Lowe's SIFT descriptor for cuboids.  Creates a descriptor for an cuboid
% that is fairly robust to small perturbations of the cuboid.  No histogramming (if
% histflag==-1) See "PCA-SIFT: A More Distinctive Representation for Local Image
% Descriptors" by Yan Ke for why this might be a good idea. Should not be called directly,
% instead use imagedesc.
%
% INPUTS
%   I               - MxNxT double array (cuboid) with most vals in range [-1,1]
%   sigmas          - n-element vector of spatial scales at which to look at gradient
%   taus            - n-element vector of temporal scales at which to look at gradient
%   ch2params       - see imagedesc_ch2desc
%   ignGt           - if 1 the temporal gradient is ignored
%
% OUTPUTS
%   desc            - 1xp feature vector, where p=n*prod(size(cuboid))
%
% See also IMAGEDESC, IMAGEDESC_CH2DESC


function desc = desccuboid_GRAD( I, sigmas, taus, ch2params, ignGt )
    if( ndims(I)~=3 ) error('I must be MxNxT'); end;
    if( ~isa(I,'double') ) error('I must be of type double'); end;

    %%% create gradient images
    nsigmas = length(sigmas);
    for s=1:nsigmas
        L = gauss_smooth( I, [sigmas(s) sigmas(s) taus(s)], 'same', 2 );
        [Gx,Gy,Gz] = gradient(L);  
        G = cat(4,Gx,Gy);  if(~ignGt) G=cat(4,G,Gz); end;
        if(s==1) GS=repmat(G,[1 1 1 1 nsigmas]); else GS(:,:,:,:,s)=G; end;            
    end;

    %%% call imagedesc_ch2desc  
    if( ignGt ) nch=2;  else  nch=3;  end;
    desc = imagedesc_ch2desc( GS, ch2params, 1, nch, nsigmas );
    