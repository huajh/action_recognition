
clear;clc;
close all;

rng(1); % For reproducibility
r = sqrt(rand(100,1)); % Radius
t = 2*pi*rand(100,1);  % Angle
data1 = [r.*cos(t), r.*sin(t)]; % Points

r2 = sqrt(3*rand(100,1)+1); % Radius
t2 = 2*pi*rand(100,1);      % Angle
data2 = [r2.*cos(t2), r2.*sin(t2)]; % points

r3 = sqrt(5*rand(100,1)+4); % Radius
t3 = 2*pi*rand(100,1);      % Angle
data3 = [r3.*cos(t3), r3.*sin(t3)]; % points

r4 = sqrt(7*rand(100,1)+9); % Radius
t4 = 2*pi*rand(100,1);      % Angle
data4 = [r4.*cos(t4), r4.*sin(t4)]; % points

figure;
h1 = plot(data1(:,1),data1(:,2),'r.','MarkerSize',15);
hold on
h2 = plot(data2(:,1),data2(:,2),'c.','MarkerSize',15);
%h3 = plot(data3(:,1),data3(:,2),'g.','MarkerSize',15); 
%h4 = plot(data4(:,1),data4(:,2),'b.','MarkerSize',15); 
ezpolar(@(x)1);ezpolar(@(x)2);%ezpolar(@(x)3); %ezpolar(@(x)4);
axis equal

trainX = [data1;data2];%;]; % data3 data4
labelX = ones(200,1);
labelX(101:200) = 2;
%labelX(201:300) = 3;
%labelX(301:400) = 4;

nsample =100;
r0 = sqrt(4*rand(nsample,1)); % Radius 16 9 4 1
t0 = 2*pi*rand(nsample,1);      % Angle
sample = [r0.*cos(t0), r0.*sin(t0)]; % points 
truelabel = ones(nsample,1);
for i=1:nsample 
    dist = sqrt(sum(sample(i,:).^2));
    if dist<=1
        truelabel(i) = 1;
    elseif dist <=2
        truelabel(i) = 2;
    elseif dist <=3
        truelabel(i) = 2;
    else
        truelabel(i) = 2;
    end
end

plot(sample(:,1),sample(:,2),'ko','MarkerSize',10)

%libsvm
% model = svmtrain(labelX,trainX);
% [labelY] = svmpredict(truelabel,sample,model);    

 [ svmclass] = mymultisvmtrain( trainX,labelX );
 [ labelY ] = mymultisvmclassify( svmclass, sample );
 
idx1 = find(labelY == 1);
idx2 = find(labelY == 2);
%idx3 = find(labelY == 3);
%idx4 = find(labelY == 4);
h5 = plot(sample(idx1,1),sample(idx1,2),'r*','MarkerSize',10);
h6 = plot(sample(idx2,1),sample(idx2,2),'c*','MarkerSize',10);
%h7 = plot(sample(idx3,1),sample(idx3,2),'g*','MarkerSize',10); 
%h8 = plot(sample(idx4,1),sample(idx4,2),'b*','MarkerSize',10);
% legend([h1,h2,h3,h4,h5,h6,h7,h8],...
%     {'1 (train)','2 (train)','3 (train)','4 (train)', '1 (classified)','2 (classified)','3 (classified)','4 (classified)'});

% legend([h1,h2,h3,h5,h6,h7],...
%     {'1 (train)','2 (train)','3 (train)', '1 (classified)','2 (classified)','3 (classified)'});

legend([h1,h2,h5,h6],...
    {'1 (train)','2 (train)', '1 (classified)','2 (classified)'});

hold off;  %

accuracy = sum((truelabel-labelY)==0)/nsample;
title(['Four Class - Accuracy = ' num2str(accuracy)]);

