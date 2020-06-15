clc;clear;close all
% addpath('~/m_map')
var='tmean';
Outfigure=['metric_',var];

Infile='../../OIevaluation.mat';
shapefile='~/Google Drive/Datasets/Shapefiles/North America/From MERIT DEM/North_America.shp';
shp=shaperead(shapefile);

% data preparation, resample point data to grid data
datafile=['inputdata_',var,'.mat'];
if exist(datafile,'file')
    load(datafile);
else
    load(Infile,'stn_lle',['met_',var]);
    LLE=stn_lle;
    command=['dv=met_',var,';'];
    eval(command);
    % define the grids
    cellsize=1;
    nrows=floor(80/cellsize);
    ncols=floor(130/cellsize);
    latg=(85-cellsize/2):-cellsize:(5+cellsize/2);
    long=(-180+cellsize/2):cellsize:(-50-cellsize/2);
    row=floor((85-LLE(:,1))/cellsize)+1;
    col=floor((LLE(:,2)+180)/cellsize)+1;
    indrc=sub2ind([nrows,ncols],row,col);
    indrcu=unique(indrc);
    
    met_grid=cell(4,3);
    met_grid(:)={nan*zeros(nrows,ncols)};
    met_all=cell(4,3);
    for i=1:4
        for j=1:3
            dataij=squeeze(dv(j,:,i));
            met_all{i,j}=dataij;
            for g=1:length(indrcu)
                dataijg=dataij(indrc==indrcu(g));
                dataijg(isnan(dataijg))=[];
                if ~isempty(dataijg)
                    met_grid{i,j}(indrcu(g))=median(dataijg);
                end
            end
        end
    end
    save(datafile,'met_grid','met_all','long','latg');
end

met_grid=met_grid([1,2,4],:); % CC, ME, RMSE
met_all=met_all([1,2,4],:);

% plot
% basic settings
if strcmp(var,'tmean')
clims=cell(3,3);
clims(1,1:3)={[0.6,1]};
clims(2,1:3)={[-1,1]};
clims(3,1:3)={[0,3]};
end
if strcmp(var,'trange')
clims=cell(3,3);
clims(1,1:3)={[0,1]};
clims(2,1:3)={[-2,2]};
clims(3,1:3)={[0,6]};
end
if strcmp(var,'prcp')
clims=cell(3,3);
clims(1,1:3)={[0,1]};
clims(2,1:3)={[-0.5,0.5]};
clims(3,1:3)={[0,8]};
end

fsize=7;
xtitles={'Regression','Reanalysis','OI'};
ytitles={'CC','ME','RMSE'};

figure('color','w','unit','centimeters','position',[15,20,21,17.5]);
haa=tight_subplot(3,3, [0.03 0.07],[.02 .03],[.07 .07]);

flag=1;
for i=1:3
    for j=1:3
        axes(haa(flag));
        
        m_proj('equidistant','lon',[-180 -50],'lat',[5 85]);
        hold on
        for q=1:length(shp)
            ll1=shp(q).X; ll2=shp(q).Y; % delete Hawaii
            m_line(ll1,ll2,'color','k');
        end
        m_pcolor(long,latg,met_grid{i,j});
        hold off
        shading flat
        m_grid('linewi',1,'tickdir','out','fontsize',fsize);
        
        % color
        caxis(clims{i,j});
%         colormap(gca,flipud(m_colmap('water',8)));
        colormap(gca,'jet');
        
        % titles
        if i==1
            title(xtitles{j},'fontsize',fsize+4);
        end
        if j==1
            yh=ylabel(ytitles{i},'fontsize',fsize+4,'fontweight','bold');
            yh.Position=yh.Position+[-0.2 0 0];
        end        
        % colorbar 
        if j==3
            h=colorbar('east','fontsize',fsize);
            h.Position=h.Position+[0.05 0 -0.01 0];
            h.AxisLocation='out';
            set(h,'Ticks',linspace(clims{i,j}(1),clims{i,j}(2),6),'TickLabels',linspace(clims{i,j}(1),clims{i,j}(2),6),'fontsize',fsize);
        end
        
        % nest a bar plot
        po=get(haa(flag),'Position');
        po(1)=po(1)+0.03;
        po(2)=po(2)+0.05;
        po(3)=po(3)*0.3;
        po(4)=po(4)*0.3;
        hn = axes('position',po);
        hold on
        temp=histogram(met_all{i,j},linspace(clims{i,j}(1),clims{i,j}(2),11),'facecolor',[0.8,0.8,0.8],'edgecolor',[0.8,0.8,0.8]);
        set(hn,'yticklabel',[],'ycolor',[1,1,1]);
        set(hn,'xtick',linspace(clims{i,j}(1),clims{i,j}(2),3),'xticklabel',linspace(clims{i,j}(1),clims{i,j}(2),3),'fontsize',fsize-1)

        flag=flag+1;
    end
end
fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(gcf,'-dpng',[Outfigure,'.png'],'-r600');



