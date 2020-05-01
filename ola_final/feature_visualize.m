% small script for feature visualization
FINGER = 5;
ix = (Ymax{1}==FINGER);

v = R{1}(:,2:11);
vx = v(ix,:);
vy = v(~ix,:);

vxm = mean(vx,1);
vym = mean(vy,1);

vxs = std(vx,0,1);
vys = std(vy,0,1);

titles = {'LL' 'E' 'H' 'K' 'p-\delta' 'p-\theta' 'p-\alpha' 'p-\beta' 'p-\gamma' 'p-high\gamma'};
for i = 1:10
    subplot(2,5,i)
    bar([1 2], [vxm(i) vym(i)]); hold on
    errorbar([1 2], [vxm(i) vym(i)], [vxs(i) vys(i)]);
    title(titles{i});
end