clc;clear;close all
% path='/datastore/GLOBALWATER/CommonData/EMDNA_new/EMDNA_ens3/2016';
path='~/scratch/2016';


for i=1:100
    fprintf('%d\n',i);
    file=[path,'/EMDNA_201601.',num2str(i,'%03d'),'.nc4'];
    pi=ncread(file,'pcp');
    pi(pi<0)=nan;
    pi=nanmean(pi,3);
    prcp(:,:,i)=pi;
end
prcp=single(prcp);
save('EMDNA_201601_prcp.mat','prcp');
