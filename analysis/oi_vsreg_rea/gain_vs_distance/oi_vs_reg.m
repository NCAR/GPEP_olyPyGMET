% study the improvement of OI against station density
clc;clear;close all

Outfigure='gain_vs_dist_oireg';
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
if exist(datafile,'file')
    load(datafile);
else
    % distbin=[0:5:95,100:10:190,200:50:450,500:200:2000];
    % distbin=0:5:2000;
    distbin=10.^(1:0.1:3.2);
    distbin=floor(distbin);
    distbin=unique(distbin);
    distbin(1)=1;
    
    % grid
    numbin=length(distbin)-1;
    distgrid=load('../../basic_figure/InputData.mat');
    gridnum=nan*zeros(4,3,numbin);
    for i=1:4
        for j=1:2
            dij=squeeze(distgrid.dist(:,:,i,j));
            for q=1:numbin
                indq=dij>=distbin(q)&dij<distbin(q+1);
                gridnum(i,j,q)=sum(indq(:));
            end
        end
    end
    gridnum(:,3,:)=gridnum(:,2,:);
    
    % station, only consider the 20th closest station
    metbin=cell(3,1);
    metbin(:)={nan*zeros(numbin,16)};
    metbin_oi=metbin;
    metbin_reg=metbin;
    metnum=cell(3,1);
    metnum(:)={nan*zeros(numbin,16)};
    metdist=nan*zeros(numbin,1);
    
    load('../oi_gain/mean_value.mat','mean_stn');
    load('../oi_gain/oi_evaluation.mat','met_prcp_oi','met_tmean_oi','met_trange_oi')
    load('../oi_gain/reg_evaluation.mat','met_prcp_reg','met_tmean_reg','met_trange_reg')
    metall=cell(3,2);
    met_prcp_oi(:,2)=met_prcp_oi(:,2)./mean_stn(:,1);
    met_trange_oi(:,2)=met_trange_oi(:,2)./mean_stn(:,3);
    metall{1,1}=met_prcp_oi; metall{2,1}=met_tmean_oi; metall{3,1}=met_trange_oi;
    
    met_prcp_reg(:,2)=met_prcp_reg(:,2)./mean_stn(:,1);
    met_trange_reg(:,2)=met_trange_reg(:,2)./mean_stn(:,3);
    metall{1,2}=met_prcp_reg; metall{2,2}=met_tmean_reg; metall{3,2}=met_trange_reg;
    for v=1:3
        metv=[metall{v,1},metall{v,2}];
        for i=1:16
            data=[metv(:,[i,i+16]),dist{v}(:,3)];
            data(isnan(data(:,1))|isnan(data(:,2))|isnan(data(:,3)),:)=[];
            for j=1:numbin
                indj=data(:,3)>=distbin(j)&data(:,3)<distbin(j+1);
                metbin{v}(j,i)=nanmedian(data(indj,1)-data(indj,2));
                metbin_oi{v}(j,i)=nanmedian(data(indj,1));
                metbin_reg{v}(j,i)=nanmedian(data(indj,2));
                metnum{v}(j,i)=sum(indj);
                metdist(j)=(distbin(j)+distbin(j+1))/2;
            end
        end
        
    end
    save(datafile,'gridnum','distbin','metnum','metbin','metbin_oi','metbin_reg','metdist');
end


% basic settings
% titles={'(a) Precipitation','(b) Mean temperature','(c) Temperature range'};
% titles={'(a) Precipitation','(b) Mean temperature','(c) Temperature range'};
% ylabels={'mm/day', '\circC', '\circC'};
% ylims=[0, 4; 0, 10; 0, 10];
% fsize=6;
% color1=[0.41961	0.55686	0.13725];
% color2=[0.80392	0.71765	0.61961];
% 
% color3=[0.47843	0.40392	0.93333];
% color4=[0.11765	0.56471	1];
% 
% 
% figure('color','w','unit','centimeters','position',[15,20,18,18]);
% haa=tight_subplot(3,1, [.12 .05],[.11 .02],[.06 .06]);
% 
% for i=1:3
%     axes(haa(i))
%     % plot main figure
%     yyaxis left
%     plot(metdist,metbin{i}(:,1),'*-','Color',color1,'LineWidth',2);
%     ylabel('CC difference')
%     
%     yyaxis right
%     plot(metdist,metbin{i}(:,2),'*-','Color',color2,'LineWidth',2);
%     ylabel('RMSE difference')
%     
%     ax=gca;
%     ax.YAxis(1).Color = color1;
%     ax.YAxis(2).Color = color2;
%     ax.XScale='log';
%     ax.FontSize=fsize;
%     
%     % figure title
%     th=title(titles{i},'FontWeight','normal','FontSize',fsize+3);
%     th.Position(2)=th.Position(2)*0.8;
% %     th.Position(1)=th.Position(1)*0.15;
%     
%     %  nest grid number bar
%     po=get(haa(i),'Position');
%     po(1)=po(1);
%     po(2)=po(2)-0.065;
%     po(3)=po(3);
%     po(4)=0.065;
%     hn = axes('position',po);
%     
%     hold on
%     yyaxis right
%     dij=squeeze(gridnum(3,i,:));
%     x=[metdist;flipud(metdist)];
%     y=[dij;dij*0];
%     fill(x,y,color3,'FaceAlpha',0.5);
%     set(hn,'YLim',[0,60000],'YTick',[0,20000,40000],'YTickLabel',[0,20000,40000]);
%     ylabel('Number');
%     
%     yyaxis left
%     dij=metnum{i}(:,1);
%     y=[dij;dij*0];
%     fill(x,y,color4,'FaceAlpha',0.5);
%     set(hn,'YLim',[0,6000],'YTick',[0,2000,4000],'YTickLabel',[0,2000,4000]);
%     ylabel('Number');
%     hold off
%     box on
%     hn.XScale='log';
% %     set(hn,'xColor',[0.4,0.4,0.4],'yColor',[0.32549	0.52549	0.5451]);
%     hn.YAxis(1).Color = color4;
%     hn.YAxis(2).Color = color3;
% 
%     xlabel('Distance (km)')
%     set(hn,'fontsize',fsize)
% end
% 
% fig = gcf;
% fig.PaperPositionMode='auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(gcf,'-dpng',[Outfigure,'.png'],'-r600');
