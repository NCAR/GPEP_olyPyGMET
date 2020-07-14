clc;clear;close all
load('ensemble_data_2016.mat');

n=1; % station number
titles={'P','T_{mean}','T_{range}'};
units={'mm/d','\circC', '\circC'};
ylims=[0,50; -2,14; 0,10];

fsize=6;
figure('color','w','unit','centimeters','position',[15,20,10,4]);
haa=tight_subplot(1,3, [0.02 0.07],[.2 .04],[.05 .02]);
for v=1:3
    axes(haa(v));
    dens2=squeeze(dens(v,:,n,:));
    dstn2=squeeze(dstn(v,:,n));
    if v==1
        dstn2=(dstn2/3+1).^3;
    end
    
    pens=nan*zeros(366,10);
    for i=1:366
        for j=1:9
            pens(i,j)=prctile(dens2(i,:),j*10);
        end
    end
    
    hold on
    x = 1 : 366;
    curve1 = pens(:,1)';
    curve2 =pens(:,9)';
    x2 = [x, fliplr(x)];
    inBetween = [curve1, fliplr(curve2)];
    fill(x2, inBetween, [1	0.96471	0.56078]);
    
    x = 1 : 366;
    curve1 = pens(:,3)';
    curve2 =pens(:,7)';
    x2 = [x, fliplr(x)];
    inBetween = [curve1, fliplr(curve2)];
    fill(x2, inBetween, [0.80392	0.77647	0.45098],'LineStyle','none');
    
    
    plot(x,dstn2,'.r','markersize',5)
    hold off
    xlim([1,30])
    xlabel('January 2016');
    set(gca,'xtick',[1,15,30],'xticklabel',[1,15,30]);
    set(gca,'ylim',[ylims(v,1),ylims(v,2)],'ytick',linspace(ylims(v,1),ylims(v,2),3),'yticklabel',linspace(ylims(v,1),ylims(v,2),3));
    text(15,(ylims(v,2)-ylims(v,1))*0.95+ylims(v,1),titles{v},'fontsize',fsize);
%     text(0,(ylims(v,2)-ylims(v,1))*1+ylims(v,1),units{v},'fontsize',fsize);
    set(gca,'fontsize',fsize);
end

% export_fig ensemble_example.png -transparent -m20