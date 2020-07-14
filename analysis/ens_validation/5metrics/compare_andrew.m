clc;clear;
var='prcp';

file1=['/Users/localuser/GMET/EMDNA_evaluate/ens/stn_',var,'.mat'];
file2=['/Users/localuser/GMET/EMDNA_evaluate/ens/stn_',var,'_andrew.mat'];
d1=load(file1,'LLE');
d2=load(file2,'LLE');
[ind1,ind2]=ismember(d1.LLE,d2.LLE,'rows');
ind2(ind2==0)=[];

load(['variability_',var,'_scale1.mat'])
vmag=vmag(ind1,:);
% sum(vstd(:)==0)
nanmedian(vmag(:))
nanmean(vmag(:))

load(['variability_',var,'_andrew.mat'])
vmag=vmag(ind2,:);
% sum(vstd(:)==0)
nanmedian(vmag(:))
nanmean(vmag(:))