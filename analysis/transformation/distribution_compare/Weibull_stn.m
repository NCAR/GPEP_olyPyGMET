clc;clear;close all

datafile='weibull_stn_param.mat';
if ~exist(datafile,'file')
    load('/Users/localuser/Research/EMDNA/stndata_aftercheck.mat','prcp_stn','stninfo')
    nstn=size(prcp_stn,1);
    a=nan*zeros(nstn,1);
    b=nan*zeros(nstn,1);
    for i=1:nstn
        pi=prcp_stn(i,:);
        pi=pi(pi>=0.1);
        if length(pi)>1000
            param=wblfit(double(pi));
            a(i)=param(1);
            b(i)=param(2);
        end
    end
    save(datafile,'a','b','stninfo');
else
    load(datafile,'a','b','stninfo');
end

figure('color','w','unit','centimeters','position',[15,20,20,12]);
subplot(2,2,1)
scatter(stninfo(:,3),stninfo(:,2),1,a,'filled');
colormap('jet')
colorbar
caxis([0,10])
title('a of Weibull based on station P')

subplot(2,2,2)
scatter(stninfo(:,3),stninfo(:,2),1,b,'filled');
colormap('jet')
colorbar
caxis([0.5,1.2])
title('b of Weibull based on station P')

subplot(2,2,3)
histogram(a,50);
xlim([0,20])

subplot(2,2,4)
histogram(b,50);
xlim([0,1.5])


fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(gcf,'-dpng',['weibull_stn','.png'],'-r600');

