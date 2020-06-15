% plot the autocorrelation between each station and its neighboring
% stations to demonstrate the effect of autocorrelation
clc;clear;close all

var='trange';
Outfigure=['Scatter_',var];

if strcmp(var,'prcp')
    step=[0.02,0.3]; Xlim=[0,1; 0,15]; Ylim=[0,1; 0,15]; 
    Res=zeros(1,2);
    for i=1:2
        Res(i)=(Xlim(i,2)-Xlim(i,1))/step(i);
    end
elseif strcmp(var,'tmean') || strcmp(var,'trange')
    step=[0.01,0.2]; Xlim=[0.5,1; 0,10]; Ylim=[0.5,1; 0,10]; 
    Res=zeros(1,2);
    for i=1:2
        Res(i)=(Xlim(i,2)-Xlim(i,1))/step(i);
    end
end
datafile=['Data_',var,'.mat'];
if ~exist(datafile,'file')
    Infile='../../OIevaluation.mat';
    load(Infile,'stn_lle',['met_',var]);
    command=['dv=met_',var,';'];
    eval(command);
    comb=[1,2; 1,3; 2,3];
    Data=cell(2,3);
    Xrange=cell(2,3);
    Yrange=cell(2,3);
    for i=1:3
        % CC
        xdata=dv(comb(i,1),:,1); ydata=dv(comb(i,2),:,1);
        [Data{1,i},Xrange{1,i},Yrange{1,i}] = f_datapre(xdata,ydata,step(1),Xlim(1,:),Ylim(1,:));
        % RMSE
        xdata=dv(comb(i,1),:,4); ydata=dv(comb(i,2),:,4);
        [Data{2,i},Xrange{2,i},Yrange{2,i}] = f_datapre(xdata,ydata,step(2),Xlim(2,:),Ylim(2,:));
    end
    save(datafile, 'Data', 'Xrange', 'Yrange','comb','Res');
else
    load(datafile)
end


% start plot
load mycolor
fsize=8;
title1={'Regression','Reanalysis','OI'};
title2={'Regression VS Reanalysis','Regression VS OI','Reanalysis VS OI'};

figure('color','w','unit','centimeters','position',[15,20,20,16]);
haa=tight_subplot(2,3, [0.04 0.07],[.13 .03],[.05 .01]);
flag=1;
for i=1:2
    for j=1:3
        axes(haa(flag))
        
        hold on
        dd=flipud(Data{i,j});
        imagesc(dd,'alphadata',dd~=0);
        plot([0,Res(i)],[0,Res(i)],'-r','LineWidth',1);
        hold off
        
        xlim([0,Res(i)]); ylim([0,Res(i)]);
        xlabel(title1{comb(j,1)},'fontsize',fsize+1);
        ylabel(title1{comb(j,2)},'fontsize',fsize+1);

        set(gca,'xtick',linspace(0,Res(i),6),'ytick',linspace(0,Res(i),6));
        set(gca,'fontsize',fsize);
        set(gca,'xticklabel',linspace(Xlim(i,1),Xlim(i,2),6),'yticklabel',linspace(Ylim(i,1),Ylim(i,2),6));

        axis square
        box on
        grid on
        
        %color
        colormap('jet')
        set(gca,'ColorScale','log')
        
        cmax=300;
        caxis([0,cmax]);
        
        if i==2&&j==3
            h=colorbar('south','fontsize',fsize);
            h.Position=h.Position+[-0.5 -0.14 0.32 0.0];
            h.AxisLocation='out';
            ctick=linspace(0,cmax,7);
            ctickstr=cell(length(ctick),1);
            for cc=1:length(ctick)
                ctickstr{cc}=num2str(ctick(cc));
            end
            ctickstr{end}=['>',ctickstr{end}];
            
            set(h,'Ticks',ctick,'TickLabels',ctickstr,'fontsize',fsize);
            set(get(h,'title'),'String','Number of stations','fontsize',fsize+1);
        end
        
        th=title(title2{j},'fontsize',fsize+2);
        flag=flag+1;
    end
end
fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(gcf,'-dpng',[Outfigure,'.png'],'-r600');

