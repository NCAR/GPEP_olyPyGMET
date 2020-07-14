clc;clear;close all
Outfigure='pop_map';

shapefile='/Users/localuser/Google Drive/Datasets/Shapefiles/North America/From MERIT DEM/North_America.shp';
shp=shaperead(shapefile);

datafile='pop_evaluation.mat';
load(datafile);

data=cell(2,2);
data{1,1}=bscond_grid(:,:,1); % reg
data{1,2}=bscond_grid(:,:,2); % bma
data{2,1}=bscond_grid(:,:,3)-bscond_grid(:,:,1); % oi - reg
data{2,2}=bscond_grid(:,:,3)-bscond_grid(:,:,2); % oi - bma
databox=permute(bscond_month,[1,3,2]);

% plot
% basic settings
clims=cell(2,1);
clims{1}=[0,0.4];
clims{2}=[-0.04,0.04];
cbins=[5,5];

fsize=6;
titles={'(a) Regression','(b) BMA','(c) OI - Regression', '(d) OI - BMA'};

figure('color','w','unit','centimeters','position',[15,20,12.5,15]);
haa=tight_subplot(3,2, [0.04 0.04],[.05 .01],[.03 .08]);

flag=1;
for i=1:2
    for j=1:2
        axes(haa(flag));
        m_proj('equidistant','lon',[-180 -50],'lat',[5 85]);
        hold on
        for q=1:length(shp)
            ll1=shp(q).X; ll2=shp(q).Y; % delete Hawaii
            m_line(ll1,ll2,'color',[0.6,0.6,0.6]);
        end
        m_pcolor(long,latg,data{i,j});
        hold off
        shading flat
        m_grid('linewi',0.5,'tickdir','in','fontsize',fsize,'xtick',-180:30:-50);
        
        % color
        caxis(clims{i});
        if i==1
            colormap(gca,flipud(m_colmap('water',64)));
        elseif i==2
            colormap(gca,m_colmap('jet',64));
        end
        
        % titles
        text(-0.7,1.4,titles{flag},'fontsize',fsize+2);
        
        % colorbar
        if j==2
            h=colorbar('east','fontsize',fsize);
            h.Position=h.Position+[0.07 0 -0.01 0];
            h.AxisLocation='out';
            set(h,'Ticks',linspace(clims{i}(1),clims{i}(2),cbins(j)),'TickLabels',linspace(clims{i}(1),clims{i}(2),cbins(j)),'fontsize',fsize);
            cbarrow
        end
        
        % nest a bar plot
        po=get(haa(flag),'Position');
        po(1)=po(1)+0.04;
        po(2)=po(2)+0.03;
        po(3)=po(3)*0.35;
        po(4)=po(4)*0.35;
        hn = axes('position',po);
        hold on
        if i==2&&j==1
            climij=[-0.2,0.2];
        else
            climij=clims{i};
        end
        temp=histogram(data{i,j}(:),linspace(climij(1),climij(2),10),...
            'facecolor',[0.8,0.8,0.8],'edgecolor',[0.8,0.8,0.8]);
        %         plot([clims{i,j}(1),clims{i,j}(1)],[0,max(temp.Values)],'-k');
        set(hn,'ylim',[0,max(temp.Values)],'yticklabel','','ycolor',[1,1,1],'xcolor',[1,1,1]*0.6);
        set(hn,'xtick',linspace(climij(1),climij(2),3),'xticklabel',linspace(climij(1),climij(2),3),'fontsize',fsize)

        flag=flag+1;
    end
end

% add boxplot
axes(haa(flag))
axis off
axes(haa(flag+1))
axis off
po=get(haa(flag),'Position');
po(1)=po(1)+0.04;
po(2)=po(2);
po(3)=po(3)*2;
po(4)=po(4);
hn = axes('position',po);
hold on
x=1:12;
bscond_month2=permute(bscond_month,[1,3,2]);
h = boxplot2(bscond_month2,x);
ylim([0,0.4])
xlim([0.5,12.5]);
xlabel('Month');
ylabel('Brier score');

set(h.out, 'marker', 'none');
color1=[0.41961	0.55686	0.13725];
color2=[0.80392	0.71765	0.61961];
color3=[0.47843	0.40392	0.93333];
color4=[0.11765	0.56471	1];
cmap(1,:)=color1;
cmap(2,:)=color3;
cmap(3,:)=color4;
for ii = 1:3
    structfun(@(x) set(x(ii,:), 'color', cmap(ii,:), ...
        'markeredgecolor', cmap(ii,:)), h);
end
legend({'Regression','BMA','OI'},'Location','north','NumColumns',3,'Box','off','FontSize',fsize);
set(hn,'XTick',1:12,'XTickLabel',1:12,'YTick',0:0.1:0.4);
set(hn,'FontSize',fsize+1);
text(1,0.37,'(e)','fontsize',fsize+2);

% fig = gcf;
% fig.PaperPositionMode='auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(gcf,'-dpng',[Outfigure,'.png'],'-r600');