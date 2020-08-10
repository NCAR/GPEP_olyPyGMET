% study the improvement of OI against station density
clc;clear;close all

Outfigure='gain_vs_dist_oiregrea';
% calculate distance
datafile='stn_dist.mat';
if exist(datafile,'file')
    load(datafile);
else
    filestn='/Users/localuser/Research/EMDNA/stndata_aftercheck.mat';
    % prcp
    load(filestn,'prcp_stn','stninfo');
    lle=stninfo(:,2:4);
    nstn=size(lle,1);
    lle(isnan(prcp_stn(:,1)),:)=nan;
    dist1=nan*zeros(nstn,4); % 1, 10, 20, 30 closest station
    for i=1:nstn
        if ~isnan(lle(i,1))
            distij=lldistkm(lle(i,1),lle(i,2),lle(:,1),lle(:,2));
            distij(i)=1e10;
            distij(isnan(distij))=1e10;
            distij=sort(distij);
            dist1(i,1)=distij(1);
            dist1(i,2)=distij(10);
            dist1(i,3)=distij(20);
            dist1(i,4)=distij(30);
        end
    end
    
    % tmean
    load(filestn,'tmean_stn','stninfo');
    lle=stninfo(:,2:4);
    nstn=size(lle,1);
    lle(isnan(tmean_stn(:,1)),:)=nan;
    dist2=nan*zeros(nstn,4); % 1, 10, 20, 30 closest station
    for i=1:nstn
        if ~isnan(lle(i,1))
            distij=lldistkm(lle(i,1),lle(i,2),lle(:,1),lle(:,2));
            distij(i)=1e10;
            distij(isnan(distij))=1e10;
            distij=sort(distij);
            dist2(i,1)=distij(1);
            dist2(i,2)=distij(10);
            dist2(i,3)=distij(20);
            dist2(i,4)=distij(30);
        end
    end
    dist=cell(3,1);
    dist{1}=dist1;
    dist{2}=dist2;
    dist{3}=dist2;
    lle=stninfo(:,2:4);
    save(datafile,'dist','lle');
end

% grid distance
datafile='data_oireg.mat';
load(datafile,'gridnum','distbin','metnum','metbin','metdist');
metbin1=metbin;
datafile='data_oirea.mat';
load(datafile,'gridnum','distbin','metnum','metbin','metdist');
metbin2=metbin;



% basic settings
% titles={'(a) Precipitation','(b) Mean temperature','(c) Temperature range'};
titles={'(a) Precipitation','(b) Mean temperature','(c) Temperature range'};
ylabels={'mm/day', '\circC', '\circC'};
ylims=[0, 0.5; 0, 0.05; 0, 0.5];
fsize=6;
color1=[0.41961	0.55686	0.13725];
color2=[0.80392	0.71765	0.61961];

color3=[0.47843	0.40392	0.93333];
color4=[0.11765	0.56471	1];


figure('color','w','unit','centimeters','position',[15,20,18,20]);
haa=tight_subplot(3,1, [.12 .05],[.16 .02],[.06 .06]);

for i=1:3
    axes(haa(i))
    % plot main figure
    yyaxis left
    hold on
    plot(metdist,metbin1{i}(:,1),'*-','Color',color1,'LineWidth',1.5);
    plot(metdist,metbin2{i}(:,1),'^--','Color',color1,'LineWidth',1.5);
    hold off
    ylabel('CC difference')
    set(gca,'ylim',ylims(i,:),'ytick',linspace(ylims(i,1),ylims(i,2),6),'yticklabel',linspace(ylims(i,1),ylims(i,2),6))
    
    yyaxis right
    hold on
    plot(metdist,metbin1{i}(:,2),'*-','Color',color2,'LineWidth',1.5);
    plot(metdist,metbin2{i}(:,2),'^--','Color',color2,'LineWidth',1.5);
    hold off
    if i==2
        ylabel('RMSE difference')
    else
        ylabel('NRMSE difference')
    end
        
    ax=gca;
    ax.YAxis(1).Color = color1;
    ax.YAxis(2).Color = color2;
    ax.XScale='log';
    ax.FontSize=fsize;
    
    xlim([0,1000]);
    % figure title
    th=title(titles{i},'FontWeight','normal','FontSize',fsize+3);
    th.Position(2)=th.Position(2)*0.9;
%     th.Position(1)=th.Position(1)*0.15;
    
    %  nest grid number bar
    po=get(haa(i),'Position');
    po(1)=po(1);
    po(2)=po(2)-0.065;
    po(3)=po(3);
    po(4)=0.065;
    hn = axes('position',po);
    
    hold on
    yyaxis right
    dij=squeeze(gridnum(3,i,:));
    x=[metdist;flipud(metdist)];
    y=[dij;dij*0];
    fill(x,y,color3,'FaceAlpha',0.5);
    set(hn,'YLim',[0,60000],'YTick',[0,20000,40000],'YTickLabel',[0,20000,40000]);
    ylabel('Number');
    
    yyaxis left
    dij=metnum{i}(:,1);
    y=[dij;dij*0];
    fill(x,y,color4,'FaceAlpha',0.5);
    set(hn,'YLim',[0,6000],'YTick',[0,2000,4000],'YTickLabel',[0,2000,4000]);
    ylabel('Number');
    hold off
    box on
    hn.XScale='log';
%     set(hn,'xColor',[0.4,0.4,0.4],'yColor',[0.32549	0.52549	0.5451]);
    hn.YAxis(1).Color = color4;
    hn.YAxis(2).Color = color3;
    
    xlim([0,1000]);
    xlabel('Distance (km)')
    set(hn,'fontsize',fsize)
end

lh1=legend(hn,{'Station number','Grid number'},'Box','off',...
    'Location','south','NumColumns',2,'FontSize',fsize);
lh1.Position=lh1.Position+[0.33, -0.08, 0, 0];
lh2=legend(ax,{'CC: OI - REG','CC: OI - BMA','RMSE: OI - REG','RMSE: OI - BMA'},...
    'NumColumns',4,'Box','off','Location','south','FontSize',fsize);
lh2.Position(1)=lh1.Position(1)-lh2.Position(3);
lh2.Position(2)=lh1.Position(2);

% fig = gcf;
% fig.PaperPositionMode='auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(gcf,'-dpng',[Outfigure,'.png'],'-r600');
