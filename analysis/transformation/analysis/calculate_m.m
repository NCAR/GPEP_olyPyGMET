clc;clear;close all
bss_mean=zeros(21,6);
bss_median=zeros(21,6);
for i=1:20
    file=['ensval_2016_',num2str(i),'.mat'];
    load(file,'bss');
    bss(bss<-5)=nan;
    bss_mean(i,:)=nanmean(bss);
    bss_median(i,:)=nanmedian(bss);
end
load('ensval_2016_fixbc.mat','bss');
bss(bss<-5)=nan;
bss_median(21,:)=nanmedian(bss);
bss_mean(21,:)=nanmean(bss);


figure('color','w');
plot(bss_mean);
legend({'0','5','10','15','20','25'});
xlabel('Function number');
ylabel('BSS');
fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(gcf,'-dpng',['bss','.png'],'-r300');