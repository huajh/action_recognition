
clear;clc;
close all;

rng(1); % For reproducibility
r = sqrt(rand(100,1)); % Radius
t = 2*pi*rand(100,1);  % Angle
data1 = [r.*cos(t), r.*sin(t)]; % Points

r2 = sqrt(3*rand(100,1)+1); % Radius
t2 = 2*pi*rand(100,1);      % Angle
data2 = [r2.*cos(t2), r2.*sin(t2)]; % points

figure;
h1 = plot(data1(:,1),data1(:,2),'r.','MarkerSize',15)
hold on
h2 = plot(data2(:,1),data2(:,2),'b.','MarkerSize',15)
ezpolar(@(x)1);ezpolar(@(x)2);
axis equal
%hold off

trainX = [data1;data2];
labelX = ones(200,1);
labelX(101:200) = -1;

[svm_class] = mysvmtrain(trainX,labelX);

nsample = 100;
r3 = sqrt(4*rand(100,1)); % Radius
t3 = 2*pi*rand(100,1);      % Angle
sample = [r3.*cos(t3), r3.*sin(t3)]; % points
plot(sample(:,1),sample(:,2),'ko','MarkerSize',10)

labelY = mysvmclassify(svm_class,sample);

idx1 = find(labelY == -1);
idx2 = find(labelY == 1);
h3 = plot(sample(idx1,1),sample(idx1,2),'b*');
h4 = plot(sample(idx2,1),sample(idx2,2),'r*');

truelabel = ones(nsample,1);
for i=1:nsample 
    dist = sqrt(sum(sample(i,:).^2));
    if dist<=1
        truelabel(i) = 1;
    else
        truelabel(i) = -1;
    end
end

legend([h1,h2,h3,h4],{'1 (train)','-1 (train)','1 (classified)','-1 (classified)'});

accuracy = sum((truelabel-labelY)==0)/nsample;
title(['Two Class - Accuracy = ' num2str(accuracy)]);
