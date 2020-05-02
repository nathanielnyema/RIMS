clear all;
close all;

foldername= 'RIMS';

addpath(genpath(foldername));

        
fprintf('Success! \n Test 2 (dataset length 13455)...');
load dummy_data_trim
load dummy_dg_trim
predicted_dg = make_predictions(test_data);


rs_mat = [diag(corr(predicted_dg{1},test_dg{1}),0)'; ...
                diag(corr(predicted_dg{2},test_dg{2}),0)'; ...
                diag(corr(predicted_dg{3},test_dg{3}),0)'];

fingers = [1 2 3 5];
avgR = mean(mean(rs_mat(:,fingers)))

fprintf('Success!');
