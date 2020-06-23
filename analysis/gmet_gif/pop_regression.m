clc;clear;close all

file1='/Users/localuser/GMET/test0622/reg_197901.nc';

pcp=ncread(file1,'pcp');
pop=ncread(file1,'pop');
pcp_err=ncread(file1,'pcp_error');
pcp=flipud(permute(pcp,[2,1,3]));
pop=flipud(permute(pop,[2,1,3]));
pcp_err=flipud(permute(pcp_err,[2,1,3]));
pcp_err(pcp_err<0)=nan;

day=1;
subplot(1,3,1)
imagesc(pcp(:,:,day),'alphadata',~isnan(pcp(:,:,day)));
colorbar()
caxis([-4,4])
colormap(jet)
title('pcp')
% xlim([700,1300]);
% ylim([200,600]);


subplot(1,3,2)
imagesc(pop(:,:,day),'alphadata',~isnan(pop(:,:,day)));
colorbar()
caxis([0,1])
colormap(jet)
title('pop')
% xlim([700,1300]);
% ylim([200,600]);

subplot(1,3,3)
imagesc(pcp_err(:,:,day),'alphadata',~isnan(pcp_err(:,:,day)));
colorbar()
caxis([0,10])
colormap(jet)
title('pcp error')
% xlim([700,1300]);
% ylim([200,600]);