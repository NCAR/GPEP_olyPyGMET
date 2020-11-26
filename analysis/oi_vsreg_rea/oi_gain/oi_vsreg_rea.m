% rmse is normalized using mean value for prcp and trange
clc;clear;close all
addpath('~/m_map');
mode='rea'; % reg/rea

if strcmp(mode,'rea')
    Outfigure='oi_vs_rea';
elseif strcmp(mode,'reg')
    Outfigure='oi_vs_reg';
end

shapefile='/Users/localuser/Google Drive/Datasets/Shapefiles/North America/From MERIT DEM/North_America.shp';
shp=shaperead(shapefile);


% data preparation
datafile='oi_vsreg_rea.mat';
if exist(datafile,'file')
    load(datafile);
else
    load('mean_value.mat','mean_stn');
    % calculate mean precipitation and temperature range
    load('oi_evaluation.mat')
    met_prcp_oi(:,2)=met_prcp_oi(:,2)./mean_stn(:,1);
    met_trange_oi(:,2)=met_trange_oi(:,2)./mean_stn(:,3);
    
    load('reg_evaluation.mat')
    met_prcp_reg(:,2)=met_prcp_reg(:,2)./mean_stn(:,1);
    met_trange_reg(:,2)=met_trange_reg(:,2)./mean_stn(:,3);
   
    oi_vs_reg=cell(3,1);
    oi_vs_reg{1}=met_prcp_oi-met_prcp_reg;
    oi_vs_reg{2}=met_tmean_oi-met_tmean_reg;
    oi_vs_reg{3}=met_trange_oi-met_trange_reg;
    
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
    
    oi_vs_reg_grid=nan*zeros(3,nrows,ncols,15); % 3 variables
    for i=1:3
        for j=1:15
            m1=nan*zeros(nrows,ncols);
            for g=1:length(indrcu)
                m1(indrcu(g))=nanmedian(oi_vs_reg{i}(indrc==indrcu(g),j));
            end
            oi_vs_reg_grid(i,:,:,j)=m1;
        end
    end
    
    
    file={'../../rea_corrmerge/prcp_evaluation.mat',...
        '../../rea_corrmerge/tmean_evaluation.mat',...
        '../../rea_corrmerge/trange_evaluation.mat'};
    
    oi_vs_rea_grid=nan*zeros(3,nrows,ncols,15); % 3 variables
    oimet=cell(3,1);
    oimet{1}=met_prcp_oi;
    oimet{2}=met_tmean_oi;
    oimet{3}=met_trange_oi;
    for i=1:3
        load(file{i},'met_merge');
        if i~=2
            met_merge(:,2)=met_merge(:,2)./mean_stn(:,i);
        end
        latdiff=oimet{i}-met_merge;
        for j=1:15
            m1=nan*zeros(nrows,ncols);
            for g=1:length(indrcu)
                m1(indrcu(g))=nanmedian(latdiff(indrc==indrcu(g),j));
            end
            oi_vs_rea_grid(i,:,:,j)=m1;
        end
    end
    
    save(datafile,'oi_vs_reg_grid','oi_vs_rea_grid','latg','long');
end

if strcmp(mode,'rea')
    datause=oi_vs_rea_grid;
elseif strcmp(mode,'reg')
    datause=oi_vs_reg_grid;
end
latdiff=nan*zeros(3,2,160);
londiff=nan*zeros(3,2,260);

for i=1:3
    for j=1:2
        zz=squeeze(datause(i,:,:,j));
        num=sum(~isnan(zz),2);
        temp=nanmedian(zz,2);
        temp(num<5)=nan;
        latdiff(i,j,:)=temp;
        
        zz=squeeze(datause(i,:,:,j));
        num=sum(~isnan(zz),1);
        temp=nanmedian(zz,1);
        temp(num<10)=nan;
        londiff(i,j,:)=temp;
    end
end

% plot figures
if strcmp(mode,'rea')
    clims(1,1)={[-0.3,0.3]};
    clims(1,2)={[-2,2]};
    clims(2,1)={[-0.1,0.1]};
    clims(2,2)={[-1,1]};
    clims(3,1)={[-0.3,0.3]};
    clims(3,2)={[-0.2,0.2]};
    cbins=[5,5,5,5];
