function [bct, bclambda] = trans_simon10(x)

if ~isvector(x)
    error(message('finance:ftseries:ftseries_boxcox:InputMustBeVector'));
end
if any(x <= 0)
    error(message('finance:ftseries:ftseries_boxcox:DataMustBePositive'));
end

objectiveFun = @(l) logLikelihood(l,x);
options = optimset('MaxFunEvals', 2000, 'Display', 'off');
bclambda = fminsearch(objectiveFun, 0, options);

% Generate the transformed data using the optimal lambda.
bct = s10tran(bclambda,x);


function llf = logLikelihood(lambda,x)
% Compute the log likelihood function for a given lambda and x

% Get the length of the data vector.
n = length(x);

% Transform data using a particular lambda.
xhat = s10tran(lambda,x);

% The algorithm calls for maximizing the LLF; however, since we
% have only functions that minimize, the LLF is negated so that we
% can minimize the function instead of maximizing it to find the
% optimum lambda.
llf = -(n/2) .* log(std(xhat, 1, 1)' .^ 2) + (lambda-1)*(sum(log(x)));
llf = -llf;


function t10 = s10tran(lambda,x)
% Perform the actual box-cox transform.

% Get the length of the data vector.
n = length(x);

% Make sure that the lambda vector is a column vector.
lambda = lambda(:);

% Create a matrix of the data by replicating the data vector
% columnwise.
mx = x * ones(1, length(lambda));

% Create a matrix of the lambda by replicating the lambda vector
% rowwise.
mlambda = (lambda * ones(1, n))';

% Calculate the transformed data vector, xhat.
t10 =mlambda .* log(mx+1)+log(mx);


