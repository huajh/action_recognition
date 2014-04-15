
function TestFeatureDetect(cliptypes, par_stfeatures )

    dircontent = dir( [TestDir() '\clip' '_*.mat'] );
    matcontents = {'I','clipname'};
    n = length(dircontent);
    filenames = {dircontent.name};
     ticstatusid = ticstatus('TestFeatureDetect;',[],10 );
    for i=1:n
        S = load( [TestDir() '\' filenames{i}] );
        I = getfield(S,matcontents{1});
        clipname = getfield(S,matcontents{2});

        % apply feature detector
        I=padarray(I,[5 5 15],'both','replicate'); %small/short clips, pad!
        [d,subs,d,cuboids] = stfeatures( I,par_stfeatures{:}); 
        featuresize = size(subs,1)
        % save results
        destname = [TestDir() '/cuboids_' clipname];
        save( destname, 'clipname', 'cuboids', 'subs' );
        tocstatus( ticstatusid, i/n);
    end