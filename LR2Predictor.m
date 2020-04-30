classdef LR2Predictor < handle
    % Wrapper for Matlab's builtin linear regression algorithm.
    % Combines five RegressionLinear models (one per finger).
    properties
        trained
        model
        params
    end
    
    methods
        function obj = LR2Predictor()
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
            for i = 1:5 % train all 5 fingers in parallel
                args = namedargs2cell(param_struct{i});
                model_cell{i} = fitrlinear(R, Y(:,i), args{:});
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
                model_cell{i} = fitrlinear(R, Y(:,i), ...
                    'OptimizeHyperparameters', params, ...
                    'HyperparameterOptimizationOptions', ...
                        struct('UseParallel', true, 'ShowPlots', false));
                
                S = model_cell{i}.ModelParameters;
                names = fieldnames(S);
                ix = cellfun(@(x) ~any(strcmp(params,x)), names);
                obj.params{i} = rmfield(S, names(ix));
            end
            obj.model = model_cell;
            obj.trained = true;
        end
        
        function yhat = predict(obj, R)
            % PREDICT predicts dataglove outputs from feature matrix R.
            % R [N x M]: feature matrix
            % yhat [M x 5]: predicted dataglove values
            if ~obj.trained
                throw(MException('LR2Predictor:predict', 'Model is not trained.'));
            end
            
            yhat = zeros(size(R,1), 5);
            for i = 1:5
                yhat(:,i) = obj.model{i}.predict(R);
            end
        end
    end
end