% Apply spatio-temporal feature detector at a number of scales.
%
% If moviename is specified creates a movie of the detector responses.  Also calls
% makemovie_featurelocations to create a movie of the detected feature locations (after
% nonmaximal suppression).
%
% INPUTS
%   I           - MxNxK image stack to apply detector to
%   sigmas      - spatial scales
%   taus        - temporal scales
%   periodic    - if 1 uses periodic detector else uses harris detector
%   moviename   - [optional] filename to output movie to
%
% OUTPUTS
%   RS          - detector responses (M x N x K x nsigmas x ntaus)
%
% EXAMPLE
%   load example;
%   stfeatures_allscales( I, [2 4], [2 4], {1,[],20,[],2,1,0}, 'example' );

function [RS,subs_cell,vals_cell] = ...
        stfeatures_allscales( I, sigmas, taus, stfeatures_params, moviename )
    if( nargin<5) moviename=[]; end;

    %%% get responses at each spatial and temporal scale
    nsigmas = length(sigmas); ntaus = length(taus);
    subs_cell = cell(nsigmas,ntaus); vals_cell = subs_cell;
    for s=1:nsigmas
        for t=1:ntaus
            
            % run detector
            sigma=sigmas(s); tau=taus(t);
            [R,subs,vals] = stfeatures( I,sigma,tau,stfeatures_params{:});
            maxR = max(R(:));
            
            % convert R to uint8 and store
            subs_cell{s,t} = subs;  vals_cell{s,t} = vals;
            if( s==1 && t==1 ) RS=repmat(uint8(0),[size(R) nsigmas ntaus]); end;
            RS(:,:,:,s,t) = uint8(  R/maxR*255 );
        end
    end

    %%% stop here if not making movies
    if( isempty(moviename) ) return; end

    %%% construct movie of detector responses
    disp( 'Making movie of detector responses');
    siz = size(RS);
    RSflat = repmat( uint8(0), [siz(1)*nsigmas siz(2)*ntaus siz(3)] );
    for s=1:nsigmas for t=1:ntaus
        RSflat( (1+siz(1)*(s-1)):(siz(1)*s), ...
            (1+siz(2)*(t-1)):(siz(2)*t), : ) = RS(:,:,:,s,t);
    end; end; clear R;
    M = makemovie(RSflat); 
    movie2avi( M, [moviename '_responses.avi'], 'compression','Cinepak','FPS',10);   
    clear RSflat M;

    %%% make movie of detected feature locations
    name_fl =  [moviename '_featurelocations'];
    makemovie_featurelocations( I, sigmas, taus, subs_cell, name_fl, 20 );
    