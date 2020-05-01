function clean_data = filter_data_wnotch(raw_eeg, fs)
    % filter_data.m
    % Input:    raw_eeg (samples x channels)
    %
    % Output:   clean_data (samples x channels)
    %           fs: sample rate in Hz

% 60 Hz notch filter
w0 = 60 * 2 / fs; % rad/s, normalized by pi
[B_notch, A_notch] = iirnotch(w0, w0/35);
eeg = filtfilt(B_notch, A_notch, raw_eeg);

% main filter
filt_type = 'lowpass';
switch filt_type
    case 'lowpass'
        f = designfilt('lowpassfir', 'FilterOrder', 100, 'CutoffFrequency', 200,'SampleRate', fs);
    case 'bandpass'
        f = designfilt('bandpassfir', 'FilterOrder', 100, 'CutoffFrequency1', 1, 'CutoffFrequency2', 200, 'SampleRate', fs);
    case 'highpass'
        f = designfilt('highpassfir', 'FilterOrder', 100, 'CutoffFrequency', 1,'SampleRate', fs);
    otherwise
        error("must be 'lowpass', 'bandpass', or 'highpass'");
end
clean_data = filtfilt(f, eeg);

end
