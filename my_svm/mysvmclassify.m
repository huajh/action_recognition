function [ LabelY, predY] = mysvmclassify( svm_struct,testX )
%MYSVMCLASSIFIER Summary of this function goes here
%   Detailed explanation goes here
%
%	author: Junhao Hua
%	email:  huajh7@gmail.com
%

    sv = svm_struct.Support_Vectors;
    alpha_t = svm_struct.Alpha_t;
    bias = svm_struct.Bias;
    kfun = svm_struct.kfunc;    
    kfunargs = svm_struct.kfunargs;
    shift = svm_struct.shift;
    scalefactor = svm_struct.scalefactor;
    
%     shift and rescale data
    [~,dim] = size(testX);
    for i = 1:dim
        testX(:,i) = scalefactor(i) * (testX(:,i) - shift(i));
    end
    
    predY = (feval(kfun,sv,testX,kfunargs{:})'*alpha_t(:)) + bias;
    
    LabelY = sign(predY);
    
    % points on the boundary are assigned to class 1
    LabelY(LabelY==0) = 1;    

end

