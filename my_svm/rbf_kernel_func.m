function [kval] = rbf_kernel_func(x,y,sigma)
%
%   Euclidean distance: Gaussian Kernel
%
%   number x feature
%   x: n x p
%   y: m x p
%
%   output: n x m
%
    if (nargin <3 ||isempty(sigma))
        sigma = 1;
    end
    sigma = 0.5;
    n = size(x,1);
    m = size(y,1);
   kval = exp(-(1/(2*sigma^2))* (repmat(sum(x.^2,2),1,m) + repmat(sum(y.^2,2)',n,1) - 2*x*y') );
end



