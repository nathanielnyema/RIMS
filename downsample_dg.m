function Y = downsample_dg(dg, timestamps)
% downsample_dg.m
%
% Description:  Downsamples dataglove data using a shifting window average
%
% Input:    dg          raw dataglove data
%           timestamps  points to be sampled
%
% Output:   Y   downsampled dataglove
Y = zeros(length(timestamps), size(dg,2));
start = 1;
for i = 1:length(timestamps)
    stop = timestamps(i);
    Y(i,:) = mean(dg(start:stop,:), 1);
    start = stop + 1;
end