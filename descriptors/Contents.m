% CUBOIDS/DESCRIPTORS
% See also
%
% Interface to descriptors for patches and cuboids.
%   imagedesc          - Runs descriptor on a set of images, optionally jitters, and optionally applies PCA.
%   imagedesc_generate - Generate parameters for image or cuboid descriptor.
%   imagedesc_demo     - Demo to show how imagedesc works.
%
% Descriptors for images and cuboids.
%   descpatch_GRAD     - Patch descriptor based on histogrammed gradient [Lowe's SIFT descriptor].
%   descpatch_FB       - Patch descriptor based on histogrammed filter responses.
%   desccuboid_APR     - Cuboid descriptor based on histogrammed brightness values.
%   desccuboid_FLOW    - Cuboid descriptor based on histogrammed optical flow.
%   desccuboid_GRAD    - Cuboid descriptor based on histogrammed gradient.
%   desccuboid_IMDESC  - Cuboid descriptor based on a concatentation of the types of frames present.
%   desccuboid_WW      - Cuboid descriptor that is a combination of 'who' doing 'what'.  
%
% Helper functions to descriptors.
%   imagedesc_getpca   - Runs descriptor on a subset of cuboids or images to get PCA coefficients.
%   imagedesc2clusters - Assignment of descriptors to clusters. 
%   imagedesc_ch2desc  - Helper, converts descriptor in array format to vector or histogram.
%
% Add jitter to descriptors and distance measures.
%   jitter_dist        - Calculates the minumum distance between two sets of possibly 'jittered' feature vectors.
%   jitter_kmeans      - Version of kmeans that allows for jittered vectors.
%   jitter_rectify     - Post processing for jitter_kmeans.

