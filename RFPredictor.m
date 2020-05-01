classdef RFPredictor < handle
% Wrapper for regression tree ensemble.
% Combines five RegressionEnsemble models (one per finger).

properties
    trained
    model
    params
    template
end

methods
    function obj = RFPredictor()
        obj.trained = false;
        obj.model = cell(5,1);
        obj.params = cell(5,1);
        for i = 1:5
            obj.params{i} = struct();
            obj.template{i} = templateTree();
        end
    end

    function obj = train(obj, R, Y)
        % TRAIN trains the model.
        % R [N x M]: R matrix
        % Y [N x 5]: dataglove matrix
        model_cell = cell(5,1);
        param_struct = obj.params;
        templates = obj.template;
        parfor i = 1:5 % train all 5 fingers in parallel
            args = namedargs2cell(param_struct{i});
            model_cell{i} = fitrensemble(R, Y(:,i), 'Learners', templates{i}, args{:});
        end
        obj.model = model_cell;
        obj.trained = true;
    end

    function obj = optimize(obj, R, Y, params)
        % OPTIMIZE trains the model and optimizes hyperparameters
        % using cross-validation, then saves results to obj.params
        % R [N x M]: R matrix
        % Y [N x 5]: dataglove matrix
        % params (optional): cell array of names of parameters to optimize
        if ~exist('params', 'var')
            params = 'auto';
        end

        model_cell = cell(5,1);
        for i = 1:5 % train all 5 fingers in parallel
            model_cell{i} = fitrensemble(R, Y(:,i), ...
                'OptimizeHyperparameters', params, ...
                'HyperparameterOptimizationOptions', ...
                    struct('UseParallel', true, 'ShowPlots', false, 'MaxObjectiveEvaluations', 20));

            % Save params and template tree
            S = table2struct(model_cell{i}.HyperparameterOptimizationResults.XAtMinObjective);
            if isfield(S, 'Method')
                S.Method = char(S.Method);
            end
            if isnan(S.LearnRate)
                S = rmfield(S, 'LearnRate');
            end
            
            T = struct();
            for x = {'MinLeafSize', 'MaxNumSplits'}
                if isfield(S, x)
                    T.(x{1}) = S.(x{1});
                    S = rmfield(S, x{1});
                end
            end
            
            obj.params{i} = S;
            tree_args = namedargs2cell(T);
            obj.template{i} = templateTree(tree_args{:});
        end
        
        obj.model = model_cell;
        obj.trained = true;
    end

    function yhat = predict(obj, R)
        % PREDICT predicts DG outputs from feature matrix R.
        % R [N x M]: feature matrix
        % yhat [M x 5]: predicted dataglove values
        if ~obj.trained
            throw(MException('RFPredictor:predict', 'Model is not trained.'));
        end

        yhat = zeros(size(R,1), 5);
        for i = 1:5
            yhat(:,i) = obj.model{i}.predict(R);
        end
    end
end

end