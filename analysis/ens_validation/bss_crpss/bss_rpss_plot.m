clc;clear;close all
Outfigure='bss_rpss';
datafile='bss_rpss.mat';
if exist(datafile,'file')
    load(datafile);
else
    path='/Users/localuser/Research/EMDNA/EMDNA_evaluate/bss_rpss';
    year=1979:2018;
    bss_year=nan*zeros(40,6);
    rpss_year=nan*zeros(40,2);
    bss_prcp=[];
    rpss_tmean=[];
    rpss_trange=[];
    for i=1:40
        filei=[path,'/bss_rpss_prcp_',num2str(year(i)),'.mat'];
        load(filei,'bss');
        bss_year(i,:)=nanmedian(bss,1);
        bss_prcp=[bss_prcp;bss];
        
        filei=[path,'/bss_rpss_tmean_',num2str(year(i)),'.mat'];
        load(filei,'rpss');
        rpss_year(i,1)=nanmedian(rpss);
        rpss_tmean=[rpss_tmean;rpss(:)];
        
        filei=[path,'/bss_rpss_trange_',num2str(year(i)),'.mat'];
        load(filei,'rpss');
        rpss_year(i,2)=nanmedian(rpss);
        rpss_trange=[rpss_trange;rpss(:)];
    end
    
    
    bins0=cell(3,1);
    bins0{1}=-1:0.05:1;
    bins0{2}=-2:0.1:1;
    bins0{3}=-2:0.1:1;
    bins=cell(3,1);
    
    bss_prcp_pdf=nan*zeros(length(bins0{1})-1,6);
    for i=1:length(bins0{1})-1
        for j=1:6
            bss_prcp_pdf(i,j)=sum(bss_prcp(:,j)>bins0{1}(i) & bss_prcp(:,j)<=bins0{1}(i+1));
        end
        bins{1}(i,1)=(bins0{1}(i)+bins0{1}(i+1))/2;
    end
    bss_prcp_pdf=bss_prcp_pdf/sum(~isnan(bss_prcp(:,1)));
    
    
    rpss_tmean_pdf=nan*zeros(length(bins0{2})-1,1);
    for i=1:length(bins0{2})-1
        rpss_tmean_pdf(i,1)=sum(rpss_tmean>bins0{2}(i) & rpss_tmean<=bins0{2}(i+1));
        bins{2}(i,1)=(bins0{2}(i)+bins0{2}(i+1))/2;
    end
    rpss_tmean_pdf=rpss_tmean_pdf/sum(~isnan(rpss_tmean));
    
    rpss_trange_pdf=nan*zeros(length(bins0{3})-1,1);
    for i=1:length(bins0{3})-1
        rpss_trange_pdf(i,1)=sum(rpss_trange>bins0{3}(i) & rpss_trange<=bins0{3}(i+1));
        bins{3}(i,1)=(bins0{3}(i)+bins0{3}(i+1))/2;
    end
    rpss_trange_pdf=rpss_trange_pdf/sum(~isnan(rpss_trange));
    
    save(datafile,'bins','bss_prcp_pdf','rpss_tmean_pdf','rpss_trange_pdf','bss_prcp','rpss_tmean','rpss_trange','bss_year','rpss_year');
end

% plot
fsize=7;
clrs=winter(6);
clrs=flipud(clrs);

figure('color','w','unit','centimeters','position',[10,10,12,16]);
haa=tight_subplot(3,1, [.06 .1],[.05 .02],[.08 .02]);

axes(haa(1));
hold on
for i=1:6
    plot(bins{1},bss_prcp_pdf(:,i),'Color',clrs(i,:),'linewidth',1)
end
hold off
set(gca,'xlim',[-1,1],'xtick',-1:0.5:1,'xticklabel',-1:0.5:1);
set(gca,'ylim',[0,0.2],'ytick',0:0.1:0.2,'yticklabel',0:0.1:0.2);
set(gca,'fontsize',fsize,'Box','on');
xlabel('BSS','fontsize',fsize+1);
ylabel('Frequency','fontsize',fsize+1);
legend({'0','5','10','15','20','25'},'location','northwest','box','off');
th=title('(a)','fontweight','normal','fontsize',fsize+2);
th.Position(2)=th.Position(2)*0.85;

axes(haa(2));
hold on
for i=1:6
    plot(1979:2018,bss_year(:,i),'Color',clrs(i,:),'linewidth',1)
end
hold off
set(gca,'xlim',[1979,2018],'xtick',1980:5:2018,'xticklabel',1980:5:2018);
set(gca,'ylim',[0.2,0.6],'ytick',0:0.1:1,'yticklabel',0:0.1:1);
xlabel('Year','fontsize',fsize+1);
ylabel('BSS','fontsize',fsize+1);
set(gca,'fontsize',fsize,'Box','on');
th=title('(b)','fontweight','normal','fontsize',fsize+2);
th.Position(2)=th.Position(2)*0.9;

axes(haa(3));
hold on
plot(bins{2},rpss_tmean_pdf,'Color',[0.13333	0.5451	0.13333],'linewidth',2)
plot(bins{3},rpss_trange_pdf,'Color',[0.69804	0.13333	0.13333],'linewidth',2)
hold off
set(gca,'xlim',[-1,1],'xtick',-2:0.5:1,'xticklabel',-2:0.5:1);
set(gca,'ylim',[0,0.4],'ytick',0:0.1:0.4,'yticklabel',0:0.1:0.4);
set(gca,'fontsize',fsize,'Box','on');
xlabel('CRPSS','fontsize',fsize+1);
ylabel('Frequency','fontsize',fsize+1);
legend({'mean temperature','temperature range'},'location','northwest','box','off');
th=title('(c)','fontweight','normal','fontsize',fsize+2);
th.Position(2)=th.Position(2)*0.85;

% fig = gcf;
% fig.PaperPositionMode='auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(gcf,'-dpng',[Outfigure,'.png'],'-r600');
