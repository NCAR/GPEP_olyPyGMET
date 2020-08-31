clc;clear;close all

datafile='lognormal_stn_param.mat';
if ~exist(datafile,'file')
    load('/Users/localuser/Research/EMDNA/stndata_aftercheck.mat','prcp_stn','stninfo')
    nstn=size(prcp_stn,1);
    param_mean=nan*zeros(nstn,1);
    param_std=nan*zeros(nstn,1);
    for i=1:nstn
        pi=prcp_stn(i,:);
        pi=pi(pi>=0.1);
        if length(pi)>1000
            param = lognfit(double(pi));
            param_mean(i)=param(1);
            param_std(i)=param(2);
        end
    end
    save(datafile,'param_mean','param_std','stninfo');
else
    load(datafile,'param_mean','param_std','stninfo');
end

figure('color','w','unit','centimeters','position',[15,20,20,12]);
subplot(2,2,1)
scatter(stninfo(:,3),stninfo(:,2),1,param_mean,'filled');
colormap('jet')
colorbar
caxis([0,3])
title('mean of lognormal based on station P')

subplot(2,2,2)
scatter(stninfo(:,3),stninfo(:,2),1,param_std,'filled');
colormap('jet')
colorbar
caxis([0.5,2])
title('std of lognormal based on station P')

subplot(2,2,3)
histogram(param_mean,50);
xlim([0,3])

subplot(2,2,4)
histogram(param_std,50);
xlim([0.5,2])


fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(gcf,'-dpng',['lognormal_stn','.png'],'-r600');

