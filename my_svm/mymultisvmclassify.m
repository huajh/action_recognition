function [ group ] = mymultisvmclassify( SvmClass, testX )
%MYMULTISVMCLASSIFIER Summary of this function goes here
%
%	author: Junhao Hua
%	email:  huajh7@gmail.com
    
    labelList = SvmClass.labelList;
    nlabel = length(labelList);
    Ylist = [];
    for i=1:nlabel
       [ ~, predY] = mysvmclassify( SvmClass.model{i},testX );
        %[ ~, predY] = svmclassify( SvmClass.model{i},testX );
        Ylist = [Ylist,predY];
    end
    [~,idx] = max(Ylist,[],2);
    group = labelList(idx);
    
end

