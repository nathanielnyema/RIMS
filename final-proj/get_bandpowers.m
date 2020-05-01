function features = get_bandpowers(Pxx, F, bands, do_pca)
% get_bandpowers.m
%
% Description:  Compute bandpowers for all windows in parallel
%
% Input:    Pxx:    [frequencies x windows x channels]
%           F:      vector of frequencies in Pxx
%
% Output:   features:   [windows x (features*channels)]

if ~exist('bands', 'var') || isempty(bands)
%     delta  = [1 5];
%     theta  = [5 10];
%     alpha  = [10 15];
%     beta   = [15 30];
%     gamma  = [30 70];
%     hgamma = [70 200];
%     bands = [delta; theta; alpha; beta; gamma; hgamma];
    bands = [
        5   15;
        20  25;
        75  115;
        125 160;
        160 175;
    ];
end
if ~exist('do_pca', 'var')
    do_pca = false;
end

n_feats = length(bands);
n_win = size(Pxx, 2);
n_ch = size(Pxx, 3);

% Compute features
feat_matrix = zeros(n_win, n_ch, n_feats);
for i = 1:n_feats
    band = bands(i,:);
    feat_matrix(:,:,i) = getbandpwr(Pxx, F, band);
end


if do_pca
    feat_pca = cell(n_win,1);
    for i = 1:n_win
        [~,feat_pca{i}] = pca(squeeze(feat_matrix(i,:,:)));
    end
    n_comp = size(feat_pca{1}, 2);
    features = reshape(cell2mat(feat_pca), [n_win n_ch n_comp]);
    features = features(:,:); % features((i-1)*n_ch + j) = ith principal component, jth channel
else
    % combine dimensions 2 and 3:
    % features((i-1)*n_ch + j) = ith band, jth channel
    features = feat_matrix(:,:);
end

function p = getbandpwr(Pxx, F, freqrange)
    % Pxx: power spectral density [frequency x window x channel]
    % F: vector of frequency values
    % freqrange: [f_low, f_high]
    % output: [frequency x channel]
    width = [diff(F); 0];
    i1 = find(F <= freqrange(1), 1, 'last');
    i2 = find(F >= freqrange(2), 1, 'first');
    p = squeeze(sum( width(i1:i2) .* Pxx(i1:i2,:,:), 1));
end

end
