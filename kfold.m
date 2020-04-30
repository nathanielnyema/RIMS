function corr_matrix = kfold(n_folds, predictor, R, Y, dg, timestamps)
    % KFOLD k-fold cross validation.
    % n_folds: number of folds to use.
    % predictor: Predictor object
    % R: R matrix of ecog features
    % Y: downsampled dataglove
    % dg: raw dataglove
    % timestamps: indices of dg from which Y was sampled
    %
    % correlation_matrix [n_folds x 5]: correlation per fold per finger
    
    % get partition indices
    Nx = size(R, 1);
    Ny = size(dg, 1);
    partition_R = zeros(Nx, 1);
    fold_indices = round(linspace(1, Nx+1, n_folds+1));
    for k = 1:n_folds
        partition_R(fold_indices(k) : fold_indices(k+1) - 1) = k;
    end
    
    % shuffle
    rand_ix = randperm(Nx);
    partition_R = partition_R(rand_ix);
    
    % interpolate ecog partition to dataglove data
    partition_dg = zeros(Ny, 1);
    start = 1;
    for i = 1:Nx
        stop = timestamps(i);
        partition_dg(start:stop) = partition_R(i);
        start = stop + 1;
    end

    % cross validate
    corr_matrix = zeros(n_folds, 5);
    for k = 1:n_folds
        fold_ix = (partition_R == k);
        Xtrain = R(~fold_ix, :);
        Ytrain = Y(~fold_ix, :);
        Xtest = R(fold_ix, :);
%         Ytest = Y(fold_ix, :);
        dg_test = dg(partition_dg == k,:);
        
        predictor.train(Xtrain, Ytrain);
        Yest = predictor.predict(Xtest);
        dg_est = resample(Yest, size(dg_test,1), size(Xtest,1));
        corr_matrix(k,:) = diag(corr(dg_test, dg_est));

        % Plot (downsampled) true vs predicted dataglove data
%         figure
%         subplot(2,1,1); plot(Ytest); legend({'1' '2' '3' '4' '5'})
%         subplot(2,1,2); plot(Yest); legend({'1' '2' '3' '4' '5'})
%         diag(corr(Y(fold_ix,:), Yest))
    end
end
