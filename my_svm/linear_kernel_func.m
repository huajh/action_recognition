function [kval] = linear_kernel_func(x,y)
% x : n x p
% y : m x p
% kval : n x m
    kval = x*y';
%     kval = zeros(size(y,1),1);
%     for i=1:size(y,1),
%       kval(i,1) = x*y(i,:)';
%     end
end