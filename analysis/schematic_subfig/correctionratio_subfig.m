clc;clear;close all
file='CHELSA_V12_NA_corratio.mat';
load(file,'corr_ratio');

% distribution map
fsize=8;
figure('color','w','unit','centimeters','position',[15,20,10,4]);
haa=tight_subplot(1,3, [0.0 0.02],[.04 .12],[.02 .02]);

axes(haa(1));
d=corr_ratio(:,:,4);
imagesc(d,'alphadata',~isnan(d));
colormap(winter)
caxis([0,3]);
axis off
title('April','fontweight','normal','fontsize',fsize)
lh=colorbar('location','west','fontsize',fsize-3);
lh.Position=lh.Position+[0.03 0.05 -0.02 -0.5];

axes(haa(2));
d=corr_ratio(:,:,8);
imagesc(d,'alphadata',~isnan(d));
colormap(winter)
caxis([0,3]);
axis off
title('August','fontweight','normal','fontsize',fsize)
lh=colorbar('location','west','fontsize',fsize-3);
lh.Position=lh.Position+[0.03 0.05 -0.02 -0.5];

axes(haa(3));
d=corr_ratio(:,:,12);
imagesc(d,'alphadata',~isnan(d));
colormap(winter)
caxis([0,3]);
axis off

title('December','fontweight','normal','fontsize',fsize)
lh=colorbar('location','west','fontsize',fsize-3);
lh.Position=lh.Position+[0.03 0.05 -0.02 -0.5];

export_fig corr_ratio.png -transparent -m10

% curves
% data=zeros(80,12);
% for i=1:12
%     for j=1:80
%         dij=corr_ratio((j-1)*10+1:j*10,:,i);
%         data(j,i)=nanmedian(dij(:));
%     end
% end