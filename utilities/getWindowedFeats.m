function [all_feats,timestamps]=getWindowedFeats(raw_data, fs, window_length, window_overlap)
    % getWindowedFeats.m
    %
    % Description:  Same as getWindowedFeats but trying to parallelize the
    %               whole thing
    %
    % Inputs:   raw_data:       The raw data for all patients
    %           fs:             The raw sampling frequency
    %           window_length:  The length of window (seconds)
    %           window_overlap: The overlap in window (seconds)
    %
    % Output:   all_feats:      All calculated features
    %           timestamps:     indices marking the end of each window
    %
%% Filter the raw data
data_filt = filter_data(raw_data);

% Compute timestamps
[n_raw, m_raw] = size(data_filt); % n_samples x n_channels
W = round(fs * window_length); % window length in samples
D = round(fs * (window_length - window_overlap)); % displacement in samples
n_windows = 1 + floor((n_raw - W) / D);
timestamps = (W + (0:n_windows-1) * (D))';

% time-frequency spectrogram [freq x window x channel]
hwin = hamming(W);
[timefreq,F,~] = stft(data_filt, fs, 'Window', hwin, 'Centered', false, ...
    'OverlapLength', W - D);
n_freq = ceil(W/2);
timefreq = timefreq(1:n_freq,:,:);
F = F(1:n_freq);

% power spectral density [freq x window x channel]
Pxx = timefreq .* conj(timefreq) / (fs*(hwin' * hwin));
clear timefreq

% Build windowed data matrix [samples x windows x channels]
windowed_data = zeros(W, n_windows, m_raw);
for i = 1:n_windows
    windowed_data(:,i,:) = data_filt(timestamps(i)-W+1:timestamps(i),:);
end

% Time series features
f1 = get_features(windowed_data, fs);

% Time-frequency features
f2 = get_bandpowers(Pxx, F);

% Combine features
all_feats = [f1, f2];

end