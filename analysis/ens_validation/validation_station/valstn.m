clc;clear;close all
file='/Users/localuser/Research/EMDNA/StnValidation.nc4';
prcp=ncread(file,'prcp');
tmean=ncread(file,'tmean');
trange=ncread(file,'trange');
LLE=ncread(file,'LLE');
gnum=size(LLE,1);

samnum1=zeros(gnum,3);
samnum1(:,1)=sum(~isnan(prcp),1);
samnum1(:,2)=sum(~isnan(tmean),1);
samnum1(:,3)=sum(~isnan(trange),1);

samnum2(:,1)=sum(~isnan(prcp),2);
samnum2(:,2)=sum(~isnan(tmean),2);
samnum2(:,3)=sum(~isnan(trange),2);

save('ValstnInfo.mat','LLE','samnum1','samnum2');

% ind=samnum(:,1)>200;
% scatter(LLE(ind,2),LLE(ind,1));
