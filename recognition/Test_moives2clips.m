function Test_moives2clips()

    dircontent = dir( [TestDir() '\*.avi'] );    
    nfiles = length(dircontent);
    if(nfiles==0) 
        warning('No avi files found.'); 
        return; 
    end;
    ticstatusid = ticstatus('converting movies to clips');
    for i=1:nfiles
        fname = dircontent(i).name;
        Mobj = VideoReader( [TestDir() '\' fname]); %replace             
        I = movie2images(Mobj);         
        for j=1:size(I,3)
            % bilinear
            subI(:,:,j) = imresize(I(:,:,j),200/432,'bilinear');            
        end
        I = subI;
        clear subI;
        clipname = fname(1:end-4);
        save( [TestDir() '\clip_' clipname '.mat'], 'I','clipname');
        tocstatus( ticstatusid, i/nfiles );
    end;

end
