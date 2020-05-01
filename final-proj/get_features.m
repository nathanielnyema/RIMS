function [features] = get_features(clean_data, fs, channel_features, cross_chan)
    %
    % get_features.m
    %
    % Input:    clean_data: (samples x channels)
    %           fs:         sampling frequency
    %           channel_features: string array of per channel features to
    %           calculate. names must match the field names in the
    %           feat_funcs struct
    %           cross_chan: string array of cross channel features to 
    %           calculate. names must match the field names in the
    %           feat_funcs struct 
    %
    % Output:   features:   (1 x (channels*features))
    % 
%% create structure of function handles for features
num_ch=size(clean_data,2);
%channel level features
feat_funcs.LLFn = @(x) sum(abs(diff(x)), 1);
feat_funcs.mean = @(x) mean(x,1);
feat_funcs.kurt= @(x) kurtosis(x);
feat_funcs.energy = @(x) sum(x .^ 2,1);
% feat_funcs.bandpow=@bandpow; % moved to get_bandpowers()
% feat_funcs.pcbandpow=@pcbandpow;

%cross channel features
feat_funcs.cc=@cross_corr;
feat_funcs.evals=@evals;

%% create the feature vector

%loop through specified channel features and calculate
chfeats=cell(1,length(channel_features));
for i=1:length(channel_features)
    chfeats{i}=feat_funcs.(channel_features(i))(clean_data);
end
chfeats=reshape(cell2mat(chfeats),1,[]);

%loop through specified cross channel features and calculate
ccfeats=cell(1,length(cross_chan));
for i=1:length(cross_chan)
    ccfeats{i}=feat_funcs.(cross_chan(i))(clean_data);
end

ccfeats=cell2mat(ccfeats);
features=[chfeats,ccfeats];

%% longer functions
function w = went(x,~)
    % shannon wavelet entropy
    % x: [time x channel] or [time x channel x window]
    % output: [1 x channel] or [1 x channel x window]
    w = x.^2;
    w = -sum(w .* log(eps+w), 1);
end
% cross channel (need to vectorize these)
    function c=cross_corr(x)
        c=corr(x);
        c=c(logical(triu(c)))';
    end

    function e=evals(x)
        [~,~,e]=pca(x)';
    end

end
