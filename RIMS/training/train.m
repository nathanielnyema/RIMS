%% load in Data
addpath ../
addpath ../utilities
load raw_training_data.mat
load leaderboard_data.mat

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
% window length on overlap chosen keeping in mind that data is sampled at
% an fs of 25 Hz which corresponds to one sample per .04s
window_length=0.08; 
window_overlap=0.04;
% channel_feats=["mean","bandpow","LLFn","kurt","energy"];
% cross_chan=[];
%% Get Features and downsample dg data
feats=cell(1,3);
test_feats=cell(1,3);
all_feats=cell(1,3);
alltest_feats=cell(1,3);

fprintf('getting feats \n')
for i=1:3
    fprintf('pt %i. ',i)
    fprintf('training feats. ')
    [feats{i},~]=getWindowedFeats(train{i}, fs, window_length, window_overlap);
    fprintf('testing feats. ')
    [test_feats{i},~]=getWindowedFeats(test{i}, fs, window_length, window_overlap);
    fprintf('all training feats. ')
    [all_feats{i},~]=getWindowedFeats(train_ecog{i}, fs, window_length, window_overlap);
    fprintf('leaderboard feats \n')
    [alltest_feats{i},~]=getWindowedFeats(leaderboard_ecog{i}, fs, window_length, window_overlap);
end
%% 
Y=cell(1,3);
Ytest=cell(1,3);
train_Y=cell(1,3);
fprintf('downsampling Y \n')
for i=1:3
    Y{i}=downsample(train2{i},round(length(train2{i})/(size(feats{i},1)+2)));
    Y{i}=Y{i}(2:end,:);
    Ytest{i}=downsample(test2{i},round(length(test2{i})/(size(test_feats{i},1)+2)));
    Ytest{i}=Ytest{i}(2:end,:);
    train_Y{i}=downsample(train_dg{i},round(length(train_dg{i})/(size(all_feats{i},1)+2)));
    train_Y{i}=train_Y{i}(2:end,:);
end
%% an attempt at forward selection with the mrmr algorithm using all data
% idxs2=cell(3,1);
% scores=cell(3,1);
% for i=1:3
%     for j=[1 2 3 5]
%         fprintf('pt %i finger %i \n',i,j)
%         [idxs2{i}(:,j),scores{i}(:,j)]=fscmrmr(all_feats{i},train_Y{i}(:,j));
%     end
% end
% save('../models/selected2.mat','idxs2')

load('../models/selected2.mat')
%% plot scores to determine how many features to cut
% count=1;
% figure
% for i=1:3
%     for j=[1 2 3 5]
%         subplot(3,4,count)
%         bar(scores{i}(idxs2{i}(:,j),j))
%         count=count+1;
%     end
% end
%% create new feature matrices for each finger with selected features

num_feats=200; % based on bar plots above
reduced_train=cell(3,5);
reduced_test=cell(3,5);
reduced_alltr=cell(3,5);
reduced_allte=cell(3,5);

for i=1:3
    for j=[1 2 3 5]
        reduced_train{i,j}=feats{i}(:,idxs2{i}(1:num_feats,j));
        reduced_test{i,j}=test_feats{i}(:,idxs2{i}(1:num_feats,j));
        reduced_alltr{i,j}=all_feats{i}(:,idxs2{i}(1:num_feats,j));
        reduced_allte{i,j}=alltest_feats{i}(:,idxs2{i}(1:num_feats,j));
    end
end
%% try plotting features to see what they look like
% also test out movmean window sizes

pt=1;
fing=2;
feat=2;
wind=40;

figure
subplot(1,2,1)
plot(movmean(reduced_alltr{pt,fing}(:,feat),wind))

% fft of features
featfs=25;
l=length(reduced_alltr{pt,fing});
power=abs(fft(movmean(reduced_alltr{pt,fing}(:,feat),wind)));
freqs=featfs*(0:l/2)/l;

subplot(1,2,2)
plot(freqs,power(1:l/2+1))

%% filter feats for regression

wind=40; % based on prior plots above
proc_train=cell(3,5);
proc_test=cell(3,5);
proc_alltr=cell(3,5);
proc_allte=cell(3,5);

for i=1:3
    for j=[1 2 3 5]
        proc_train{i,j}=movmean(reduced_train{i,j},wind);
        proc_test{i,j}=movmean(reduced_test{i,j},wind);
        proc_alltr{i,j}=movmean(reduced_alltr{i,j},wind);
        proc_allte{i,j}=movmean(reduced_allte{i,j},wind);
    end
end
%% try random forest regression model with 8 trees 
% (less trees for less training time to make sure things are working)
rf8=cell(3,5);
paroptions=statset('UseParallel',true);
for i=1:3
    for j=[1 2 3 5]
        fprintf('pt %i finger %i \n',i,j)
        rf8{i,j}=TreeBagger(8, proc_train{i,j}, Y{i}(:,j), 'Method',...
            'regression', 'OOBPredictorImportance','on',...
            'Options',paroptions);
    end
