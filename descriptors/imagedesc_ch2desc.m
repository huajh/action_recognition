% Helper, converts descriptor in array format to vector or histogram.
%
% Takes the multiple channel, multiple instance input and creates a descriptor by:
%   1) histFlat==-1  stringing out the channels
%   2) histFlat== 0  using nchs*ninst 1D-histograms
%   3) histFlat== 1  using ninst nch-histograms [SLOW]
%
% INPUTS
%   CHS         - mxn    x  nchs  x  ninst (if image)
%               - mxnxt  x  nchs  x  ninst (if cuboid)
%   ch2params   - STRUCT with the following fields
%           histFLAG    - if -1 string out vector, if 0 1D histograms, 1 3D histograms 
%           pargmask    - [optional] param to histc_sift (mask_gaussians)
%           edges       - [optional] param to histc_sift (histogram edges)
%   iscuboid    - should be true if cuboid, 0 otherwise [if 2d patch]
%   nch         - must specify number channels, nch [error checking]
%   ninst       - must specify number instances, ninst [error checking]

function desc = imagedesc_ch2desc( CHS, ch2params, iscuboid, nch, ninst )
    if( (iscuboid && (size(CHS,4)~=nch || size(CHS,5)~=ninst)) ...
            || (~iscuboid && (size(CHS,3)~=nch || size(CHS,4)~=ninst)) )
        error('Unsupported dimension for CHS'); end;
    histFLAG = ch2params.histFLAG;
    
    %%% string out vector, we're done
    if( histFLAG==-1 )
        desc = CHS(:)';
        return;
    end;

    pargmask = ch2params.pargmask;
    edges = ch2params.edges;

    %%% 3D histograms out of the question
    if( histFLAG == 1 && nch>3 )  
        warning('imagedesc_ch2desc: multidimensional histograms out of the question.');
        histFLAG=0; 
    end;    
    
    
    %%% 1D histograms;  regardless, for each ch, each inst create 1 histogram
    if( histFLAG==0 || (nch==1))
        siz=size(CHS); 
        if( iscuboid ) 
            CHS=reshape(CHS,siz(1),siz(2),siz(3),[]); 
            ninst = size(CHS,4);
        else 
            CHS=reshape(CHS,siz(1),siz(2),[]); 
            ninst = size(CHS,3);
        end
        if( ninst>1 )
            hs = feval_arrays( CHS, @histc_sift, edges, pargmask ); 
        else
            hs = histc_sift( CHS, edges, pargmask );
        end
        desc = hs(:)'; 
        return;
    end;
    
    %%% 3D histograms;  
    if( ninst>1 )
        hs = feval_arrays( CHS, @histc_sift_nD, edges, pargmask ); 
    else
        hs = histc_sift_nD( CHS, edges, pargmask );
    end
    desc=hs(:)';
    return;
    
    
    