function [features] = get_features(clean_data, fs)
    % get_features_release.m
    %
    % Instructions: Write a function to calculate features.
    %               Please create 4 OR MORE different features for each channel.
    %               Some of these features can be of the same type (for example, 
    %               power in different frequency bands, etc) but you should
    %               have at least 2 different types of features as well
    %               (Such as frequency dependent, signal morphology, etc.)
    %               Feel free to use features you have seen before in this
    %               class, features that have been used in the literature
    %               for similar problems, or design your own!
    %
    % Input:    clean_data: (samples x channels)
    %           fs:         sampling frequency
    %
    % Output:   features:   (1 x (channels*features))
    % 

%% Your code here (8 points)
linelength = @(x, fs) sum(abs(diff(x))) / fs;
energy = @(x, fs) sum(x .^ 2) / fs;
went = @(x, ~) wentropy(x, 'shannon');
kurt = @(x, ~) kurtosis(x);
pdelta = @(x, fs) bandpower(x, fs, [1 4]);
ptheta = @(x, fs) bandpower(x, fs, [4 8]);
palpha = @(x, fs) bandpower(x, fs, [8 12]);
pbeta = @(x, fs) bandpower(x, fs, [13 30]);
pgamma = @(x, fs) bandpower(x, fs, [30 70]);
phgamma = @(x, fs) bandpower(x, fs, [70 200]);
feat_functions = {linelength, energy, went, kurt, ...
    pdelta, ptheta, palpha, pbeta, pgamma, phgamma};

n_feats = length(feat_functions);
n_ch = size(clean_data, 2);
feat_matrix = zeros(1, n_feats);
for i = 1:n_ch
    for j = 1:n_feats
        feat_matrix(i,j) = feat_functions{j}(clean_data(:,i), fs);
    end
end

% features((i-1)*n_ch + j) = ith feature, jth channel
features = feat_matrix(:);

end
