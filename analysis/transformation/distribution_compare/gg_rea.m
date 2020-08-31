clc;clear;close all

datafile='gg_rea_param.mat';
if ~exist(datafile,'file')
    file={'/Users/localuser/Research/EMDNA/ERA5_downto_stn_nearest.mat',...
        '/Users/localuser/Research/EMDNA/MERRA2_downto_stn_nearest.mat',...
        '/Users/localuser/Research/EMDNA/JRA55_downto_stn_nearest.mat',...
        '/Users/localuser/Research/EMDNA/ERA5_downto_stn_GWR.mat',...
        '/Users/localuser/Research/EMDNA/MERRA2_downto_stn_GWR.mat',...
        '/Users/localuser/Research/EMDNA/JRA55_downto_stn_GWR.mat'};
    
    load(file{1},'stn_lle');
    nstn=size(stn_lle,1);
    c1=nan*zeros(nstn,6);
    c2=nan*zeros(nstn,6);
    beta=nan*zeros(nstn,6);
    stv=[1,0.6]; % start point of c1, c2
    range={[0.1,0.1],[15,2]}; % lower/upper of c1, c2
    for r=1:6
        load(file{r},'prcp_readown');
        for i=1:nstn
            pi=prcp_readown(i,:);
            pi=pi(pi>=0.1);
            if length(pi)>1000
                [c1(i,r),c2(i,r),beta(i,r)]=gg_parameter(pi,stv,range);
            end
        end
    end
    save(datafile,'c1','c2','beta','stn_lle');
else
    load(datafile,'c1','c2','beta','stn_lle');
end

% step=0.5;
% x=step:step:40;
% i=1;
% r=1;
% gg1=c2(i,r)/beta(i,r)/gamma(c1(i,r)/c2(i,r))*((x/beta(i,r)).^(c1(i,r)-1)).*(exp(-(x/beta(i,r)).^c2(i,r)));
% gg2=c2(i,r+3)/beta(i,r+3)/gamma(c1(i,r+3)/c2(i,r+3))*((x/beta(i,r+3)).^(c1(i,r+3)-1)).*(exp(-(x/beta(i,r+3)).^c2(i,r+3)));
% plot(x,gg1/sum(gg1),x,gg2/sum(gg2));
% legend({'near','GWR'});

c1=c1(:,4);
c2=c2(:,4);
beta=beta(:,4);

figure('color','w','unit','centimeters','position',[15,20,30,12]);
subplot(2,3,1)
scatter(stn_lle(:,2),stn_lle(:,1),5,c1,'filled');
colormap('jet')
colorbar
caxis([0,1.5])
title('c1 of GG based on reanalysis P')

subplot(2,3,2)
scatter(stn_lle(:,2),stn_lle(:,1),5,c2,'filled');
colormap('jet')
colorbar
caxis([0,1.5])
title('c2 of GG based on reanalysis P')

subplot(2,3,3)
scatter(stn_lle(:,2),stn_lle(:,1),5,beta,'filled');
colormap('jet')
colorbar
title('beta of GG based on reanalysis P')
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

% fig = gcf;
% fig.PaperPositionMode='auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(gcf,'-dpng',['gg_ear5','.png'],'-r600');