end
%% try predicting and plot
pt=1;
fing=2;
figure
plot(Ytest{pt}(:,fing))
hold on
plot(predict(rf8{pt,fing},proc_test{pt,fing}));
hold off

%% from here on we incrementally train and add more trees to our model
% and occassionally test our progress


% start with 64 and test then we'll append afterwards

% rf64=cell(3,5);
% paroptions=statset('UseParallel',true);
% for i=1:3
%     for j=[1 2 3 5]
%         fprintf('pt %i finger %i \n',i,j)
%         rf64{i,j}=TreeBagger(64, proc_alltr{i,j}, train_Y{i}(:,j), 'Method',...
%             'regression', 'OOBPredictorImportance','on',...
%             'Options',paroptions);
%     end
% end
% 
% save('../models/random_forest64.mat','rf64')

load('../models/random_forest64.mat')

%% try predicting and plot pt 2
pt=1;
fing=2;
figure
plot(predict(rf64{pt,fing},proc_allte{pt,fing}));

%% grow to 128
% rf128=cell(3,5);
% for i=1:3
%     for j=[1 2 3 5]
%         fprintf('pt %i finger %i \n',i,j)
%         rf128{i,j}=growTrees(rf64{i,j},64);
%     end
% end
% 
% save('../models/random_forest128.mat','rf128')

load('../models/random_forest128.mat')
%% try predicting and plot pt 3
pt=1;
fing=2;
figure
plot(predict(rf128{pt,fing},proc_allte{pt,fing}));

%% grow to 256
% rf256=cell(3,5);
% for i=1:3
%     for j=[1 2 3 5]
%         fprintf('pt %i finger %i \n',i,j)
%         rf256{i,j}=growTrees(rf128{i,j},128);
%     end
% end
% 
% save('../models/random_forest256.mat','rf256')

load('../models/random_forest256.mat')

%% try predicting and plot pt 4
pt=1;
fing=2;
figure
plot(predict(rf64{pt,fing},proc_allte{pt,fing}),'k');
hold on
plot(predict(rf128{pt,fing},proc_allte{pt,fing}),'b');
hold on
plot(predict(rf256{pt,fing},proc_allte{pt,fing}),'r');
hold off
%% grow to 384
% rf384=cell(3,5);
% for i=1:3
%     for j=[1 2 3 5]
%         fprintf('pt %i finger %i \n',i,j)
%         rf384{i,j}=growTrees(rf256{i,j},128);
%     end
% end
% 
% save('../models/random_forest384.mat','rf384')

load('../models/random_forest384.mat')
%% try predicting and plot pt 4
pt=3;
fing=2;
figure
plot(predict(rf384{pt,fing},proc_allte{pt,fing}),'k');

%% determine the optimal number of trees based on the correlation of
% oob predictions with training data
fings=[1 2 3 5];
r_64=zeros(3,5);
r_128=zeros(3,5);
r_256=zeros(3,5);
r_384=zeros(3,5);

for i=1:3
    for j=[1 2 3 5]
        fprintf('pt %i finger %i. ',i,j)
        fprintf('64. ')
        r_64(i,j) = corr( oobPredict(rf64{i,j}), rf64{i,j}.Y );
        fprintf('128. ')
        r_128(i,j) = corr( oobPredict(rf128{i,j}), rf128{i,j}.Y );
        fprintf('256. ')
        r_256(i,j) = corr( oobPredict(rf256{i,j}), rf256{i,j}.Y );
        fprintf('384 \n')
        r_384(i,j) = corr( oobPredict(rf384{i,j}), rf384{i,j}.Y );
    end
end

r_64=mean(mean( r_64(:,fings) ))
r_128=mean(mean( r_128(:,fings) ))
r_256=mean(mean( r_256(:,fings) ))
r_384=mean(mean( r_384(:,fings) ))

%% out of bag correlation seems to still be increasing but assymptotically
% we'll add 128 to end at 512 trees
% 
% rf512=cell(3,5);
% for i=1:3
%     for j=[1 2 3 5]
%         fprintf('pt %i finger %i \n',i,j)
%         rf512{i,j}=growTrees(rf384{i,j},128);
%     end
% end
% 
% save('../models/final_model.mat','rf512')

load('../models/final_model.mat')

%% try predicting and plot pt 5
pt=3;
fing=2;
figure
plot(predict(rf512{pt,fing},proc_allte{pt,fing}),'k');

%% check out of bag prediction correlation
r_512=zeros(3,5);

for i=1:3
    for j=[1 2 3 5]
        fprintf('pt %i finger %i \n',i,j)
        r_512(i,j) = corr( oobPredict(rf512{i,j}), rf512{i,j}.Y );
    end
end
        
r_512=mean(mean( r_512(:,fings) ))

%% make final predictions for leaderboard
predicted_dg=make_predictions(leaderboard_ecog);
save('../predictions/final_preds.mat','predicted_dg')
