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
W = round(fs * window_length); % window length in samples
D = round(fs * (window_length - window_overlap)); % displacement in samples

% First, filter the raw data
data_filt = filter_data(raw_data, fs);

% Then, loop through sliding windows
[n_raw, m_raw] = size(data_filt);
n_feats = size(get_features(data_filt(1:10,:), fs) / m_raw, 1);
n_windows = 1 + floor((n_raw - W) / D);

start = 1;
all_feats = zeros(n_windows, n_feats);
for i = 1:n_windows
    % Within loop calculate feature for each segment (call get_features)
    clip = data_filt(start:start+W-1,:);
    f = get_features(clip, fs);
    % update feature matrix
    all_feats(i,:) = f;
    start = start + D;
end

end
