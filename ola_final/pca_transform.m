function [R, pca_coeff, n_components] = pca_transform(R_raw, pca_coeff)
% pca_transform.m
% Description:  Normalize the input, then transform using PCA.
%               Chooses enough components to caputure 90% of variance
%
% Input:    R_raw           Input matrix
%
% Outputs:  R               Transformed output matrix
%           pca_coeff       PCA transformation matrix
%           n_components    number of components used

R_norm = normalize(R_raw, 1);

if exist('pca_coeff', 'var')
    % use the given coefficients
    R  = R_norm * pca_coeff;
else
    % compute coefficients
    [coeff,pca_score,~,~,explained] = pca(R_norm);
    n_components = find(cumsum(explained) >= 90, 1); % should be ~700
    pca_coeff = coeff(:,1:n_components);
    R = pca_score(:,1:n_components);
end

end