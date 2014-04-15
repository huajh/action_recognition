%
% 
%   @author:    Junhao Hua
%   @email:     huajh7@gmail.com
%
%   Created in: 2014/4/3
%   Lastest Update:  2014/4/10
%

function [ Svm_Struct ] = mysvmtrain( trainX, labelX,ker_func)

%MYSVMTRAIN Summary of this function goes here
%   Detailed explanation goes here
%   %Train the SVM Classifier
%   
%   Input: trainX    - n x p
%          labelY    - n x 1
%          dist_func: distance function
%
%   KernelFunction: 
%       linear      - k(x,x_i) = x_i'*x
%       polynomial  - k(x,x_i) = (1+x_i'*x/c)^d
%       rbf         -  Gaussian Radial Basis Function
%                      default: scale factor = 1 (sigma)
%       MLP (*)      - Multilayer Perceptron kernel (MLP)
%                     k(x,x_i) = tanh(k*x_i'*x + theta)
%
%  Optimization Methods: 
%       SMO         -  Sequential Minimal Optimization (SMO) 
%                      L1 soft-margin SVM classifier.
%                                 
%       LS          -  Least-squares method
%                      L2 soft-margin
%
%    
    if nargin < 3
        % defalut
        ker_func = 'rbf';
            % rbf parameter
        rbf_sigma = 1;
        kfunargs = {rbf_sigma};
    end
    
    if strcmp(ker_func,'linear')
        
        kfunc= @linear_kernel_func; 
        kfunargs = {};
        
    elseif strcmp(ker_func,'polynomial')
        
        kfunc = @polynomial_kernel_func;
        k = 10;
        kfunargs = {3,1/k,0};     
        
    elseif strcmp(ker_func,'rbf')
        
        kfunc = @rbf_kernel_func;
        kfunargs = {1};
        
    elseif strcmp(ker_func,'chisquared')
        
        kfunc = @chisquared_kernel;
        k = 10;
        kfunargs = {1/k};
        
    end
    
    Support_Vectors = [];
    Alpha_t = [];  % [alpha_i*y_i]
    Bias = [];
    Indx = [];    
    SV_Indx = [];    
    OptList = {'LS','SMO'};
    % use which optimization method ?
    i = 1;
    OptMethods = OptList{i};
    
    [NumX,dim] = size(trainX);     
    
   % labelX(labelX>0) = 1;
   % labelX(labelX<0) = -1;
   
    % tuning parameters
    
    % trade-off between slack variable \xi and weights.
    %
    %   min C \sum_i \xi_i (or \xi_i^2) + 1/2 |w|^2 
    %
    %   box constraint represents for C     
    %BoxConstraint = inf;
    boxC = 1;
    BoxConstraint = ones(NumX,1);
    n1 = length(find(labelX==1));
    n2 = length(find(labelX==-1));
    BoxConstraint(labelX == 1) = 0.5 * boxC * NumX / n1;
    BoxConstraint(labelX == -1) = 0.5 * boxC * NumX / n2;
    

    
    % scale the trainig data
    shift = mean(trainX);
    scalefactor = 1./std(trainX);
    scalefactor(~isfinite(scalefactor)) = 1;  % zero-variance data unscaled
    for i = 1:dim
        trainX(:,i) = scalefactor(i) * (trainX(:,i) - shift(i));
    end
        
    if strcmpi(OptMethods,'LS')
        %
        % Alpha: loss the sparseness
        %
        %Calcuate kernel matrix
        % two-norm soft-margin classifier        
        Omega = feval(kfunc,trainX,trainX,kfunargs{:});
        Omega = (Omega+Omega')/2 + diag(1./BoxConstraint);        
        
        % hessian matrix ZZ'
        H = (labelX * labelX').*Omega;
        
        % sovle AX = b
        
        A = [0      , -labelX'
             labelX ,    H   ];
        b = [0;ones(NumX,1)];
        
        x = A\b; %%%%%%
        Bias = x(1);
        Alpha_t = labelX.*x(2:end);
        Support_Vectors = trainX;
        SV_Indx = (1:NumX)';
        
    else
        % defalut : SMO 
        % if ~isempty(kfunargs)
            % tmp_kfun = @(x,y) feval(kfunc, x,y, kfunargs{:});
        % else
            % tmp_kfun = ker_func;
        % end    
        % smo_opts = statset('Display','off','MaxIter',15000);
        % [alpha, Bias] = seqminopt(trainX, labelX,BoxConstraint, tmp_kfun, smo_opts);
    
    % svIndex = find(alpha > sqrt(eps));
    % Support_Vectors = trainX(svIndex,:);
    % Alpha_t = Support_Vectors(svIndex).*alpha(svIndex);
    
    end
    
    Svm_Struct.Support_Vectors = Support_Vectors;
    Svm_Struct.Alpha_t = Alpha_t;
    Svm_Struct.Bias = Bias;
    Svm_Struct.kfunc = kfunc;        
    Svm_Struct.SV_Indx = SV_Indx;
    Svm_Struct.kfunargs = kfunargs;
    Svm_Struct.shift = shift;
    Svm_Struct.scalefactor = scalefactor;
    
end

% Sequential minimal optimization(SMO)
function SeqMinOpt()

end







