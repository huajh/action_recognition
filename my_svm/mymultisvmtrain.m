function [ SvmClass ] = mymultisvmtrain( trainX,labelX,ker_func )
%MYMULTISVMTRAIN Summary of this function goes here
%   Detailed explanation goes here
%
%   trainX : N x p
%   labelX : N x 1
%   dist_func: distance function
%   
%   scheme:
%   one-versus-the-rest
%   one-versus-one
%
%	author: Junhao Hua
%	email:  huajh7@gmail.com


    labelList = unique(labelX);
    nlabel = length(labelList);
    
    if nlabel <2
        warning(message('The groupsize of label needs greater than 2.'))
        return;
    end
    if nargin < 3 || isempty(ker_func)
        ker_func = 'rbf';
    end
    
    [NumX,~] = size(trainX);
    SvmClass.labelList = labelList;
    %
    % Simplest approach: The one-versus-the-rest 
    %    
    for i=1:nlabel
        onevAll = -1/(nlabel-1) * ones(NumX,1); %
        onevAll(labelX==labelList(i)) = 1;
        
        SvmClass.model{i}  = mysvmtrain(trainX,onevAll,ker_func);
        % SvmClass.model{i} = svmtrain(trainX,onevAll,'kernel_function','rbf');
    end
    
end

