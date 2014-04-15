
    ccc;
    dircontent = dir( [TestDir() '\*.avi'] );    
    nfiles = length(dircontent);
    if(nfiles==0) 
        warning('No avi files found.'); 
        return; 
    end;
    ticstatusid = ticstatus('Create My movie');
    Movs = [];
    start = 1;
    for i=1:nfiles
        fname = dircontent(i).name;
        Mobj = VideoReader( [TestDir() '\' fname]); %replace                     
        nFrames = Mobj.NumberOfFrames;
        vidHeight = Mobj.Height;
        vidWidth = Mobj.Width;    
        mov(1:nFrames) = ...
        struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
           'colormap', []);
        for k = 1 : nFrames
            mov(k).cdata = read(Mobj, k);
        end
        Movs = [Movs,mov];
        clear mov;
        tocstatus( ticstatusid, i/nfiles );
    end;
        
    
    hf = figure;    
    movie2avi(Movs, [OutputDir() '\Synthesis\orignal_Ours_Moive.avi'], 'compression', 'None');
    movie(hf,Movs,5,12,[0,0,0,0]);
