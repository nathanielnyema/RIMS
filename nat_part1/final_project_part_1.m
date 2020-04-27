%% Final project part 1
% Prepared by John Bernabei and Brittany Scheid

% One of the oldest paradigms of BCI research is motor planning: predicting
% the movement of a limb using recordings from an ensemble of cells involved
% in motor control (usually in primary motor cortex, often called M1).

% This final project involves predicting finger flexion using intracranial EEG (ECoG) in three human
% subjects. The data and problem framing come from the 4th BCI Competition. For the details of the
% problem, experimental protocol, data, and evaluation, please see the original 4th BCI Competition
% documentation (included as separate document). The remainder of the current document discusses
% other aspects of the project relevant to BE521.


%% load in Data (0 points)
% load('final_proj_part1_data.mat');
load('raw_training_data.mat')
load('leaderboard_data.mat');
%% Extract dataglove and ECoG data 
% Dataglove should be (samples x 5) array 
% ECoG should be (samples x channels) array

% Split data into a train and test set (use at least 50% for training)

train=cell(1,3);
train2=cell(1,3);
test=cell(1,3);
test2=cell(1,3);


for i=1:3
    train{i}=train_ecog{i}(1:length(train_ecog{1})*.7,:);
    train2{i}=train_dg{i}(1:length(train_ecog{1})*.7,:);
    test{i}=train_ecog{i}(length(train_ecog{1})*.7+1:end,:);
    test2{i}=train_dg{i}(length(train_ecog{1})*.7+1:end,:);
end
%% Get Features

fs=1000; 
window_length=0.1; 
window_overlap=0.05;
% feats=cell(1,3);
% test_feats=cell(1,3);
all_feats=cell(1,3);
alltest_feats=cell(1,3);
fprintf('getting feats \n')
for i=1:3
    fprintf('pt %i \n',i)
%     feats{i}=getWindowedFeats(train{i}, fs, window_length, window_overlap);
%     test_feats{i}=getWindowedFeats(test{i}, fs, window_length, window_overlap);
    all_feats{i}=getWindowedFeats(train_ecog{i}, fs, window_length, window_overlap);
    alltest_feats{i}=getWindowedFeats(leaderboard_ecog{i}, fs, window_length, window_overlap);
end


%% Create R matrix
% R=cell(1,3);
% test_R=cell(1,3);

all_R=cell(1,3);
alltest_R=cell(1,3);

N_winds=3;
fprintf('creating R matrix \n')

for i=1:3
    fprintf('pt %i \n',i)
%     [R{i},zstats]=create_R_matrix(feats{i},N_winds,NaN, true);
%     R{i}=R{i}(1:end-1,:);
%     [test_R{i},~]=create_R_matrix(test_feats{i},N_winds, zstats, true);
%     test_R{i}=test_R{i}(1:end-1,:);
    [all_R{i},zstats]=create_R_matrix(all_feats{i},N_winds,NaN, true);
    all_R{i}=all_R{i}(1:end-1,:);
    [alltest_R{i},~]=create_R_matrix(alltest_feats{i},N_winds, zstats, true);
    alltest_R{i}=alltest_R{i}(1:end-1,:);
end


%% Train classifiers
% as a first pass try the optimal linear decoder
f=cell(1,3);
Y=cell(1,3);

