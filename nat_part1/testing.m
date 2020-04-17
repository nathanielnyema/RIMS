
clean_data=filter_data(train{1});
%%
fs=1000;
figure
subplot(3,1,1)
for i=1:size(clean_data,2)
    plot(linspace(0,length(train{1})/fs,length(train{1}))',clean_data(:,i)+i*1e4)
    hold on
end
ylim([2.5e5 3e5])
xlim([0 25])
hold off

subplot(3,1,2)
ind=zeros(size(clean_data,2),10000);

for i=1:size(clean_data,2)
    if ~exist('t','var')
        [s,w,t]=spectrogram(clean_data(:,i), .0001*length(train{1}), 0 , linspace(0,200,500), 1e3, 'yaxis');
        [~,ind(i,:)]=max(abs(s),[],1);
        ind(i,:)=ind(i,:)+400*i;
    else
        [s,~,~]=spectrogram(clean_data(:,i), .0001*length(train{1}), 0 , linspace(0,200,500), 1e3, 'yaxis');
        [~,ind(i,:)]=max(abs(s),[],1);
        ind(i,:)=ind(i,:)+400*i;
    end
end

plot(t,ind')
% spectrogram(train{1}(:,1), .0001*length(train{1}), 0 , 2000, 1e3, 'yaxis')

ylim([0 5e3])
xlim([0 25/60])

subplot(3,1,3)

for i=1:5
    plot(linspace(0,length(train{1})/fs,length(train{1}))',train2{1}(:,i)+i)
    hold on
end
xlim([0 25])
hold off