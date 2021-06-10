clc;clear;close all
Outfigure='prcp_metric_map_nrmse';

shapefile='/Users/localuser/Google Drive/Datasets/Shapefiles/North America/From MERIT DEM/North_America.shp';
shp=shaperead(shapefile);

% data preparation
datafile='prcp_plotdata_nrmse.mat';
if exist(datafile,'file')
    load(datafile,'latg','long','metmerge_grid','metcorr_grid','metdown_grid','metraw_grid');
else
    load('prcp_evaluation.mat','met_merge','met_corr','met_raw','met_down','lle');
    load('../../DEM/NA_DEM_010deg_trim.mat','DEM','InfoLow');
    
    load('mean_value.mat','mean_stn');
    met_merge(:,2)=met_merge(:,2)./mean_stn(:,1);
    for i=1:3
        met_corr(i,:,2)=squeeze(met_corr(i,:,2))'./mean_stn(:,1);
        met_raw(i,:,2)=squeeze(met_raw(i,:,2))'./mean_stn(:,1);
        met_down(i,:,2)=squeeze(met_down(i,:,2))'./mean_stn(:,1);
    end

    
    % define the grids
    cellsize=0.5;
    nrows=floor(80/cellsize);
    ncols=floor(130/cellsize);
    latg=(85-cellsize/2):-cellsize:(5+cellsize/2);
    long=(-180+cellsize/2):cellsize:(-50-cellsize/2);
    row=floor((85-lle(:,1))/cellsize)+1;
    col=floor((lle(:,2)+180)/cellsize)+1;
    indrc=sub2ind([nrows,ncols],row,col);
    indrcu=unique(indrc);
    
    metraw_grid=nan*zeros(3,nrows,ncols,15);
    metdown_grid=nan*zeros(3,nrows,ncols,15);
    metcorr_grid=nan*zeros(3,nrows,ncols,15);
    metmerge_grid=nan*zeros(nrows,ncols,15);
    for i=1:3
        for j=1:15
            m1=nan*zeros(nrows,ncols);
            m2=nan*zeros(nrows,ncols);
            m3=nan*zeros(nrows,ncols);
            for g=1:length(indrcu)
                m1(indrcu(g))=nanmedian(met_raw(i,indrc==indrcu(g),j));
                m2(indrcu(g))=nanmedian(met_down(i,indrc==indrcu(g),j));
                m3(indrcu(g))=nanmedian(met_corr(i,indrc==indrcu(g),j));
            end
            metraw_grid(i,:,:,j)=m1;
            metdown_grid(i,:,:,j)=m2;
            metcorr_grid(i,:,:,j)=m3;
        end
    end
    
    for j=1:15
        m1=nan*zeros(nrows,ncols);
        for g=1:length(indrcu)
            m1(indrcu(g))=nanmedian(met_merge(indrc==indrcu(g),j));
        end
        metmerge_grid(:,:,j)=m1;
    end
    save(datafile,'latg','long','metmerge_grid','metcorr_grid','metdown_grid','metraw_grid');
end

dataplot=cell(4,3);
for i=1:3
    dataplot{1,i}=squeeze(metraw_grid(i,:,:,1)); %cc
    dataplot{2,i}=squeeze(metraw_grid(i,:,:,2)); %rmse
    dataplot{3,i}=squeeze(metmerge_grid(:,:,1))- dataplot{1,i}; % merge - raw
    dataplot{4,i}=squeeze(metmerge_grid(:,:,2))- dataplot{2,i}; % merge - raw
end

% plot
% basic settings
clims=cell(4,3);
clims(1,1:3)={[0,1]};
clims(2,1:3)={[0,6]};
clims(3,1:3)={[-0.3,0.3]};
clims(4,1:3)={[-2,2]};
cbins=[6,7,7,7];

fsize=4;
xtitles={'ERA5','MERRA-2','JRA-55'};
ytitles={'CC','NRMSE','CC difference','NRMSE difference'};

figure('color','w','unit','centimeters','position',[15,20,14.2,15]);
haa=tight_subplot(4,3, [0.015 0.015],[.02 .03],[.08 .06]);

flag=1;
for i=1:4
    for j=1:3
        axes(haa(flag));
        m_proj('equidistant','lon',[-180 -50],'lat',[5 85]);
        hold on
        for q=1:length(shp)
            ll1=shp(q).X; ll2=shp(q).Y; % delete Hawaii
            m_line(ll1,ll2,'color',[0.6,0.6,0.6]);
        end
        m_pcolor(long,latg,dataplot{i,j});
        hold off
        shading flat
        if j==1&&i<4
            m_grid('linewi',0.5,'tickdir','in','fontsize',fsize,'xtick',-180:30:-50,'xticklabel','','color',[0.6,0.6,0.6]);
        elseif j==1&&i==4
            m_grid('linewi',0.5,'tickdir','in','fontsize',fsize,'xtick',-180:30:-50,'color',[0.6,0.6,0.6]);
        elseif i==4
            m_grid('linewi',0.5,'tickdir','in','fontsize',fsize,'xtick',-180:30:-50,'yticklabel','','color',[0.6,0.6,0.6]);
        else
            m_grid('linewi',0.5,'tickdir','in','fontsize',fsize,'xtick',-180:30:-50,'xticklabel','','yticklabel','','color',[0.6,0.6,0.6]);
        end
        
        % color
        caxis(clims{i,j});
        if i<=2
            colormap(gca,flipud(m_colmap('water',10)));
        else
           colormap(gca,m_colmap('jet',10)); 
        end
        
        % titles
%         if i==1
%             title(xtitles{j},'fontsize',fsize+4);
%         end
        if j==1
            yh=ylabel(ytitles{i},'fontsize',fsize+4,'fontweight','bold');
            yh.Position=yh.Position+[-0.2 0 0];
        end
        if i<=2
            text(-0.7,1.4,xtitles{j},'fontsize',fsize+3);
        else
            text(-0.7,1.4,['BMA - ',xtitles{j}],'fontsize',fsize+3);
        end
        
        % colorbar
        if j==3
            h=colorbar('east','fontsize',fsize);
            h.Position=h.Position+[0.05 0 -0.01 0];
            h.AxisLocation='out';
            set(h,'Ticks',linspace(clims{i,j}(1),clims{i,j}(2),cbins(i)),'TickLabels',linspace(clims{i,j}(1),clims{i,j}(2),cbins(i)),'fontsize',fsize);
            cbarrow
        end
        
        % nest a bar plot
        po=get(haa(flag),'Position');
        po(1)=po(1)+0.02;
        po(2)=po(2)+0.02;
        po(3)=po(3)*0.35;
        po(4)=po(4)*0.35;
        hn = axes('position',po);
        hold on
        temp=histogram(dataplot{i,j}(:),linspace(clims{i,j}(1),clims{i,j}(2),10),...
            'facecolor',[0.5,0.5,0.5],'edgecolor',[0.8,0.8,0.8]);
%         plot([clims{i,j}(1),clims{i,j}(1)],[0,max(temp.Values)],'-k');
        set(hn,'ylim',[0,max(temp.Values)],'yticklabel','','ycolor',[1,1,1]);
        set(hn,'xlim',clims{i,j}(1:2),'xtick',linspace(clims{i,j}(1),clims{i,j}(2),3),'xticklabel',linspace(clims{i,j}(1),clims{i,j}(2),3),'fontsize',fsize+1)
        plot([clims{i,j}(1)-0.2,clims{i,j}(2)+0.2],[0,0],'k');
        hold off
        
        flag=flag+1;
    end
end
fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(gcf,'-dpng',[Outfigure,'.png'],'-r600');

