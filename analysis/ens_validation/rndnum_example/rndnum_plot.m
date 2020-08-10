clc;clear;close all
file='/Users/localuser/Research/EMDNA/EMDNA_out/ens_201601.001.nc';

pcp=ncread(file,'pcp');
mask=pcp(:,:,1); clear pcp

day=20;
pcp_rndnum=ncread(file,'pcp_rndnum');
pcp_rndnum=pcp_rndnum(:,:,day);
pcp_rndnum(mask<-100)=nan;
pcp_cprob=ncread(file,'pcp_cprob');
pcp_cprob=pcp_cprob(:,:,day);
pcp_cprob(mask<-100)=nan;
tmean_rndnum=ncread(file,'tmean_rndnum');
tmean_rndnum=tmean_rndnum(:,:,day);
tmean_rndnum(mask<-100)=nan;
trange_rndnum=ncread(file,'trange_rndnum');
trange_rndnum=trange_rndnum(:,:,day);
trange_rndnum(mask<-100)=nan;


save('rndnum.mat','pcp_rndnum','pcp_cprob','tmean_rndnum','trange_rndnum');