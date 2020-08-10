clc;clear;close all
path='/Users/localuser/Research/EMDNA/ens_map';
year=2016;
month=8;
v=1; % 1 pcp; 2 tmean; 3 trange

% compare with andrew
dp1=nan*zeros(800,1300,3);
file=[path,'/oi_ens_mean_',num2str(year*100+month),'.mat'];
load(file)
ens_data(ens_data<-100)=nan;
dp1(:,:,1:3)=squeeze(ens_data(:,:,v,1:3));
dp1=flipud(dp1);

dp2=nan*zeros(224,464,3);
file=[path,'/andrew_ens_mean_',num2str(year*100+month),'.mat'];
load(file)
ens_data(ens_data<-100)=nan;
dp2(:,:,1:3)=squeeze(ens_data(:,:,v,1:3));
dp2=flipud(dp2);

for i=1:3
    subplot(2,3,i)
    imagesc(dp1(:,:,i),'alphadata',~isnan(dp1(:,:,i)))
    colormap('jet');
    caxis([0,10]);
    xlim([500,1100]);
    ylim([330,600]);
end
for i=1:3
    subplot(2,3,i+3)
    imagesc(dp2(:,:,i),'alphadata',~isnan(dp2(:,:,i)))
    colormap('jet');
    caxis([0,10]);
end