elseif strcmp(mode,'reg')
    clims=cell(4,3);
    clims(1,1)={[-0.2,0.2]};
    clims(1,2)={[-1,1]};
    clims(2,1)={[-0.1,0.1]};
    clims(2,2)={[-1,1]};
    clims(3,1)={[-0.2,0.2]};
    clims(3,2)={[-0.2,0.2]};
    cbins=[5,5,5,5];
end


fsize=4;
xtitles={'CC','RMSE'};
ytitles={'Precipitation','Mean temperature','Temperature range'};
titles={'(a) Precipitation: CC','(b)Precipitation: NRMSE', ...
    '(c) Tmean: CC','(d) Tmean: RMSE',...
    '(e) Trange: CC','(f) Trange: NRMSE'};

figure('color','w','unit','centimeters','position',[15,20,15,15]);
haa=tight_subplot(3,2, [0.05 0.17],[.02 .01],[.1 .06]);

flag=1;
for i=1:3
    for j=1:2
        dij=squeeze(datause(i,:,:,j));
        
        axes(haa(flag));
        m_proj('equidistant','lon',[-180 -50],'lat',[5 85]);
        hold on
        for q=1:length(shp)
            ll1=shp(q).X; ll2=shp(q).Y; % delete Hawaii
            m_line(ll1,ll2,'color',[0.6,0.6,0.6]);
        end
        m_pcolor(long,latg,dij);
        hold off
        shading flat
        m_grid('linewi',0.5,'tickdir','in','fontsize',fsize,'xtick',-180:30:-50,'xticklabel','','yticklabel','','color',[0.6,0.6,0.6]);
        
        % color
        caxis(clims{i,j});
        colormap(gca,m_colmap('jet',64));
        
        % titles
        text(-0.7,1.4,titles{flag},'fontsize',fsize+3);
        
        % colorbar
        h=colorbar('east','fontsize',fsize);
        h.Position=h.Position+[0.05 0 -0.01 0];
        h.AxisLocation='out';
        set(h,'Ticks',linspace(clims{i,j}(1),clims{i,j}(2),cbins(i)),'TickLabels',linspace(clims{i,j}(1),clims{i,j}(2),cbins(i)),'fontsize',fsize);
        cbarrow
        
        if j==2 && i==2
            th=title(h,'\circC');
            th.Position(2)=th.Position(2)*1.07;
        end
        
        
        % nest a bar plot
        po=get(haa(flag),'Position');
        po(1)=po(1)+0.02;
        po(2)=po(2)+0.02;
        po(3)=po(3)*0.35;
        po(4)=po(4)*0.35;
        hn = axes('position',po);
        hold on
        temp=histogram(dij(:),linspace(clims{i,j}(1),clims{i,j}(2),20),...
            'facecolor',[0.5,0.5,0.5],'edgecolor',[0.8,0.8,0.8]);
        %         plot([clims{i,j}(1),clims{i,j}(1)],[0,max(temp.Values)],'-k');
        plot([clims{i,j}(1)-0.2,clims{i,j}(2)+0.2],[0,0],'k');
        hold off
        set(hn,'ylim',[0,max(temp.Values)],'yticklabel','','ycolor',[1,1,1]);
        set(hn,'xlim',clims{i,j}(1:2),'xtick',linspace(clims{i,j}(1),clims{i,j}(2),3),'xticklabel',linspace(clims{i,j}(1),clims{i,j}(2),3),'fontsize',fsize+1)
        
        
        % nest a latitude curve plot
        po=get(haa(flag),'Position');
        po(1)=po(1)-0.06;
        po(2)=po(2)+0.0;
        po(3)=po(3)*0.2;
        po(4)=po(4)*1;
        hn = axes('position',po);
        dij=flipud(squeeze(latdiff(i,j,:)));
        temp=plot(dij,1:160,'k');
        set(hn,'fontsize',fsize+1)
        ylabel('Latitude');
        
        set(hn,'xColor',[0.3,0.3,0.3],'yColor',[0.3,0.3,0.3]);
        set(hn,'ylim',[0,160],'ytick',0:20:160,'yticklabel',5:10:85);
        flag=flag+1;
    end
end
fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(gcf,'-dpng',[Outfigure,'.png'],'-r600');


