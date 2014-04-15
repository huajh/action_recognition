function [kval] = MLP_kernel_func(x,y,theta)
    
    if length(theta)==1
        theta(2) = 1; 
    end 
    kval = zeros(size(y,1),1);
    for i=1:size(y,1),        
        kval(i,1) = tanh(theta(1)*x*y(i,:)' + theta(2)^2);
    end
end