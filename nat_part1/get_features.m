function [features] = get_features(clean_data,fs)
    %
    % get_features_release.m
    %
    % Instructions: Write a function to calculate features.
    %               Please create 4 OR MORE different features for each channel.
    %               Some of these features can be of the same type (for example, 
    %               power in different frequency bands, etc) but you should
    %               have at least 2 different types of features as well
    %               (Such as frequency dependent, signal morphology, etc.)
    %               Feel free to use features you have seen before in this
    %               class, features that have been used in the literature
    %               for similar problems, or design your own!
    %
    % Input:    clean_data: (samples x channels)
    %           fs:         sampling frequency
    %
    % Output:   features:   (1 x (channels*features))
    % 
%% Your code here (8 points)
% LLFn= @(x) nansum(abs(x(:,2:end)-x(:,1:end-1)),2);
% ll=LLFn(clean_data');
means=mean(clean_data,1)';
num_ch=size(clean_data,2);
freqBands=reshape((0:15:195),2,7)';
% freqBands=[5 15;
%            20 25;
%            75 115;
%            125 160;
%            160 175];
p=zeros(num_ch,length(freqBands));

for i=1:length(freqBands)
    p(:,i)=bandpower(clean_data,fs,freqBands(i,:))';
end

features=reshape([p,means],[1, num_ch*(length(freqBands)+1)]);

end
