% Cuboid descriptor based on histogrammed optical flow.
%
% INPUTS
%   I               - MxNxT double array (cuboid) with most vals in range [-1,1]
%   flow_params     - paramters for lucaskanade optical flow (see optflow_lucaskanade)
%   ch2params       - see imagedesc_ch2desc
%
% OUTPUTS
%   desc            - 1xp feature vector
%
% See also IMAGEDESC, OPTFLOW_LUCASKANADE, IMAGEDESC_CH2DESC

function desc = desccuboid_FLOW( I, flow_params, ch2params )
    if( ndims(I)~=3 ) error('I must be MxNxT'); end;
    if( ~isa(I,'double') ) error('I must be of type double'); end;

    %%% get optical flow in channels
    siz = size(I);  nframes = siz(3);  I = (I+1)/2;
    Fx=zeros([siz(1:2) nframes-1]);  Fy=Fx;  reliab=Fx;  
    for i=1:nframes-1
        [Fx(:,:,i),Fy(:,:,i),reliab(:,:,i)] = ...
                optflow_lucaskanade(I(:,:,i),I(:,:,i+1),flow_params{:});
    end;
    F=cat(4,Fx,Fy);

    %%% call imagedesc_ch2desc  [will always have 2 channel, 1 instance!]
    desc = imagedesc_ch2desc( F, ch2params, 1, 2, 1 );
