% Patch descriptor based on histogrammed filter responses.
%
% Creates a descriptor for an image that is fairly robust to small perturbations of the
% image.  This differs from descimg_GRAD because instead of histograming over the smoothed
% gradient, which is essentially over the output of derivative of gaussian filters, the
% filter bank can be specified.  Factor slowdown from descimg_GRAD depends on size and
% number of filters.  
%
% INPUTS
%   I               - MxNxT double array (cuboid) with most vals in range [-1,1]
%   FB              - 2D filter bank [see above]
%   ch2params       - see imagedesc_ch2desc
%
% OUTPUTS
%   desc            - 1xp feature vector
%
% See also IMAGEDESC, DESCPATCH_GRAD, IMAGEDESC_CH2DESC

function desc = descpatch_FB( I, FB, ch2params )
    if( ndims(I)~=2 ) error('I must be MxN'); end;
    if( ~isa(I,'double') ) error('I must be of type double'); end;

    if( ch2params.histFLAG == 1 )  
        warning('descpatch_FB: multidimensional histograms out of the question.');
        ch2params.histFLAG=0; 
    end;
    
    %%% apply filters, padding first
    r = (size(FB,1)-1)/2;  
    I = padarray( I, [r r], 'replicate', 'both' );
    R = FB_apply_2D( I, FB, 'valid' );    

    %%% create SIFT histograms (histc_sift)
    desc = imagedesc_ch2desc( R, ch2params, 0, size(FB,3), 1 );
