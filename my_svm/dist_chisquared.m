
 
function D = dist_chisquared( X, Y )
    [m p] = size(X);  [n p] = size(Y);

    m_ones = ones(1,m); D = zeros(m,n); 
    for i=1:n  
        yi = Y(i,:);  yi_rep = yi( m_ones, : );
        s = yi_rep + X;    d = yi_rep - X;
        D(:,i) = sum( d.^2 ./ (s+eps), 2 );
    end
    D = D/2;
