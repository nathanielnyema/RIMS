classdef LRPredictor < handle
    % Wrapper for linear regression.
    properties
        trained
        F
    end
    
    methods
        function obj = LRPredictor()
            obj.trained = false;
        end
        
        function obj = train(obj, X, Y)
            % TRAIN trains the model.
            % X [N x M]: feature
            % Y [N x 5]: dataglove matrix
            R = [ones(size(X,1), 1), X];
            obj.F = (R' * R) \ (R' * Y);
            obj.trained = true;
        end
        
        function obj = optimize(obj, X, Y)
            obj.train(X, Y);
        end
        
        function yhat = predict(obj, X)
            % PREDICT predicts DG outputs from feature matrix R.
            % R [N x M]: feature matrix
            % Yhat [M x 5]: predicted dataglove values
            if ~obj.trained
                throw(MException('LRPredictor:predict', 'Model is not trained.'));
            end
            R = [ones(size(X,1), 1), X];
            yhat = R * obj.F;
        end
    end
end