function y=zointerp(x,displ,len)

    % zointerp.m
    %
    % Input:   x: downsampled predictions
    %          displ: window displacement during feature extraction
    %          len: intended length of data (147500 in the case of
    %          leaderboard predictions)
    %%
    y=zeros(len,size(x,2));
    I=eye(length(x));
    for i=1:length(x)
        y((i-1)*displ+1:i*displ,:)=repmat(x(logical(I(:,i)),:),displ,1);
    end
    y(i*displ+1:end,:)=repmat(y(i*displ,:),len-i*displ,1);
end