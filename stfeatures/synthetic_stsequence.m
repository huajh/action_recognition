% Simple synthetic sequences for feature detection.
%
% Adapted from code by Ivan Laptev.
%
% INPUTS
%   siz     - video will be siz x siz x siz
%   type    - switch
%               1 - corner moving up down
%               2 - two circles meet each other
%               3 - a circle moving against the wall
%               4 - spatio-temporal oscilations with increasing frequence
%
% EXAMPLE
%  f = synthetic_stsequence( 25, 1 ); playmovie( f, 0 );

function f=synthetic_stsequence( sz, type )

    switch(type)
        case 1
            img=256*ones(2*sz,sz);
            for i=1:floor(sz/2)
              img(i,i:end-i)=0;
            end

            f=ones(sz,sz,sz);
            ind=1+abs(-floor(sz/2):floor(sz/2));
            for i=1:sz
              f(:,:,i)=img(ind(i):(ind(i)+sz-1),:);
            end
        case 2
            [x,y]=meshgrid(1:2*sz,1:sz);
            r=floor(sz/12);
            img=256*(((y-floor(sz/2)).^2+(x-sz).^2)>(r^2));

            f=256*ones(sz,sz,sz);
            for i=1:sz
              f(:,:,i)=(img(:,sz+1-i:2*sz-i)&img(:,i:i+sz-1))*256;
            end
        case 3
            [x,y]=meshgrid(1:2*sz,1:sz);
            r=floor(sz/12);
            img1=((y-floor(sz/2)).^2+(x-sz).^2)>(r^2);
            img2=ones(sz,sz);
            img2(:,floor(2*sz/3):sz)=0;

            f=256*ones(sz,sz,sz);
            for i=1:sz
              f(:,:,i)=(img1(:,sz+1-i:2*sz-i)&img2)*256;
            end            
        case 4
            [x,y]=meshgrid(linspace(0.8,0.6*pi,sz),linspace(0.8,0.6*pi,sz));
            img=sin(x.^4).*sin(y.^4);
            f=ones(sz,sz,sz);
            for i=1:sz
              f(i,:,:)=256*(img>(-1.5+3*i/sz));
            end
        otherwise 
            error('Unknown type');
    end;