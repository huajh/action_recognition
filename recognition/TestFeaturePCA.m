
% Dimensionality reduction for cuboids descriptors.

function [cubdesc,cuboids] = TestFeaturePCA(cubdesc)

    dircontent = dir( [TestDir() '\cuboids' '_*.mat'] );
    matcontents = {'clipname','cuboids','subs'};
    n = length(dircontent);
    filenames = {dircontent.name};
    ticstatusid = ticstatus('TestFeaturePCA;',[],10 );
    for i=1:n
        S = load( [TestDir() '\' filenames{i}] );
        
        clipname = getfield(S,matcontents{1});
        cuboids = getfield(S,matcontents{2});
        subs = getfield(S,matcontents{3});
        
        desc = imagedesc( cuboids, cubdesc );
        destname = [TestDir() '/features_' clipname];
        save( destname, 'clipname', 'subs', 'desc' );
        tocstatus( ticstatusid, i/n);
    end
