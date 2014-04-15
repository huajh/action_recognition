% Get location of data; alter file depending on location of dataset.
%
% INPUTS
%   set_ind     - [optional] set index, value between 0 and nsets-1
%
% OUTPUTS
%   dir         - final directory 
%
% EXAMPLE
%   dir = getclipsdir( 'mouse00', 'features' )

function dir = datadir( set_ind )

    % root directory
    
   dir = 'F:\matlab_workspace\Behavior_Recognition\dataset\SpaceTimeActions\AdaptData';
    %dir = 'F:\matlab_workspace\Behavior_Recognition\dataset\KTH full dataset\AdaptData';
    % set index
    if( nargin==0 ) return; end;
    set_ind_str =['set' int2str2(set_ind,2)];
    dir = [dir '/' set_ind_str];
    
