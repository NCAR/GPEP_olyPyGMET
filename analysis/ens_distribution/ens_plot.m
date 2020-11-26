clc;clear;close all
addpath('~/m_map/');
Outfigure='ens_map';
shapefile='/Users/localuser/Google Drive/Datasets/Shapefiles/North America/From MERIT DEM/North_America.shp';
shp=shaperead(shapefile);

% data preparation
% v: 1 pcp; 2 tmean; 3 trange
datafile='ens_map_201606.mat';
if exist(datafile,'file')
    load(datafile)
else
    path='/Users/localuser/Research/EMDNA/ens_map';
    data=cell(4,3);
    year=2016;
    month=6;
    
    file=[path,'/oi_ens_mean_',num2str(year*100+month),'.mat'];
    load(file)
    ens_data(ens_data<-100)=nan;
    for v=1:3
        data{1,v}=flipud(oi_data(:,:,v));
        data{2,v}=flipud(squeeze(ens_data(:,:,v,1))); % ens_1
        data{3,v}=flipud(squeeze(ens_data(:,:,v,5))); % ens_100
        data{4,v}=flipud(squeeze(ens_std(:,:,v))); % std
        data{4,v}(isnan(data{1,v}))=nan;
    end
    
    load('../../DEM/NA_DEM_010deg_trim.mat','InfoLow');
    lat=(InfoLow.yrange(2)-InfoLow.Ysize/2):-InfoLow.Ysize:(InfoLow.yrange(1)+InfoLow.Ysize/2);
    lon=(InfoLow.xrange(1)+InfoLow.Xsize/2):InfoLow.Xsize:(InfoLow.xrange(2)-InfoLow.Xsize/2);
    
    save(datafile,'data','lat','lon');
end

% plot
% basic settings
title1={'Precipitation','Mean temperature','Temperature range'};
title2={'OI input','Member 1', 'Member 100','Standard deviation'};
unit={'mm/d','\circC','\circC'};


clims=cell(4,3);
clims(1:3,1)={[0, 8]};
clims(1:3,2)={[0, 32]};
clims(1:3,3)={[0, 20]};
clims(4,1)={[0, 2]};
clims(4,2)={[0, 0.8]};
clims(4,3)={[0, 0.8]};

fsize=5;
figure('color','w','unit','centimeters','position',[15,20,15,18]);
haa=tight_subplot(4,3, [.0 .02],[.1 .03],[.04 .02]);
flag=1;
for i=1:4
    for v=1:3
        % DEM
        axes(haa(flag));
        m_proj('Miller','lon',[-180 -50],'lat',[5 85]);
        hold on
        for j=1:length(shp)
            ll1=shp(j).X; ll2=shp(j).Y; % delete Hawaii
            ind=(ll1<-150)&(ll2<30);
            ll1(ind)=nan; ll2(ind)=nan;
            m_line(ll1,ll2,'color',[0.6,0.6,0.6]);
        end
        m_pcolor(lon,lat,data{i,v});
        hold off
        shading flat
        
        m_grid('linewi',1,'tickdir','in','fontsize',fsize,'xticklabel','','yticklabel','','color','w','linestyle','none');
        if i==1
            title(title1{v},'fontsize',fsize+2);
        end
        if v==1
            ylabel(title2{i},'fontweight','bold','fontsize',fsize+2);
        end
        
        if i<=3
%             colormap(gca,(m_colmap('blue',60)));
            colormap(gca,'winter');
        else
            colormap(gca,flipud(m_colmap('blue',60)));
        end
  
        caxis(clims{i,v});
        
        if i==4
            po=get(haa(flag),'Position');
            po(2)=po(2)-0.05;
            set(haa(flag),'Position',po);
        end
        if i>=3
            h=colorbar('south','fontsize',fsize);
            set(get(h,'title'),'String',unit{v},'fontsize',fsize);
            h.Position=h.Position+[0. -0.04 0. -0.007];
            h.AxisLocation='out';
            set(h,'ticks',linspace(clims{i,v}(1),clims{i,v}(2),5));
        end
        
        
        flag=flag+1;
    end
end

fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(gcf,'-dpng',[Outfigure,'.png'],'-r600');
