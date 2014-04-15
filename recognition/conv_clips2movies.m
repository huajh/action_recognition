% Converts between representations of behavior (avi -> mat).
%
% See RECOGNITION_DEMO for general info.
%   [datadir(set_ind)/namei.mat] --> [datadir(set_ind)/namei.avi]
%
% INPUTS
%   set_ind     - set index, value between 0 and nsets-1
%   maskflag    - [optional] apply gaussian mask to resulting video.  
%                 Applicable only if 'C' and 'mu' specified in each .mat file.
%                 
% See also RECOGNITION_DEMO, CONV_MOVIES2CLIPS

function conv_clips2movies( set_ind, maskflag )
    if( nargin<2 ) maskflag = 0; end;
    
    % get src and dest directoreies
    srcdir = datadir(set_ind);
        
    % make movies from all mat files
    if( maskflag )
        matcontents = {'I','clipname','C','mu'}; %'cliptype',
    else
        matcontents = {'I','clipname'}; %'cliptype',
    end
    params = {srcdir,maskflag};
    feval_mats( @clips2movies1, matcontents, params, srcdir, 'clip' );
    

function x = clips2movies1( vals, params ) 
    [destdir,maskflag] = deal( params{:} );
    if( maskflag )
        [I, clipname, C, mu] = deal( vals{:} );
    else
        [I, clipname] = deal( vals{:} );
    end;
    
    if( maskflag )
        mask = I; [m n t]=size(I);  
        for i=1:t  mask(:,:,i)=mask_ellipse(m,n,mu(i,:),C(:,:,i),3);  end;
        I = I.*mask;
        moviename = [destdir '/' 'M' clipname];    
    else 
        moviename = [destdir '/' clipname];    
    end;

    siz=[size(I,1)-mod(size(I,1),2), size(I,2)-mod(size(I,2),4), size(I,3)];
    I=arraycrop2dims(I,siz);
            
    M = makemovie( I ); 
    movie2avi( M, moviename,'compression','None','FPS',15); %else Cinepak
    x=[];
