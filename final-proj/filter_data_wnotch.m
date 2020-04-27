function clean_data = filter_data_wnotch(raw_eeg, fs)
    % filter_data.m
    % Input:    raw_eeg (samples x channels)
    %
    % Output:   clean_data (samples x channels)
    %           fs: sample rate in Hz

%%
% 60 Hz notch filter
w0 = 60 * 2 / fs; % rad/s, normalized by pi
[B_notch, A_notch] = iirnotch(w0, w0/35);
eeg = filtfilt(B_notch, A_notch, raw_eeg);

% main filter
filt_type = 'lowpass';
switch filt_type
    case 'lowpass'
        clean_data = lowpass(eeg, 200, fs);
    case 'bandpass'
        clean_data = bandpass(eeg, [1 200], fs);
    case 'highpass'
        clean_data = highpass(eeg, 1, fs);
    otherwise
        error("must be 'lowpass', 'bandpass', or 'highpass'");
end

end
