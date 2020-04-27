p=fft(clean_data(1:window_length*fs,:));
len=size(p,1);
p=abs(p(1:len/2+1,:)/len);
len=size(p,1);
ps=zeros((len-1)/2,size(clean_data,2));
for i=1:size(clean_data,2)
    ps(:,i)=mean(reshape(p(2:end,i),2,(len-1)/2)',2);
end

% figure
% plot(f,p)