function [features] = get_features(clean_data,fs, channel_features, cross_chan)
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
feat_funcs.LLFn = @(x) nansum(abs(x(2:end,:)-x(1:end-1,:)),1);
feat_funcs.mean = @(x) mean(x,1)';
feat_funcs.kurt= @(x) kurtosis(x)';
feat_funcs.energy = @(x) sum(x .^ 2,1);
feat_funcs.went=@went;
feat_funcs.bandpow=@bandpow;
feat_funcs.pcbandpow=@pcbandpow;
feat_funcs.pdelta = @(x) bandpower(x, fs, [1 4])';
feat_funcs.ptheta = @(x) bandpower(x, fs, [4 8])';
feat_funcs.palpha = @(x) bandpower(x, fs, [8 12])';
feat_funcs.pbeta = @(x) bandpower(x, fs, [13 30])';
feat_funcs.pgamma = @(x) bandpower(x, fs, [30 70])';
feat_funcs.phgamma = @(x) bandpower(x, fs, [70 200])';

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
% cross channel
    function c=cross_corr(x)
        c=corr(x);
        c=c(logical(triu(c)))';
    end

    function e=evals(x)
        [~,~,e]=pca(x)';
    end

% per channel
    function bp=bandpow(x)
        freqBands=[5 15;
            20 25;
            75 115;
            125 160;
            160 175];
        bp=zeros(num_ch,length(freqBands));
        for j=1:length(freqBands)
            bp(:,j)=bandpower(x,fs,freqBands(j,:))';
        end
        
    end

    function pbp=pcbandpow(x)
        freqBands=[5 15;
            20 25;
            75 115;
            125 160;
            160 175];
        bp=zeros(num_ch,length(freqBands));
        for j=1:length(freqBands)
            bp(:,j)=bandpower(x,fs,freqBands(j,:))';
        end
        [~,pbp]=pca(bp);
    end
        

    function w=went(x)
        w=zeros(num_ch,1);
        for j=1:num_ch
            w(j) = wentropy(x(:,j), 'shannon')';
        end
    end
end
