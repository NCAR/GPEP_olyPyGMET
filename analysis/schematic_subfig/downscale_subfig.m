clc;clear;close all
addpath('/Users/localuser/Github/tools/export_fig');

% load station data
% file='/Users/localuser/Research/EMDNA/MERRA2_downto_stn_GWR.mat';
% load(file,'tmean_readown');
% tmean_gwr=tmean_readown; clear tmean_readown
%
% file='/Users/localuser/Research/EMDNA/MERRA2_downto_stn_nearest.mat';
% load(file,'tmean_readown');
% tmean_near=tmean_readown; clear tmean_readown
%
% file='/Users/localuser/Research/EMDNA/stndata_aftercheck.mat';
% load(file,'tmean_stn','stninfo');
%
% % find suitable station points
% mae(:,1)=abs(nanmean(tmean_gwr,2)-nanmean(tmean_stn,2));
% mae(:,2)=abs(nanmean(tmean_near,2)-nanmean(tmean_stn,2));
% diff=mae(:,2)-mae(:,1);
%
% scatter(stninfo(:,3),stninfo(:,2),20,diff,'filled');
% colormap('jet')
% caxis([-1,1]);
% xlim([-120,-110]);
% ylim([40,50])



Outfigure='downscale_201808';
datafile='downscale_data.mat';

if exist(datafile)
    load(datafile)
else
    % load grid data
    file_grid='/Users/localuser/Research/EMDNA/basicinfo/gridinfo_whole.nc';
    elev=ncread(file_grid,'elev');
    elev=flipud(elev');
    
    load('/Users/localuser/Research/EMDNA/MERRA2_rawds/MERRA2_tmax_2018.mat','data')
    tmax=data(:,:,213:243); % august
    load('/Users/localuser/Research/EMDNA/MERRA2_rawds/MERRA2_tmin_2018.mat','data')
    tmin=data(:,:,213:243); % august
    tmean_raw=(tmin+tmax)/2;
    tmean_raw=nanmean(tmean_raw,3);
    
    load('/Users/localuser/Research/EMDNA/MERRA2_rawds/MERRA2_ds_tmean_201808.mat','data')
    tmean_ds=data;
    tmean_ds=nanmean(tmean_ds,3);
    save(datafile,'elev','tmean_raw','tmean_ds');
end
% target region
latr=[40,50];
lonr=[-120,-110];

xlim1=[600,700];
ylim1=[350,450];

xlim2=[96,112];
ylim2=[80,100];


fsize=8;
figure('color','w','unit','centimeters','position',[15,20,10,4]);
haa=tight_subplot(1,3, [0.0 0.02],[.02 .02],[.02 .02]);

axes(haa(1));
imagesc(elev,'alphadata',~isnan(elev));
colormap(jet)
xlim(xlim1);
ylim(ylim1);
axis square
axis off
title('Elevation','fontweight','normal','fontsize',fsize)


axes(haa(2));
imagesc(tmean_raw,'alphadata',~isnan(tmean_raw));
colormap(jet)
xlim(xlim2);
ylim(ylim2);
axis square
axis off
title('Raw MERRA-2','fontweight','normal','fontsize',fsize)

axes(haa(3));
imagesc(tmean_ds,'alphadata',~isnan(tmean_ds));
colormap(jet)
xlim(xlim1);
ylim(ylim1);
axis square
axis off
title('Regridded MERRA-2','fontweight','normal','fontsize',fsize)


% fig = gcf;
% fig.PaperPositionMode='auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(gcf,'-dpng',[Outfigure,'.png'],'-r600');
export_fig downscale_201808.png -transparent -m20