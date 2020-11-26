clc;clear;close all
addpath('~/m_map');


Outfigure='pop_Clim';
datafile='clim_pop.mat';
if exist(datafile,'file')
    load(datafile,'pop_stn','pop_ens','LLE','num');
else
    inpath='/Users/localuser/Research/EMDNA/EMDNA_evaluate/climPoP';
    year=1979:2018;
    leastnum=5; % least years
    
    % load all data
    data=cell(length(year),1);
    for i=1:length(year)
        filei=[inpath,'/pop_prcp_',num2str(year(i)),'.mat'];
        data{i}=load(filei);
    end
    
    % find stations that have >= leastnum during the period
    LLE=[];
    for i=1:length(year)
        LLE=cat(1,LLE,data{i}.LLE);
    end
    LLEu=unique(LLE,'rows');
    numu=zeros(size(LLEu,1),1);
    for i=11286:size(LLEu,1)
        numu(i)=sum(ismember(LLE,LLEu(i,:),'rows'));
    end
    LLE=LLEu(numu>=leastnum,:);
    num=numu(numu>=leastnum);
    % extract those stations
    nstn=size(LLE,1);
    pop_stn=nan*zeros(nstn,size(data{1}.pop_stn,2));
    pop_ens=nan*zeros(nstn,size(data{1}.pop_stn,2));
    for n=1:nstn
        if mod(n,100)==0
            fprintf('%d--%d\n',n,nstn);
        end
        popn1=0;
        popn2=0;
        for i=1:length(year)
            indi=ismember(data{i}.LLE,LLE(n,:),'rows');
            if sum(indi)==1
                popn1=popn1+data{i}.pop_stn(indi,:);
                popn2=popn2+data{i}.pop_ens(indi,:);
            end
        end
        pop_stn(n,:)=popn1/num(n);
        pop_ens(n,:)=popn2/num(n);
    end
    save(datafile,'pop_stn','pop_ens','LLE','num');
end
% plot
dataplot=cell(3,1);
dataplot{1}=pop_stn(:,1);
dataplot{2}=pop_ens(:,1);
dataplot{3}=pop_ens(:,1)-pop_stn(:,1);

titles={'(a) Station PoP','(b) Ensemble PoP','(c) Ensemble - Station'};

clims=cell(3,1);
clims{1}=[0,0.6];
clims{2}=[0,0.6];
clims{3}=[-0.2,0.2];
cbins=[4,4,5];

fsize=5;

shapefile='/Users/localuser/Google Drive/Datasets/Shapefiles/North America/From MERIT DEM/North_America.shp';
shp=shaperead(shapefile);

figure('color','w','unit','centimeters','position',[15,20,15,6]);
haa=tight_subplot(1,3, [0.0 0.03],[.1 0],[.02 .02]);

for i=1:3
    dij=squeeze(dataplot{i});
    
    axes(haa(i));
    m_proj('equidistant','lon',[-180 -50],'lat',[5 85]);
    hold on
    for q=1:length(shp)
        ll1=shp(q).X; ll2=shp(q).Y; % delete Hawaii
        m_line(ll1,ll2,'color',[0.6,0.6,0.6]);
    end
    m_scatter(LLE(:,2),LLE(:,1),3,dij,'filled');
    hold off
    shading flat
    m_grid('linewi',0.5,'tickdir','in','fontsize',fsize,'xtick',-180:30:-50,'xticklabel','','yticklabel','','color',[0.6,0.6,0.6]);
    
    % color
    caxis(clims{i});
    if i<=2
        colormap(gca,m_colmap('water',64));
    else
        colormap(gca,m_colmap('jet',64));
    end
    
    % titles
    title(titles{i},'fontsize',fsize+3);
    
    % colorbar
    h=colorbar('south','fontsize',fsize);
    h.Position=h.Position+[0 -0.16 0 0];
    h.AxisLocation='out';
    set(h,'Ticks',linspace(clims{i}(1),clims{i}(2),cbins(i)),'TickLabels',linspace(clims{i}(1),clims{i}(2),cbins(i)),'fontsize',fsize);
end
fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(gcf,'-dpng',[Outfigure,'.png'],'-r600');






