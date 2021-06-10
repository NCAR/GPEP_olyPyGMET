clc;clear;close all
addpath('~/m_map/');
Outfigure='ens_map_teaserproduct';
shapefile='/Users/localuser/Research/EMDNA/ExampleData/Bow_outline/Bow.shp';
shp=shaperead(shapefile);

% data preparation
% v: 1 pcp; 2 tmean; 3 trange
datafile='ens_map_2015_teaserproduct.mat';
if exist(datafile,'file')
    load(datafile)
else
    file='/Users/localuser/Research/EMDNA/ExampleData/EMDNA_example_2015.nc';
    data=cell(4,3);
    var={'prcp','tmean','trange'};
    day=180; %100
    ensnum=[1,10,20];
    for i=1:3
        di=ncread(file,var{i});
        di=squeeze(di(:,:,day,:));
        data{1,i}=di(:,:,1);
        data{2,i}=di(:,:,10);
        data{3,i}=di(:,:,20);
        data{4,i}=nanstd(di,[],3);
    end
  
    lat=ncread(file,'lat');
    lon=ncread(file,'lon');
    
    save(datafile,'data','lat','lon');
end

% plot
% basic settings
title1={'Precipitation','Mean temperature','Temperature range'};
title2={'Member 1', 'Member 10', 'Member 20','Standard deviation'};
unit={'mm/d','\circC','\circC'};


clims=cell(4,3);
clims(1:3,1)={[0, 12]};
clims(1:3,2)={[0, 20]};
clims(1:3,3)={[0, 20]};
clims(4,1)={[0, 8]};
clims(4,2)={[1, 2]};
clims(4,3)={[4, 6]};

fsize=7;
figure('color','w','unit','centimeters','position',[15,20,13,18]);
haa=tight_subplot(4,3, [.03 .03],[.13 .03],[.06 .02]);
flag=1;
for i=1:4
    for v=1:3
        % DEM
        axes(haa(flag));
        m_proj('Miller','lon',lon([1,end]),'lat',lat([end,1]));
        hold on
        m_pcolor(lon,lat,data{i,v});
        
        for j=1:length(shp)
            ll1=shp(j).X; ll2=shp(j).Y; % delete Hawaii
            ind=(ll1<-150)&(ll2<30);
            ll1(ind)=nan; ll2(ind)=nan;
            m_line(ll1,ll2,'color','k','linewidth',2);
        end
        
        hold off
        shading flat
        
        m_grid('linewi',1,'tickdir','in','fontsize',fsize,'linestyle','none');
        if i==1
            title(title1{v},'fontsize',fsize+2);
        end
        if v==1
            yh=ylabel(title2{i},'fontweight','bold','fontsize',fsize+2);
            yh.Position(1)=yh.Position(1)-0.003;
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
            h.Position=h.Position+[0. -0.06 0. -0.007];
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
