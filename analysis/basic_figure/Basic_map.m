addpath('/Users/localuser/m_map');
clc;clear; close all
% DEM and the distribution of gauges
Outfigure='Basic_map';
InfileGauge='/Users/localuser/Research/EMDNA/stndata_aftercheck.mat';
shapefile='/Users/localuser/Google Drive/Datasets/Shapefiles/North America/From MERIT DEM/North_America.shp';
shp=shaperead(shapefile);
%% data preparation
datafile='InputData.mat';
if exist(datafile,'file')
    load(datafile,'DEM','lat','lon','latg','long','dist','GaugeDensity');
else
    load(InfileGauge);
    load('../../DEM/NA_DEM_010deg_trim.mat','DEM','InfoLow');
    DEM=DEM/1000;
    lat=(InfoLow.yrange(2)-InfoLow.Ysize/2):-InfoLow.Ysize:(InfoLow.yrange(1)+InfoLow.Ysize/2);
    lon=(InfoLow.xrange(1)+InfoLow.Xsize/2):InfoLow.Xsize:(InfoLow.xrange(2)-InfoLow.Xsize/2);
    
    % read gauge data
    LLEall=stninfo(:,2:4);
    LLE=cell(2,1);
    LLE{1}=LLEall(~isnan(prcp_stn(:,1)),:);
    LLE{2}=LLEall(~isnan(tmean_stn(:,1)),:);
    
    % calcualte gauge density
    cellsize=0.5;
    latg=(InfoLow.yrange(2)-cellsize/2):-cellsize:(InfoLow.yrange(1)+cellsize/2);
    long=(InfoLow.xrange(1)+cellsize/2):cellsize:(InfoLow.xrange(2)-cellsize/2);
    
    nrows=floor((InfoLow.yrange(2)-InfoLow.yrange(1))/cellsize);
    ncols=floor((InfoLow.xrange(2)-InfoLow.xrange(1))/cellsize);
    GaugeDensity=cell(2,1);
    GaugeDensity(:)={nan*zeros(nrows,ncols)};
    for i=1:2
        row=floor((InfoLow.yrange(2)-LLE{i}(:,1))/cellsize)+1;
        col=floor((LLE{i}(:,2)-InfoLow.xrange(1))/cellsize)+1;
        indrc=sub2ind([nrows,ncols],row,col);
        indrcu=unique(indrc);
        for j=1:length(indrcu)
            GaugeDensity{i}(indrcu(j))=sum(indrc==indrcu(j));
        end
    end
    
    % calculate the distance to find a certain number of stations
    dist=nan*zeros(800,1300,4,2);
    for v=1:2
        for i=1:800
            for j=1:1300
                if isnan(DEM(i,j))
                    continue
                end
                distij=lldistkm(lat(i),lon(j),LLE{v}(:,1),LLE{v}(:,2));
                distij=sort(distij);
                dist(i,j,1,v)=distij(1);
                dist(i,j,2,v)=distij(10);
                dist(i,j,3,v)=distij(20);
                dist(i,j,4,v)=distij(30);
            end
        end
    end
    
    save(datafile,'DEM','lat','lon','latg','long','dist','GaugeDensity','LLE');
end

dataplot{1,1}=dist(:,:,1,1);
dataplot{1,2}=dist(:,:,3,1);
dataplot{1,3}=dist(:,:,4,1);
dataplot{2,1}=dist(:,:,1,2);
dataplot{2,2}=dist(:,:,3,2);
dataplot{2,3}=dist(:,:,4,2);
latplot{1}=lat; latplot{2}=lat; latplot{3}=lat;
lonplot{1}=lon; lonplot{2}=lon; lonplot{3}=lon;


%% plot
% basic settings
titles={'(a)','(b)','(c)'; '(d)','(e)','(f)'};
colortitles={'km', 'km', 'km'};
clims=[0, 1000; 0, 1000; 0, 1000];
fsize=5;

figure('color','w','unit','centimeters','position',[15,20,18,12]);
haa=tight_subplot(2,3, [.05 .05],[.15 .03],[.04 .02]);
flag=1;
for v=1:2
    for i=1:3
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
        m_pcolor(lonplot{i},latplot{i},dataplot{v,i});
        hold off
        shading flat
        
        m_grid('linewi',1,'tickdir','out','fontsize',fsize);
        text(-0.85,1.85,titles{v,i},'FontSize',fsize+4);
        
        load mycolor
        colormap(gca,mycolor)
%         colormap(gca,flipud(m_colmap('gland',60)));
        caxis(clims(i,:));
%         set(gca,'ColorScale','log')
        if v==2 && i==3
            h=colorbar('south','fontsize',fsize);
            set(get(h,'title'),'String','Distance (km)','fontsize',fsize);
            h.Position=h.Position+[-0.6 -0.12 0.53 0.0];
            h.AxisLocation='out'; 
            cbarrow
        end
        flag=flag+1;
    end
end

fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(gcf,'-dpng',[Outfigure,'.png'],'-r600');
