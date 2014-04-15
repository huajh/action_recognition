
% Dimensionality reduction for cuboids descriptors.

function [cubdesc,cuboids] = TestFeaturePCA2(cubdesc,kpca)
    show = 1;
    dircontent = dir( [TestDir() '\cuboids' '_*.mat'] );
    matcontents = {'clipname','cuboids','subs'};
    n = length(dircontent);
    filenames = {dircontent.name};
    ticstatusid = ticstatus('TestFeaturePCA2;',[],10 );
    for i=1:n
        S = load( [TestDir() '\' filenames{i}] );
        
        clipname = getfield(S,matcontents{1});
        cuboids = getfield(S,matcontents{2});
        subs = getfield(S,matcontents{3});
        cubdesc = imagedesc_getpca( cuboids, cubdesc, kpca, show);        
        desc = imagedesc( cuboids, cubdesc );
        destname = [TestDir() '/features_' clipname];
        save( destname, 'clipname', 'subs', 'desc' );
        tocstatus( ticstatusid, i/n);
    end
