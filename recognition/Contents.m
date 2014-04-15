% CUBOIDS/RECOGNITION 
% See also
%
% Demo
%   recognition_demo    - Describes all steps of behavior recognition; example for facial expressions.
%   datadir             - Get location of data; alter file depending on location of dataset.
%
% Feature detection and description.
%   featuresLG          - Feature detection and description applied to .mat behavior data. 
%   featuresLGconv      - Convert features to DATASETS format so output is same as after featuresSM.
%   featuresLGdesc      - Applies descriptor to every cuboid of every clip of every set.
%   featuresLGdetect    - Detects features for each set of cuboids using stfeatures.
%   featuresLGpca       - Dimensionality reduction for cuboids descriptors.
%   featuresSM          - Feature detection and description applied to DATASETS behavior data. 
%   featuresSMdesc      - Applies descriptor to every cuboid of every clip of every set.
%   featuresSMdetect    - Detects features for each set of cuboids using stfeatures.
%   featuresSMpca       - Dimensionality reduction for cuboids descriptors.
%
% Conversion between various data formats.
%   conv_clips2datasets - Converts between representations of behavior (mat -> DATASETS).
%   conv_clips2movies   - Converts between representations of behavior (avi -> mat).
%   conv_datasets2clips - Converts between representations of behavior (DATASETS -> mat).
%   conv_movies2clips   - Converts between representations of behavior (mat -> avi).
%   conv_movies2divx    - Converts between representations of behavior (avi -> compressed avi).
%
% Classification.
%   recog_clipdesc      - Creates a clip descriptor that is simply a histogram of cuboids present. 
%   recog_clipsdesc     - Create descriptor of every clip.
%   recog_cluster       - Clusters all cuboids in DATASETS (based on their descriptions).
%   recog_test          - Test the performance of behavior recognition using the cuboid representation.
%   recog_test_nfold    - Test the performance of behavior recognition using cross validation.





