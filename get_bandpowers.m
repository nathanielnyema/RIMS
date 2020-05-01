function features = get_bandpowers(Pxx, F)
    % get_features2.m
    %
    % Description:  Compute bandpowers for all windows in parallel
    %
    % Input:    Pxx:    [frequencies x windows x channels]
    %           F:      vector of frequencies in Pxx
    %
    % Output:   features:   [windows x (features*channels)]

%% Your code here (8 points)
% delta  = @(Pxx,F) getbandpwr(Pxx, F, [1 5]);
delta  = [1 5];
theta  = [5 10];
alpha  = [10 15];
beta   = [15 30];
gamma  = [30 70];
hgamma = [70 200];
bands = [delta; theta; alpha; beta; gamma; hgamma];

n_feats = length(bands);
n_win = size(Pxx, 2);
n_ch = size(Pxx, 3);

feat_matrix = zeros(n_win, n_ch, n_feats);

% Compute features
for i = 1:n_feats
    band = bands(i,:);
    feat_matrix(:,:,i) = getbandpwr(Pxx, F, band);
end

% combine dimensions 2 and 3:
% features((i-1)*n_ch + j) = ith feature, jth channel
features = feat_matrix(:,:);

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
