% Cuboid descriptor that is a combination of 'who' doing 'what'.  
%
% Concatenates descriptor of first, middle, and last frame with motion 
% descriptor of cuboid.
%
% INPUTS
%   I               - MxNxT double array (cuboid) with most vals in range [-1,1]
%   who_imdesc      - frame appearance descriptor
%   what_desc       - cuboid motion descriptor
%   whoweight       - multiplier for frame appearance importance [0 and inf are special]
%
% OUTPUTS
%   desc            - 1xp feature vector
%
% See also IMAGEDESC, IMAGEDESC_CH2DESC

function desc = desccuboid_WW( I, who_imdesc, what_imdesc, whoweight )
    if( ndims(I)~=3 ) error('I must be MxNxT'); end;
    if( ~isa(I,'double') ) error('I must be of type double'); end;
    
    if(isfield(who_imdesc,'par_jitter')) error('NOT IMPLEMENTED'); end
    if( who_imdesc.iscuboid || ~what_imdesc.iscuboid )
        error('who is for images what is for videos'); end;
    
    %%% first get WHO descriptor 
    if( whoweight~=0 )
        mframe = round(size(I,3)/2);
        descwho1 = imagedesc( I(:,:,1), who_imdesc ); 
        descwho2 = imagedesc( I(:,:,mframe), who_imdesc ); 
        descwho3 = imagedesc( I(:,:,end), who_imdesc ); 
        descwho = [descwho1 descwho2 descwho3];
        descwho = descwho/sum(descwho);
    end;
    
    
    %%% now get WHAT descriptor
    if( whoweight~=inf )
        descwhat = imagedesc( I, what_imdesc ); 
        descwhat = descwhat/sum(descwhat);
    end

    %%% now combine WHO and WHAT
    if( whoweight==0 )
        desc=descwhat;
    elseif( whoweight==inf )
        desc=descwho;
    else
        desc=[descwho*whoweight descwhat];
    end;
    
