clc;clear;close all

Outfigure='pop_Clim_hist';
datafile='clim_pop.mat';
load(datafile,'pop_stn','pop_ens','LLE','num');
dataplot=pop_ens(:,1)-pop_stn(:,1);

m1=nanmean(dataplot);
m2=nanmedian(dataplot);

figure('color','w','unit','centimeters','position',[15,20,12,8]);

histogram(dataplot,'Normalization','probability')
ylabel('Probability');
xlabel('Ensemble PoP minus Station PoP');
text(-0.25,0.1,{['Mean = ',num2str(m1,'%.3f')],['Median = ',num2str(m2,'%.3f')]});

fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(gcf,'-dpng',[Outfigure,'.png'],'-r600');


