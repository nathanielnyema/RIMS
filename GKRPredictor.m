classdef GKRPredictor < handle
    % Wrapper for Matlab's Gaussian kernel regression algorithm.
    % Combines five RegressionKernel models (one per finger).
    properties
        trained
        model
        params
    end
    
    methods
        function obj = GKRPredictor()
            obj.trained = false;
            obj.model = cell(5,1);
            obj.params = cell(5,1);
            for i = 1:5
                obj.params{i} = struct();
            end
        end
        
        function obj = train(obj, R, Y)
            % TRAIN trains the model.
            % R [N x M]: R matrix
            % Y [N x 5]: dataglove matrix
            model_cell = cell(5,1);
            param_struct = obj.params;
            parfor i = 1:5 % train all 5 fingers in parallel
                args = namedargs2cell(param_struct{i});
                model_cell{i} = fitrkernel(R, Y(:,i), args{:});
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
                model_cell{i} = fitrkernel(R, Y(:,i), ...
                    'OptimizeHyperparameters', params, ...
                    'HyperparameterOptimizationOptions', ...
                        struct('UseParallel', true, 'ShowPlots', false, 'MaxObjectiveEvaluations', 18));                
                obj.params{i} = table2struct(model_cell{i}.HyperparameterOptimizationResults.XAtMinObjective);
            end
            obj.model = model_cell;
            obj.trained = true;
        end
        
        function yhat = predict(obj, R)
            % PREDICT predicts dataglove outputs from feature matrix R.
            % R [N x M]: feature matrix
            % yhat [M x 5]: predicted dataglove values
            if ~obj.trained
                throw(MException('GKRPredictor:predict', 'Model is not trained.'));
            end
            
            yhat = zeros(size(R,1), 5);
            models = obj.model;
            for i = 1:5
                yhat(:,i) = models{i}.predict(R);
            end
        end
    end
end