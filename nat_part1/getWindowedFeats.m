function [all_feats]=getWindowedFeats(raw_data, fs, window_length, window_overlap)
    %
    % getWindowedFeats_release.m
    %
    % Instructions: Write a function which processes data through the steps
    %               of filtering, feature calculation, creation of R matrix
    %               and returns features.
    %
    %               Points will be awarded for completing each step
    %               appropriately (note that if one of the functions you call
    %               within this script returns a bad output you won't be double
    %               penalized)
    %
    %               Note that you will need to run the filter_data and
    %               get_features functions within this script. We also 
    %               recommend applying the create_R_matrix function here
    %               too.
    %
    % Inputs:   raw_data:       The raw data for all patients
    %           fs:             The raw sampling frequency
    %           window_length:  The length of window
    %           window_overlap: The overlap in window
    %
    % Output:   all_feats:      All calculated features
    %
%% Your code here (3 points)

% First, filter the raw data
data=filter_data(raw_data);

% Then, loop through sliding windows
displ=(window_length-window_overlap)*fs;
M = 1 + floor((length(data)-window_length*fs)/displ); 
window=1:window_length*fs;
numFeats=8;
all_feats=zeros(M,size(data,2)*numFeats);

for i=1:M
    % Within loop calculate feature for each segment (call get_features)
    all_feats(i,:)=get_features(data(window,:),fs);
    window=window+displ;
end
% Finally, return feature matrix

end