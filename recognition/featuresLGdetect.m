% Detects features for each set of cuboids using stfeatures.
%    clip_[activity].mat -->  features_[activity].mat
%
% Loads each clip_[activity].mat, detects features, then saves result to
% cuboids_[activity].mat.  Each original mat file should contain the fields: 'I',
% 'clipname' and 'cliptype', the resulting mat file will contain the fields: 'clipname',
% 'cliptype', 'cuboids', 'subs'.
%
% INPUTS
%   nsets           - number of sets
%   cliptypes       - types of clips (cell of strings)
%   par_stfeature   - parameters for feature detection, see stfeatures
%
% See also FEATURESLG, STFEATURES, FEATURESSMDETECT

function featuresLGdetect( nsets, cliptypes, par_stfeatures )
    for s=0:(nsets-1)
        srcdir = datadir(s);
        matcontents = {'I','clipname','cliptype'};  
        params = {srcdir,par_stfeatures,cliptypes};
        feval_mats( @featuresLGdetect1, matcontents, params, srcdir, 'clip' );
    end;
        
    
function x = featuresLGdetect1( vals, params ) 
    [I, clipname, cliptype] = deal( vals{:} );
    [destdir,par_stfeatures,cliptypes] = deal( params{:} );

    % check if known cliptype 
    if( ~ismember( cliptype, cliptypes ) )
        error( ['Unrecognized type: ' cliptype ' for ' clipname]); end;        

    % apply feature detector
    I=padarray(I,[5 5 15],'both','replicate'); %small/short clips, pad!
    [d,subs,d,cuboids] = stfeatures( I,par_stfeatures{:}); 
    
    % save results
    destname = [destdir '/cuboids_' clipname];
    save( destname, 'clipname', 'cliptype', 'cuboids', 'subs' );
    x=[];