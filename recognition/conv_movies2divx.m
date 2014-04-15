% Converts between representations of behavior (avi -> compressed avi).
%
% See RECOGNITION_DEMO for general info.
%   [datadir(set_ind)/namei.mat] --> [datadir(set_ind)_divx/namei.avi]
%
% Requires VirtualDub to be installed.  Set path to VirutalDub accordingly, also set up
% VirutalDub option appropriately.   See http://www.virtualdub.org/
% 
% INPUTS
%   set_ind     - set index, value between 0 and nsets-1
%
% See also RECOGNITION_DEMO, CONV_MOVIES2CLIPS

function conv_movies2divx( set_ind )
    virtualdub = 'c:\progra~1\virtua~1\VirtualDub';

    % get src and dest directoreies
    srcdir = datadir(set_ind);
    destdir = [datadir(set_ind) '_divx'];
    if(~exist(destdir,'dir')) mkdir( destdir ); end;
  
    % assumes that virtualDub is installed in directory specified, and that 
    % convert2divx.vcf is in current directory
    str=[virtualdub ' /s "convert2divx.vcf" /c /b "' srcdir '", "' destdir '" /r /x' ];
    system(str);
