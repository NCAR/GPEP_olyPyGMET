clc;clear


% load('/Users/localuser/GMET/results/stn_prcp.mat');
% LLE1=LLE;
% load('/Users/localuser/GMET/results/stn_prcp12.mat');
% LLE2=LLE;
% [ind1,ind2]=ismember(LLE2,LLE1,'rows');
% ind2(ind2==0)=[];
% load('metric_prcp.mat');
% metric1=metric;
% metric1=metric1(ind2,:,1:5);
% KGE1=squeeze(metric1(:,12,:));
% 
% load('metric_prcp12.mat');
% metric2=metric;
% metric2=metric2(ind1,:,:);
% KGE2=squeeze(metric2(:,12,:));


load('/Users/localuser/GMET/results/stn_prcp.mat');
LLE1=LLE;
load('/Users/localuser/GMET/results/stn_prcp12.mat');
LLE2=LLE;
[ind1,ind2]=ismember(LLE2,LLE1,'rows');
ind2(ind2==0)=[];
load('metric_prcp.mat');
metric1=metric4{4};
metric1=metric1(ind2,:,1:5);
KGE1=squeeze(metric1(:,12,:));

load('metric_prcp12.mat');
metric2=metric4{4};
metric2=metric2(ind1,:,:);
KGE2=squeeze(metric2(:,12,:));

nanmean(KGE1)
nanmean(KGE2)


