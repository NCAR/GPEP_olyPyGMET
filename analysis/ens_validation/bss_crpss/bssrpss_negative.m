% distribution of negative bss, rpss
clc;clear;close all
Outfigure='negative_latlon';
shapefile='/Users/localuser/Google Drive/Datasets/Shapefiles/North America/From MERIT DEM/North_America.shp';
shp=shaperead(shapefile);


datafile='negative_lle.mat';
if exist(datafile,'file')
    load(datafile);
else
    path='/Users/localuser/Research/EMDNA/EMDNA_evaluate/bss_rpss';
    year=1979:2018;
    bss_year=nan*zeros(40,6);
    rpss_year=nan*zeros(40,2);
    ll_prcp1=[];
    ll_prcp2=[];
    ll_tmean=[];
    ll_trange=[];
    for i=1:40
        filei=[path,'/bss_rpss_prcp_',num2str(year(i)),'.mat'];
        load(filei,'bss','LLE');
        ind=bss(:,1)<0;
        ll_prcp1=[ll_prcp1;LLE(ind,1:2)];
        ind=bss(:,5)<-1;
        ll_prcp2=[ll_prcp2;LLE(ind,1:2)];
        
        filei=[path,'/bss_rpss_tmean_',num2str(year(i)),'.mat'];
        load(filei,'rpss','LLE');
        ind=rpss<0;
        ll_tmean=[ll_tmean;LLE(ind,1:2)];
        
        filei=[path,'/bss_rpss_trange_',num2str(year(i)),'.mat'];
        load(filei,'rpss','LLE');
        ind=rpss<0;
        ll_trange=[ll_trange;LLE(ind,1:2)];
    end
    save(datafile,'ll_prcp1','ll_prcp2','ll_tmean','ll_trange');
end

dataplot=cell(4,1);
dataplot{1}=ll_prcp1;
dataplot{2}=ll_prcp2;
dataplot{3}=ll_tmean;
dataplot{4}=ll_trange;

% basic settings
titles={'(a)','(b)','(c)','(d)'};
fsize=5;

figure('color','w','unit','centimeters','position',[15,20,18,16]);
haa=tight_subplot(2,2, [.05 .05],[.03 .03],[.04 .02]);
flag=1;

for i=1:4
    % DEM
    axes(haa(flag));
    m_proj('Miller','lon',[-180 -50],'lat',[5 85]);
    hold on
    for j=1:length(shp)
        ll1=shp(j).X; ll2=shp(j).Y; % delete Hawaii
        ind=(ll1<-150)&(ll2<30);
        ll1(ind)=nan; ll2(ind)=nan;
        m_line(ll1,ll2,'color','k');
    end
    m_scatter(dataplot{i}(:,2),dataplot{i}(:,1),'.');
    hold off
    shading flat
    
    m_grid('linewi',1,'tickdir','out','fontsize',fsize);
    title(titles{i},'FontSize',fsize+4);

    flag=flag+1;
end


% fig = gcf;
% fig.PaperPositionMode='auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(gcf,'-dpng',[Outfigure,'.png'],'-r600');
