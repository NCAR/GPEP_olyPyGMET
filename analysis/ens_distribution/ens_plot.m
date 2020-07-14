clc;clear;close all
% load('oi_ens_mean_201808.mat');
load('/Users/localuser/Downloads/oi_ens_mean_201608.mat')
ens_data(ens_data<-100)=nan;
v=1;
dp=nan*zeros(800,1300,6);
dp(:,:,1)=oi_data(:,:,v);
dp(:,:,2:end)=squeeze(ens_data(:,:,v,:));
dp=flipud(dp);

for i=1:6
    subplot(2,3,i)
    imagesc(dp(:,:,i),'alphadata',~isnan(dp(:,:,i)))
    colormap('jet');
    caxis([0,10]);
    xlim([500,1100]);
    ylim([400,600]);
end