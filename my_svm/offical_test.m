
clear;clc;

rng(1); % For reproducibility
r = sqrt(rand(100,1)); % Radius
t = 2*pi*rand(100,1);  % Angle
data1 = [r.*cos(t), r.*sin(t)]; % Points

r2 = sqrt(3*rand(100,1)+1); % Radius
t2 = 2*pi*rand(100,1);      % Angle
data2 = [r2.*cos(t2), r2.*sin(t2)]; % points

figure;
plot(data1(:,1),data1(:,2),'r.','MarkerSize',15)
hold on
plot(data2(:,1),data2(:,2),'b.','MarkerSize',15)
ezpolar(@(x)1);ezpolar(@(x)2);
axis equal
hold off

data3 = [data1;data2];
theclass = ones(200,1);
theclass(1:100) = -1;

%Train the SVM Classifier
[cl,svIndex] = svmtrain(data3,theclass,'kernel_function','rbf','showplot',true);
hold on
axis equal
ezpolar(@(x)1); ezpolar(@(x)2)
%hold off

r3 = sqrt(2*rand(100,1)+0.5); % Radius
t3 = 2*pi*rand(100,1);      % Angle
Sample = [r3.*cos(t3), r3.*sin(t3)]; % points
plot(Sample(:,1),Sample(:,2),'k.','MarkerSize',15)
hold on

Group = svmclassify(cl,Sample,'Showplot',true);