function corr_matrix = cv_correlation(predictors, R, Y, dg, timestamps, k)
% cv_correlation.m
%
% Description:  Compute average correlation per patient per finger,
%               using k-fold cross validation
%
% Input:    R_raw           Input matrix
%
% Outputs:  R               Transformed output matrix
%           pca_coeff       PCA transformation matrix
%           n_components    number of components used
if ~exist('k', 'var')
    k = 5;
end

corr_matrix = zeros(3, 5);
for i = 1:3
    fprintf(1, 'Subject %d:\t', i);
    c = kfold(10, predictors{i}, R{i}, Y{i}, dg{i}, timestamps{i});
    corr_matrix(i,:) = mean(c, 1);
    for j = 1:5
        fprintf(1, ' F%d: %.3f', j, corr_matrix(i,j));
    end
    fprintf(1,'\n');
end

end