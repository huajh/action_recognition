function [ kval ] = chisquared_kernel( x,y,gamma )

    if (nargin <3 ||isempty(gamma))
        gamma = 1;
    end 
    %kval = exp(-(1/(2*sigma^2))*(repmat(sum(x,2),1,size(y,1)) + repmat(sum(y,2)',size(x,1),1)));    
    
    % exponential chi squared kernel
    kval = exp(-gamma *(dist_chisquared(x,y)) );
    %kval = exp(-gamma *(1-dist_chisquared(x,y)) );
    
    %chi-squared kernel
    %kval = (1-dist_chisquared(x,y));        
    
    %additive chi squared kernel 
    %kval = add_chi2_kernel(x,y);
end

function D = add_chi2_kernel(X,Y)

    [m, ~] = size(X);  [n, ~] = size(Y);

    m_ones = ones(1,m); D = zeros(m,n); 
    for i=1:n  
        yi = Y(i,:);  yi_rep = yi( m_ones, : );
        s = yi_rep + X; % s = 1
        d = yi_rep.*X;
        D(:,i) = sum( d./ (s+eps), 2 );
    end
    D = 2*D;
end
