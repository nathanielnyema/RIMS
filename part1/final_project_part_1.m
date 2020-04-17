%% Final project part 1
% Prepared by John Bernabei and Brittany Scheid

% One of the oldest paradigms of BCI research is motor planning: predicting
% the movement of a limb using recordings from an ensemble of cells involved
% in motor control (usually in primary motor cortex, often called M1).

% This final project involves predicting finger flexion using intracranial EEG (ECoG) in three human
% subjects. The data and problem framing come from the 4th BCI Competition. For the details of the
% problem, experimental protocol, data, and evaluation, please see the original 4th BCI Competition
% documentation (included as separate document). The remainder of the current document discusses
% other aspects of the project relevant to BE521.


%% Start the necessary ieeg.org sessions (0 points)

% username = 'owo';
% passPath = '../pwdfile.bin';
% 
% Load training ecog from each of three patients
% s1_train_ecog = IEEGSession('I521_Sub1_Training_ecog', username, passPath);
% 
% Load training dataglove finger flexion values for each of three patients
% s1_train_dg = IEEGSession('I521_Sub1_Training_dg', username, passPath);

%% Extract dataglove and ECoG data 
% Dataglove should be (samples x 5) array 
% ECoG should be (samples x channels) array
load final_proj_part1_data train_dg train_ecog
fs = 1000; % Hz

% Split data into a train and test set (use at least 50% for training)
test_frac = 0.2; % fraction of data reserved for the test set

n_samples = length(train_dg{1}); % 300000
test_dg = cell(3,1);
test_ecog = cell(3,1);
for i = 1:3
    ix = floor(length(train_dg{i}) * test_frac);
    test_dg{i} = train_dg{i}(1:ix,:);
    test_ecog{i} = train_ecog{i}(1:ix,:);
    train_dg{i}(1:ix,:) = [];
    train_ecog{i}(1:ix,:) = [];
end

%% Get Features
win_len = 0.5; % seconds
win_overlap = 0.1; % seconds
feature_matrix = cell(3, 1);
for i = 1:3
    feature_matrix{i} = getWindowedFeats(train_ecog{i}, fs, win_len, win_overlap);
end

%% Test R matrix
load testRfunction N_wind testR_features
Rtest = create_R_matrix(testR_features, N_wind);
fprintf(1, 'mean(R) = %.4f\n', mean(Rtest, 'all'));
clear testR_features N_wind Rtest

%% Create R matrix
R_matrix = cell(3, 1);
for i = 1:3
    n_win = 10;
    R_matrix{i} = create_R_matrix(feature_matrix{i}, n_win);
end

%% Train classifiers (8 points)
% Downsample train_dg_down:
Ytrain = cell(3, 1);
for i = 1:3
    ival = size(train_dg{i},1) / size(R_matrix{i},1);
    ix = round(1:ival:length(train_dg{i}));
    Ytrain{i} = train_dg{i}(ix,:);
end

% Classifier 1: Get angle predictions using optimal linear decoding. That is, 
% calculate the linear filter (i.e. the weights matrix) as defined by 
% Equation 1 for all 5 finger angles.
F = cell(3,1);
for i = 1:3
    R_norm = [R_matrix{i}(:,1) normalize(R_matrix{i}(:,2:end), 1)];
    F{i} = (R_norm' * R_norm) \ (R_norm' * Ytrain{i});
end

% Try at least 1 other type of machine learning algorithm, you may choose
% to loop through the fingers and train a separate classifier for angles 
% corresponding to each finger

% Trying an svm
svm = cell(3, 5); % one model per subject per finger
for i = 1:3
    R_norm = [R_matrix{i}(:,1) normalize(R_matrix{i}(:,2:end), 1)];
    for j = 1:5
        svm{i,j} = fitrsvm(R_norm, Ytrain{i}(:,j));
    end
end

% Try a form of either feature or prediction post-processing to try and
% improve underlying data or predictions.



%% Correlate data to get test accuracy and make figures (2 point)
% Calculate accuracy by correlating predicted and actual angles for each
% finger separately. Hint: You will want to use zohinterp to ensure both 
% vectors are the same length.

% Build test matrix
R_norm_test = cell(3,1);
for i = 1:3
    feature_matrix_test = getWindowedFeats(test_ecog{i}, fs, win_len, win_overlap);
    R_matrix_test = create_R_matrix(feature_matrix_test, n_win);
    R_norm_test{i} = [R_matrix_test(:,1) normalize(R_matrix_test(:,2:end), 1)];
end

% Test linear regression
fprintf(1, 'LINEAR REGRESSION:\n');
corr_linreg = zeros(3,5);
Yhat = cell(3,1);
Yhat_interp = cell(3,1);
for i = 1:3
    fprintf(1, 'Subject %d:\n\t', i);
    
    % Generate Yhat and interpolate
    Yhat{i} = R_norm_test{i} * F{i};
    Yhat_interp{i} = resample(Yhat{i}, length(test_dg{i}), length(Yhat{i}));
    
    % compute correlation
    corr_linreg(i,:) = diag(corr(test_dg{i}, Yhat_interp{i}));
    for j = 1:5
        fprintf(1, ' Finger %d: %.3f', j, corr_linreg(i,j));
    end
    fprintf(1, '\n');
end

% Test svm
fprintf(1, 'REGRESSION SVM:\n');
corr_svm = zeros(3,5);
Yhat_svm = cell(3,1);
Yhat_svm_interp = cell(3,1);
for i = 1:3
    fprintf(1, 'Subject %d:\n\t', i);
    
    % Generate Yhat and interpolate
    Yhat_svm{i} = zeros(size(R_norm_test{i},1), 5);
    for j = 1:5
        Yhat_svm{i}(:,j) = svm{i,j}.predict(R_norm_test{i});
    end
    Yhat_svm_interp{i} = resample(Yhat_svm{i}, length(test_dg{i}), length(Yhat_svm{i}));
    
    % compute correlation
    corr_svm(i,:) = diag(corr(test_dg{i}, Yhat_svm_interp{i}));
    for j = 1:5
        fprintf(1, ' Finger %d: %.3f', j, corr_svm(i,j));
    end
    fprintf(1, '\n');
end