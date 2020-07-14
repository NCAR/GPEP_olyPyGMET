clc;clear;close all

var='prcp';
file1=['/Users/localuser/GMET/EMDNA_evaluate/ens/stn_',var,'.mat'];
file2=['/Users/localuser/GMET/EMDNA_evaluate/ens/stn_',var,'_andrew.mat'];
d1=load(file1,'LLE');
d2=load(file2,'LLE');
[ind1,ind2]=ismember(d1.LLE,d2.LLE,'rows');
ind2(ind2==0)=[];


load(['variability_',var,'_scale1.mat'])
rank1=rank(ind1,:);clear rank
load(['variability_',var,'_scale1.5.mat'])
rank2=rank(ind2,:);clear rank

figure('color','w')
subplot(2,1,1)
histogram(rank1(:),100)
% ylim([0,50000])
% ylim([0,15000])
title('EMDNA')

subplot(2,1,2)
histogram(rank2(:),100)
% ylim([0,50000])
% ylim([0,15000])
title('EMDNA')