% f2=cell(1,3);
% Y2=cell(1,3);
for i=1:3
%     Y{i}=downsample(train2{i},length(train2{i})/(size(R{i},1)+2));
%     f{i}=(R{i}' * R{i}) \ R{i}'*Y{i}(3:end,:);
    
    Y2{i}=downsample(train_dg{i},round(length(train_dg{i})/(size(all_R{i},1)+1)));
    f2{i}=(all_R{i}' * all_R{i}) \ all_R{i}'*Y2{i}(3:end,:);
end

[~,df]=lowpass(Y2{1},40,1e3);

%%
figure
plot(filtfilt(df,test_R{2}*f{2}(:,2)))
hold on
% plot(Y{1}(2:end,1))
plot(downsample(test2{2}(:,2),round(length(test2{2})/(size(test_R{2},1)+1))))
hold off
%%
figure
plot(filtfilt(df,R{2}*f{2}(:,2)))
hold on
% plot(Y{1}(2:end,1))
% plot(downsample(train2{2}(:,2),length(train2{2})/(size(R{2},1)+1)))
% hold off
%%
% figure
% d1=R{1}*f{1}(:,1);
% len=length(d1);
% p=fft(R{1}*f{1}(:,1));
% p=abs(p(1:len/2+1)/len);
% fr=fs*(0:len/2)/len;
% plot(fr,p)

%% Try a random forest
if isfile('random_forest.mat') && ~exist('rf_models')
    fprintf('loading models \n')
    load('random_forest.mat')
elseif ~isfile('random_forest.mat')
    fprintf('training model \n')
    rf_models=cell(3,5);
    for i=1:3
        for j=[1 2 3 5]
            fprintf('training pt %i finger %i \n',i,j)
            rf_models{i,j}=TreeBagger(64, R{i}, Y{i}(2:end,j), 'Method', 'regression');
        end
    end
    save('random_forest.mat','rf_models')
end
%%
% Try a form of either feature or prediction post-processing to try and
% improve underlying data or predictions.

% Not sure if this counts but in my create_R_matrix function, I z-score all
% the columns except the column of 1's.

%% Correlate data to get test accuracy and make figures (2 point)

% Calculate accuracy by correlating predicted and actual angles for each
% finger separately. Hint: You will want to use zohinterp to ensure both 
% vectors are the same length.

predicted_dg=cell(3,1);
% rf_test=cell(3,4);
Ypred_test=cell(3,1);

displ=(window_length-window_overlap)*fs;

for i=1:3
%     Ypred_test{i}=filtfilt(df,test_R{i}*f{i});
%     Ypred_test{i}=zointerp(Ypred_test{i},displ,length(test2{i}));
    
    predicted_dg{i}=alltest_R{i}*f2{i};
    predicted_dg{i}=zointerp(predicted_dg{i},displ,length(leaderboard_ecog{i}));
%     for j=1:4
%         rf_test{i,j}=zointerp(predict(rf_models{i,fings(j)},test_R{i}),...
%             displ,length(test{i}));
%     end
end

save('checkpoint2.mat','predicted_dg');
%% Plotting Patient 1 Predictions Optimal Linear Decoder
figure
for i=1:4
    subplot(2,2,i)
    plot(predicted_dg{1}(:,i),'b')
%     hold on
%     plot(test2{1}(:,i),'r')
%     legend('predicted','actual')
    xlabel('Samples')
    ylabel('Finger Angle')
    hold off
end

%% Plotting Patient 1 Predictions Random Forest

figure
fings=[1 2 3 5];
for i=1:4
    yfit=predict(rf_models{1,fings(i)},test_R{1});
    yfit=zointerp(yfit,displ,length(test{1}));
    subplot(2,2,i)
    plot(yfit,'b')
    hold on
    plot(test2{1}(:,i),'r')
    legend('predicted','actual')
    xlabel('Samples')
    ylabel('Finger Angle')
    hold off
end
%% Calculate Correlations

c=zeros(3,4);
c2=zeros(3,4);
fings=[1 2 3 5];
for i=1:3
    for j=1:4
        c(i,j)=corr(Ypred_test{i}(:,j),test2{i}(:,fings(j)));
%         c2(i,j)=corr(rf_test{i,j},test2{i}(:,fings(j)));
    end
end

array2table(c)
mean(c,1)
mean(c,'all')

array2table(c2)
mean(c2,1)
mean(c2,'all')

%% Functions

function y=zointerp(x,displ,len)
    y=zeros(len,size(x,2));
    I=eye(length(x));
    for i=1:length(x)
        y((i-1)*displ+1:i*displ,:)=repmat(x(logical(I(:,i)),:),displ,1);
    end
    y(i*displ+1:end,:)=repmat(y(i*displ,:),len-i*displ,1);
end


