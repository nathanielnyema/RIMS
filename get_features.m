function features = get_features(clean_data, fs)
    % get_features2.m
    %
    % Description:  Compute features for all windows in parallel
    %
    % Input:    clean_data: [samples x windows x channels]
    %           fs:         sampling frequency
    %
    % Output:   features:   [windows x (channels*features)]
    % 

%% Your code here (8 points)
linelength = @(x, fs) sum(abs(diff(x)), 1) / fs;
energy = @(x, fs) sum(x.^2, 1) / fs;
kurt = @(x, ~) kurtosis(x);
feature_functions = {linelength, energy, @went, kurt};

n_win = size(clean_data, 2);
n_ch = size(clean_data, 3);
n_feats = length(feature_functions);
feat_matrix = zeros(1, n_win, n_ch, n_feats);

% Compute features
for i = 1:n_feats
    f = feature_functions{i};
    feat_matrix(1,:,:,i) = f(clean_data, fs);
end

% combine dimensions 2 and 3:
% features((i-1)*n_ch + j) = ith feature, jth channel
features = squeeze(feat_matrix(:,:,:));

function w = went(x,~)
    % shannon wavelet entropy
    % x: [time x channel] or [time x channel x window]
    % output: [1 x channel] or [1 x channel x window]
    w = x.^2;
    w = -sum(w .* log(eps+w), 1);
end

end
