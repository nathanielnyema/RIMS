function [R, zstats]=create_R_matrix(features, N_wind,zstats,z)
    %
    % get_features_release.m
    %
    % Instructions: Write a function to calculate R matrix.             
    %
    % Input:    features:   (samples x (channels*features))
    %           N_wind:     Number of windows to use
    %
    % Output:   R:          (samples x (N_wind*channels*features))
    % 
%% Your code here (5 points)
nsamp=size(features,1);
bigfeats=[features(1:N_wind-1,:);features];
R=[];
for i=N_wind:-1:1
    R=[R,bigfeats(i:i+nsamp-1,:)];
end

if z
    if ~isa(zstats,'struct')
        clear zstats
        zstats.mean=mean(R,1); zstats.std=std(R,1);
    end
end

R=[ones(nsamp,1),(R-zstats.mean)./zstats.std];

end