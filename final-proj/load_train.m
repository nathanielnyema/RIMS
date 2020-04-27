function model=load_train(filename, varname, trainfunc, R, Y )
    %load_train.m
    %
    % Input:      filename: string name of file to save models to
    %             varname: string of variable name to save models to
    %             trainfunc: function handle for training
    %             R: cell array of feature/R matrices
    %             Y: cell array of downsampled training finger movements
%%
if isfile(filename)
    fprintf('loading models \n')
    model=load(filename);
    model=model.(varname);
elseif ~isfile(filename)
    fprintf('training model \n')
    model=cell(3,5);
    for i=1:3
        for j=[1 2 3 5] %only training on the necessary fingers
            fprintf('training pt %i finger %i \n',i,j)
            model{i,j}=trainfunc(R{i},Y{i}(:,j));
        end
    end
    assignin('caller',varname, model)
    save(filename,varname)
end



end