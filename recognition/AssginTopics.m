function AssginTopics(CodeProb, CodeIDX, Cluster_Centers)
    csigma = 0;
    dircontent = dir( [TestDir() '\features_*.mat'] );
    matcontents = {'clipname', 'subs', 'desc'};
    n = length(dircontent);
    filenames = {dircontent.name};
    ticstatusid = ticstatus('AssginTopics;',[],10 );
    for i=1:n
        S = load( [TestDir() '\' filenames{i}] );        
        clipname = getfield(S,matcontents{1});
        subs = getfield(S,matcontents{2});
        desc = getfield(S,matcontents{3});
        assigned_hist_idx = imagedesc2clusters( desc, Cluster_Centers, csigma );
        action_idx = CodeIDX(assigned_hist_idx');
        destname = [TestDir() '/features_' clipname];
        save( destname, 'clipname', 'subs', 'desc','action_idx','assigned_hist_idx');
        tocstatus( ticstatusid, i/n );
    end
