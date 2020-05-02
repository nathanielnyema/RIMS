function [predicted_dg] = make_predictions(test_ecog)

% INPUTS: test_ecog - 3 x 1 cell array containing ECoG for each subject, where test_ecog{i} 
% to the ECoG for subject i. Each cell element contains a N x M testing ECoG,
% where N is the number of samples and M is the number of EEG channels.

% OUTPUTS: predicted_dg - 3 x 1 cell array, where predicted_dg{i} contains the 
% data_glove prediction for subject i, which is an N x 5 matrix (for
% fingers 1:5)

% Run time: The script has to run less than 1 hour. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load model and feature selection params
fprintf('loading model... \n')
addpath(genpath('utilities'))
load('models/selected2.mat','idxs2')
load('models/final_model.mat','rf512')

% set feature extraction and pre-processing params 
win_len = 0.08;
win_overlap = 0.04;
fs = 1000;
displ=(win_len-win_overlap)*fs;
nsamp=size(test_ecog{1},1);
num_feats = 200;
mean_win = 40;
predicted_dg = cell(3,1);

% loop through patients and fingers and predict with the appropriate model
for i = 1:length(test_ecog)
    fprintf('extracting pt %i features. ',i)
    raw_data = test_ecog{i};
    allfeats = getWindowedFeats(raw_data,fs,win_len,win_overlap);
    fprintf('predicting finger: ')
    for j=[1 2 3 5]
        fprintf('%i . ',j)
        selected = idxs2{i}(1:num_feats,j);
        processed = movmean( allfeats(:, selected), mean_win);
        predicted_dg{i}(:,j) = zointerp( predict( rf512{i,j}, processed ), displ, nsamp );
    end
    fprintf('\n')
end





end

