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
% f_de = designfilt('lowpassfir', 'FilterOrder', 100, 'CutoffFrequency', 4,'SampleRate', fs);
% f_th = designfilt('bandpassfir', 'FilterOrder', 100, 'CutoffFrequency1', 4, 'CutoffFrequency2', 8, 'SampleRate', fs);
% f_al = designfilt('bandpassfir', 'FilterOrder', 100, 'CutoffFrequency1', 8, 'CutoffFrequency2', 12, 'SampleRate', fs);
% f_be = designfilt('bandpassfir', 'FilterOrder', 100, 'CutoffFrequency1', 13, 'CutoffFrequency2', 30, 'SampleRate', fs);
% f_ga = designfilt('bandpassfir', 'FilterOrder', 100, 'CutoffFrequency1', 30, 'CutoffFrequency2', 70, 'SampleRate', fs);
% f_hg = designfilt('bandpassfir', 'FilterOrder', 100, 'CutoffFrequency1', 70, 'CutoffFrequency2', 150, 'SampleRate', fs);

% 60 Hz notch filter
w0 = 60 * 2 / fs; % rad/s, normalized by pi
[B_notch, A_notch] = iirnotch(w0, w0/35);
eeg = filtfilt(B_notch, A_notch, raw_eeg);

% main filter
filt_type = 'lowpass';
switch filt_type
    case 'lowpass'
%         clean_data = lowpass(eeg, 200, fs);
        f = designfilt('lowpassfir', 'FilterOrder', 100, 'CutoffFrequency', 200,'SampleRate', fs);
    case 'bandpass'
%         clean_data = bandpass(eeg, [1 200], fs);
        f = designfilt('bandpassfir', 'FilterOrder', 100, 'CutoffFrequency1', 1, 'CutoffFrequency2', 200, 'SampleRate', fs);
    case 'highpass'
%         clean_data = highpass(eeg, 1, fs);
        f = designfilt('highpassfir', 'FilterOrder', 100, 'CutoffFrequency', 1,'SampleRate', fs);
    otherwise
        error("must be 'lowpass', 'bandpass', or 'highpass'");
end
clean_data = filtfilt(f, eeg);

end
