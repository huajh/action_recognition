function [kval] = polynomial_kernel_func(x,y,d,gamma,r)
    
    if nargin <3
        d = 3;
    end
    if nargin <4
        gamma = 0.5;
    end
    if nargin <5
    	r = 0;
    end
    kval = (gamma*x*y'+r).^d;
end