function R = create_R_matrix(features, N_wind)
    % get_features_release.m
    %
    % Instructions: Write a function to calculate R matrix.             
    %
    % Input:    features:   (samples x (channels*features))
    %           N_wind:     Number of windows to use
    %
    % Output:   R:          (samples x (N_wind*channels*features))
    % 

%% Your code here (5 points)
    [n_windows, n_feats] = size(features);

    % augment feature matrix by copying the first n-1 rows
    feat_aug = [features(1:N_wind-1,:); features];
    
    R = zeros(n_windows, 1 + N_wind * n_feats);
    R(:,1) = ones(n_windows, 1);
    for i = 1:n_feats
        cols = 1 + (i-1)*N_wind + (1:N_wind);
        feat_vec = feat_aug(:,i);
        R(:,cols) = makeblock(feat_vec, n_windows, N_wind);
    end

    function block = makeblock(feat_vec, n_windows, N_wind)
        % create a block of size MxN corresponding to a single feature
        block = zeros(n_windows, N_wind);
        for w = 1:N_wind
            block(:,w) = feat_vec(w:w+n_windows-1);
        end
    end
end
