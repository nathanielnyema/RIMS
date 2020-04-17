function clean_data = filter_data(raw_eeg, fs)
    % filter_data_release.m
    %
    % Instructions: Write a filter function to clean underlying data.
    %               The filter type and parameters are up to you.
    %               Points will be awarded for reasonable filter type,
    %               parameters, and correct application. Please note there 
    %               are many acceptable answers, but make sure you aren't 
    %               throwing out crucial data or adversely distorting the 
    %               underlying data!
    %
    % Input:    raw_eeg (samples x channels)
    %
    % Output:   clean_data (samples x channels)
    %           fs: sample rate in Hz

%% Your code here (2 points) 
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
