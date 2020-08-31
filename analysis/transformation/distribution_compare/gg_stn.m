clc;clear;close all

datafile='gg_stn_param.mat';
if ~exist(datafile,'file')
    load('/Users/localuser/Research/EMDNA/stndata_aftercheck.mat','prcp_stn','stninfo')
    nstn=size(prcp_stn,1);
    c1=nan*zeros(nstn,1);
    c2=nan*zeros(nstn,1);
    beta=nan*zeros(nstn,1);
    stv=[1,0.6]; % start point of c1, c2
    range={[0.1,0.1],[15,2]}; % lower/upper of c1, c2
    for i=1:nstn
        pi=prcp_stn(i,:);
        pi=pi(pi>=0.1);
        if length(pi)>1000
            [c1(i),c2(i),beta(i)]=gg_parameter(pi,stv,range);
        end
    end
    save(datafile,'c1','c2','beta','stninfo');
else
    load(datafile,'c1','c2','beta','stninfo');
end

% step=0.5;
% x=step:step:40;
% for i=1:length(c1)
%     gg=c2(i)/beta(i)/gamma(c1(i)/c2(i))*((x/beta(i)).^(c1(i)-1)).*(exp(-(x/beta(i)).^c2(i)));
%     plot(x,gg/sum(gg));
% end

figure('color','w','unit','centimeters','position',[15,20,30,12]);
subplot(2,3,1)
scatter(stninfo(:,3),stninfo(:,2),1,c1,'filled');
colormap('jet')
colorbar
caxis([0,1.5])
title('c1 of GG based on station P')

subplot(2,3,2)
scatter(stninfo(:,3),stninfo(:,2),1,c2,'filled');
colormap('jet')
colorbar
caxis([0,1.5])
title('c2 of GG based on station P')

subplot(2,3,3)
scatter(stninfo(:,3),stninfo(:,2),1,beta,'filled');
colormap('jet')
colorbar
title('beta of GG based on station P')
caxis([0,10]);


data=cell(3,1);
data{1}=c1;
data{2}=c1;
data{3}=c1;
for i=1:3
   subplot(2,3,i+3)
   histogram(data{i},50);
   xlim([0,6])
end

fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(gcf,'-dpng',['gg_stn','.png'],'-r600');

