%% Constant variables
% Raw data
fs = 1000; % Hz
% Feature extraction
win_len = 0.1; % seconds (was 1)
win_overlap = 0.02; % seconds (was 0.5)
% R matrix
n_win = 1;

%% Extract dataglove and ECoG data 
% Dataglove should be (samples x 5) array 
% ECoG should be (samples x channels) array
addpath('part1')
load raw_training_data train_dg train_ecog
load leaderboard_data leaderboard_ecog

n_samples = length(train_dg{1}); % 300000

%% Remove bad channels
for i = 1:3
    bad_ch = find(max(train_ecog{i},[],1) > 1e5);
    train_ecog{i}(:,bad_ch) = [];
    leaderboard_ecog{i}(:,bad_ch) = [];
end

%% Get Features
feat_matrix = cell(3, 1);
timestamps = cell(3, 1);
for i = 1:3
    [feat_matrix{i}, timestamps{i}] = getWindowedFeats(train_ecog{i}, fs, win_len, win_overlap);
end
save features.mat feat_matrix timestamps -append
% load features.mat feat_matrix timestamps

%% Create R matrix
R_raw = cell(3, 1);
for i = 1:3
    R_raw{i} = create_R_matrix(feat_matrix{i}, n_win);
end

%% PCA (on normalized features)
R = cell(3,1);
pca_coeff = cell(3,1);
n_components = zeros(3,1);
for i = 1:3
    [R{i}, pca_coeff{i}, n_components(i)] = pca_transform(R_raw{i});
end

save pca.mat R pca_coeff n_components
% load pca.mat R pca_coeff n_components

%% Downsample dataglove
Ytrain = cell(3, 1);
for i = 1:3
    Ytrain{i} = downsample_dg(train_dg{i}, timestamps{i});
end

%% Optimize hyperparameters
% Classifier 1: Least-squares linear regression
fprintf(1, 'LINEAR REGRESSION:\n');
linreg = cell(3, 1);
for i = 1:3
    fprintf(1, 'Subject %d:\n', i);
    linreg{i} = LRPredictor().optimize(R{i}, Ytrain{i});
end
% save models.mat linreg -append
% load models.mat linreg

% Classifier 2: SVM
% fprintf(1, 'REGRESSION SVM:\n');
% svm = cell(3, 1);
% for i = 1:3
%     fprintf(1, 'Subject %d:\n', i);
%     svm{i} = SVMPredictor('gaussian').optimize(R{i}, Ytrain{i});
%     svm{i} = SVMPredictor('gaussian').train(R{i}, Ytrain{i});
% end
% save models.mat svm -append
% load models.mat svm

% Classifier 3: Random Forest
fprintf(1, 'RANDOM FOREST:\n');
rf = cell(3, 1);
for i = 1:3
    fprintf(1, 'Subject %d:\n', i);
    rf{i} = RFPredictor().optimize(R{i}, Ytrain{i});
%     svm{i} = RFPredictor().train(R{i}, Ytrain{i});
end
save models.mat rf -append
% load models.mat rf

%% Cross validation test
% Test linear regression
fprintf(1, 'LINEAR REGRESSION:\n');
corr_linreg = cv_correlation(linreg, R, Ytrain, train_dg, timestamps);

% Test svm
% fprintf(1, 'REGRESSION SVM:\n');
% corr_svm = cv_correlation(svm, R, Ytrain, train_dg, timestamps);

% Test random forest
fprintf(1, 'RANDOM FOREST:\n');
corr_rf = cv_correlation(rf, R, Ytrain, train_dg, timestamps);

%% Train final models
for i = 1:3
    linreg{i}.train(R{i}, Ytrain{i});
%     svm{i}.train(R{i}, Ytrain{i});
    rf{i}.train(R{i}, Ytrain{i});
end
save models.mat linreg rf -append
% load models.mat linreg rf

%% Build test matrix
feat_matrix_test = cell(3,1);
R_test = cell(3,1);
for i = 1:3
    fprintf(1, 'Patient %d', i);
    fprintf(1, ' ... Getting features');
    feat_matrix_test{i} = getWindowedFeats(leaderboard_ecog{i}, fs, win_len, win_overlap);
    fprintf(1, ' ... Building R matrix');
    R_raw_test = create_R_matrix(feat_matrix_test{i}, n_win);
    fprintf(1, ' ... Applying PCA');
    R_test{i} = pca_transform(R_raw_test, pca_coeff{i});
    fprintf(1, ' ... done.\n');
end
clear R_raw_test R_norm_test

save features.mat feat_matrix_test -append
save R_test.mat R_test
% load features.mat feat_matrix_test
% load R_test.mat R_test

%% Generate test predictions
predicted_dg = cell(3,1); % the final output predictions
model = svm;
for i = 1:3
    Y_est = model{i}.predict(R_test{i});
    predicted_dg{i} = resample(Y_est, size(leaderboard_ecog{i},1), size(R_test{i},1));
end

save predicted_dg.mat predicted_dg
