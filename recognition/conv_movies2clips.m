% Converts between representations of behavior (mat -> avi).
%
% See RECOGNITION_DEMO for general info.
%   [datadir(set_ind)/namei.avi] --> [datadir(set_ind)/clip_namei.mat]
%
% INPUTS
%   set_ind     - set index, value between 0 and nsets-1
%
% See also RECOGNITION_DEMO, CONV_MOVIES2DIVX, CONV_CLIPS2MOVIES

function conv_movies2clips( set_ind )
    srcdir = datadir(set_ind);
    dircontent = dir( [srcdir '\*.avi'] );
    nfiles = length(dircontent);
    if(nfiles==0) 
        warning('No avi files found.'); 
        return; 
    end;
    ticstatusid = ticstatus('converting movies to clips');
    for i=1:nfiles
        fname = dircontent(i).name;
        Mobj = VideoReader( [srcdir '\' fname]); %replace             
        I = movie2images(Mobj);
        clipname = fname(1:end-4);
        mark = strfind(clipname,'_');        
        %cliptype = clipname(mark(1)+1:end);        
        cliptype = clipname(mark(1)+1:mark(2)-1);
        save( [srcdir '\clip_' clipname '.mat'], 'I', 'clipname', 'cliptype' );
        tocstatus( ticstatusid, i/nfiles );
    end;
