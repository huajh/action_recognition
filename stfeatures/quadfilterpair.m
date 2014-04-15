% Used to show the filters used by stfeatures_periodic.
%
% EXAMPLE
%   quadfilterpair

function quadfilterpair

    %%% make 1D gabor filtesr
    tau=12.5;
    [fev,fod] = filter_gabor_1D(5*tau,2*tau,.5/tau,0);

    %%% show 1D gabor filters
    figure(1); clf; hold on; 
    r = (length(fev)-1)/2;
    plot(-r:r, fod, 'b');  plot(-r:r, fev, '--k'); 
    axis tight; axis off; 
    legend('odd','even');
    h = line( xlim, [0 0]); set(h,'Color','k')
    h = line( [0 0], ylim); set(h,'Color','k')
    %plot(-r:r, sqrt(fev.^2+fod.^2), '.-'); %gaussian!
    
    %%% make 3D quadpair filters, store result in F
    fev = permute( fev, [3 1 2] ); 
    fod = permute( fod, [3 1 2] );  
    Fev = gauss_smooth( fev, [5,5,0] );
    Fod = gauss_smooth( fod, [5,5,0] );    
    Fev = arraycrop2dims( Fev, size(Fev)+6 );
    Fod = arraycrop2dims( Fod, size(Fod)+6 );
    F = cat(2,Fev,Fod); % top filter will be odd

    %%% show 3D quadpair filtres
    figure(2); clf; filter_visualize_3D( F, .05 );
