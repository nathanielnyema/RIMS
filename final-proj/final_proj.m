%% load in Data
load('raw_training_data.mat');
load('leaderboard_data.mat');
% mypool=parpool(2);
%% Split up training and testing set

train=cell(1,3);
train2=cell(1,3);
test=cell(1,3);
test2=cell(1,3);

%using a quarter of the training data for training and testing purposes
for i=1:3
    train{i}=train_ecog{i}(1:length(train_ecog{1})*.25,:);
    train2{i}=train_dg{i}(1:length(train_ecog{1})*.25,:);
    test{i}=train_ecog{i}(length(train_ecog{1})*.25+1:end,:);
    test2{i}=train_dg{i}(length(train_ecog{1})*.25+1:end,:);
end

%% Model and Data Parameters
fs=1000; 
window_length=0.1; 
window_overlap=0.05;
N_winds=3;
channel_feats=["mean","pcbandpow"];
cross_chan=[];
%% Get Features
feats=cell(1,3);
test_feats=cell(1,3);
all_feats=cell(1,3);
alltest_feats=cell(1,3);

fprintf('getting feats \n')
for i=1:3
    fprintf('pt %i. ',i)
    fprintf('training feats. ')
    feats{i}=getWindowedFeats(train{i}, fs, window_length, window_overlap,channel_feats,cross_chan);
    fprintf('testing feats. ')
    test_feats{i}=getWindowedFeats(test{i}, fs, window_length, window_overlap,channel_feats,cross_chan);
    fprintf('all training feats. ')
    all_feats{i}=getWindowedFeats(train_ecog{i}, fs, window_length, window_overlap,channel_feats,cross_chan);
    fprintf('leaderboard feats \n')
    alltest_feats{i}=getWindowedFeats(leaderboard_ecog{i}, fs, window_length, window_overlap,channel_feats,cross_chan);
end
%% Create R and Y matrices
R=cell(1,3);
test_R=cell(1,3);
Y=cell(1,3);

all_R=cell(1,3);
alltest_R=cell(1,3);
train_Y=cell(1,3);

fprintf('creating R matrix \n')

for i=1:3
    fprintf('pt %i \n',i)
    [R{i},zstats]=create_R_matrix(feats{i},N_winds,NaN, true);
    [test_R{i},~]=create_R_matrix(test_feats{i},N_winds, zstats, true);
    [all_R{i},zstats]=create_R_matrix(all_feats{i},N_winds,NaN, true);
    [alltest_R{i},~]=create_R_matrix(alltest_feats{i},N_winds, zstats, true);
    Y{i}=downsample(train2{i},round(length(train2{i})/(size(R{i},1)+2)));
    Y{i}=Y{i}(2:end,:);
    train_Y{i}=downsample(train_dg{i},round(length(train_dg{i})/(size(all_R{i},1)+2)));
    train_Y{i}=train_Y{i}(2:end,:);
end
%% quick cross validation with linear decoder (mainly to test out features )
means=zeros(1,3);
for pt=1:3
    r=all_R{pt};
    y=train_Y{pt};
    folds=reshape(randperm(length(r)-3),4,(length(r)-3)/4);
    corrs=zeros(1,4);
    for i=1:4
        rf=r(folds([1:i-1,i+1:4],:),:);
        yf=y(folds([1:i-1,i+1:4],:),:);
        ff=(rf'*rf)\(rf'*yf);
        pf=r(folds(i,:),:)*ff;
        yyf=y(folds(i,:),:);
        corrs(i)=mean(diag(corr(pf,yyf)));
    end
    means(pt)=mean(corrs);
end
means

%% TODO: implement some feature selection
%% BUILD THE CLASSIFIERS WITH ALL DATA
%% train svm
trainsvm= @(r,y) fitrsvm(r,y,'KFold',5);
if ~exist('svm_models')
    rf_models=load_train('svm.mat','svm_models', trainsvm, all_R, train_Y);
end

%% predict with svm
%% train random forest only if it hasnt been already
paroptions=statset('UseParallel',true);
trainforest=@(r,y) TreeBagger(64, r, y, 'Method',...
    'regression', 'OOBPredictorImportance','on','Options',paroptions);

if ~exist('rf_models')
    rf_models=load_train('random_forest.mat','rf_models',trainforest,all_R,train_Y);
end

%% predict with random forest
predicted_dg=cell(3,1);
displ=(window_length-window_overlap)*fs;
for i=1:3
    for j=[1 2 3 5]
        fprintf('predicting pt %i finger %i \n',i,j)
        predicted_dg{i}(:,j)=zointerp(predict(rf_models{i,j},alltest_R{i}),...
            displ,length(leaderboard_ecog{i}));
%         predicted_dg{i}(:,j)=movmean(predicted_dg{i}(:,j),100);
    end
end

save('checkpoint2v2.mat','predicted_dg');
%% make plots
figure
plot(movmean(predicted_dg{1}(:,1),100))

