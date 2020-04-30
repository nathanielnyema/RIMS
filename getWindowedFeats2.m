function [all_feats,timestamps]=getWindowedFeats2(raw_data, fs, window_length, window_overlap)
    % getWindowedFeats2.m
    %
    % Description:  This function processes data through the steps of
    %               filtering, feature calculation, creation of R matrix
    %               and returns features.
    %
    % Inputs:   raw_data:       The raw data for all patients
    %           fs:             The raw sampling frequency
    %           window_length:  The length of window
    %           window_overlap: The overlap in window
    %
    % Output:   all_feats:      All calculated features
    %           timestamps:     indices marking the end of each window
    %
% Filter the raw data
data_filt = filter_data(raw_data, fs);

% Compute timestamps
[n_raw, m_raw] = size(data_filt);
W = round(fs * window_length); % window length in samples
D = round(fs * (window_length - window_overlap)); % displacement in samples
n_windows = 1 + floor((n_raw - W) / D);
timestamps = (W + (0:n_windows-1) * (D))';

% Compute features
n_feats = size(get_features(data_filt(1:10,:), fs) / m_raw, 1);
all_feats = zeros(n_windows, n_feats);
for i = 1:n_windows
    % Within loop calculate feature for each segment (call get_features)
    clip = data_filt(timestamps(i)-W+1:timestamps(i),:);
    f = get_features(clip, fs);
    % update feature matrix
    all_feats(i,:) = f;
end

end
