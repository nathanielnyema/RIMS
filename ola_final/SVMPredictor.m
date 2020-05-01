classdef SVMPredictor < handle
    % Wrapper for regression SVM.
    % Combines five RegressionSVM models (one per finger).
    properties
        trained
        svm
        kernel
        params
    end
    
    methods
        function obj = SVMPredictor(kernel)
            obj.trained = false;
            obj.svm = cell(5,1);
            obj.kernel = kernel;
            obj.params = cell(5,1);
            for i = 1:5
                obj.params{i} = struct();
            end
        end
        
        function obj = train(obj, R, Y)
            % TRAIN trains the model.
            % R [N x M]: R matrix
            % Y [N x 5]: dataglove matrix
            svm_cell = cell(5,1);
            param_struct = obj.params;
            parfor i = 1:5 % train all 5 fingers in parallel
                args = namedargs2cell(param_struct{i});
                svm_cell{i} = fitrsvm(R, Y(:,i), 'KernelFunction', obj.kernel, args{:});
            end
            obj.svm = svm_cell;
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
            
            svm_cell = cell(5,1);
            for i = 1:5 % train all 5 fingers in parallel
                svm_cell{i} = fitrsvm(R, Y(:,i), ...
                    'KernelFunction', obj.kernel, ...
                    'OptimizeHyperparameters', params, ...
                    'HyperparameterOptimizationOptions', ...
                        struct('UseParallel', true, 'ShowPlots', false, 'MaxObjectiveEvaluations', 18));
                
                obj.params{i} = table2struct(svm_cell{i}.HyperparameterOptimizationResults.XAtMinObjective);
            end
            obj.svm = svm_cell;
            obj.trained = true;
        end
        
        function yhat = predict(obj, R)
            % PREDICT predicts DG outputs from feature matrix R.
            % R [N x M]: feature matrix
            % yhat [M x 5]: predicted dataglove values
            if ~obj.trained
                throw(MException('SVMPredictor:predict', 'Model is not trained.'));
            end
            
            yhat = zeros(size(R,1), 5);
            for i = 1:5
                yhat(:,i) = obj.svm{i}.predict(R);
            end
        end
    end
end