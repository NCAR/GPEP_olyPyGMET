clc;clear
file1='C:\Users\TGQ\Downloads\metric_prcp_nolag.mat';
stn1='C:\Users\TGQ\Downloads\stn_prcp_nolag.mat';
file2='C:\Users\TGQ\Downloads\metric_prcp_andrew.mat';
stn2='C:\Users\TGQ\Downloads\stn_prcp_andrew.mat';

% find the same stations
load(stn1,'LLE'); LLE1=LLE; clear LLE;
load(stn2,'LLE'); LLE2=LLE; clear LLE;
[ind1,ind2]=ismember(LLE1,LLE2,'rows');
ind2(ind2==0)=[];
LLE=LLE1(ind1,:);

% calcualte the mean of metrics
load(file1,'metric'); metric=metric(ind1,:,:);
MM(:,1)=nanmean(nanmean(metric,3));
load(file2,'metric'); metric=metric(ind2,:,:);
MM(:,2)=nanmean(nanmean(metric,3));

% calcualte the mean metric for one station
metnum=12;
load(file1,'metric'); metric=squeeze(metric(ind1,metnum,:));
MM2(:,1)=nanmedian(metric,2);
load(file2,'metric'); metric=squeeze(metric(ind2,metnum,:));
MM2(:,2)=nanmedian(metric,2);
scatter(LLE(:,2),LLE(:,1),5,MM2(:,1)-MM2(:,2),'filled')
caxis([-0.2,0.2])
colormap(jet)
colorbar
title('prcp  KGE: My - Andrew');