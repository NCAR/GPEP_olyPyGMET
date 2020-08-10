clc;clear;close all

Outfigure='rank_diagram';

data=cell(3,1);
load('rank_prcp_2016-2016.mat');
data{1}=rank;
load('rank_tmean_2016-2016.mat');
data{2}=rank;
load('rank_trange_2016-2016.mat');
data{3}=rank;

titles={'(a) Precipitation','(b) Mean temperature','(c) Temperature range'};

fsize=7;
figure('color','w','unit','centimeters','position',[15,20,12,16]);
haa=tight_subplot(3,1, [.1 .02],[.05 .03],[.1 .02]);
flag=1;

for i=1:3
    axes(haa(i))
    h=histogram(data{i},0.5:2:100.5,'Normalization','probability','EdgeColor','w','FaceColor',[0	0.80392	0.4]);
    xlabel('Rank');
    ylabel('Frequency');
    set(gca,'fontsize',fsize);
    title(titles{i},'fontweight','normal','FontSize',fsize+2);
end

fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(gcf,'-dpng',[Outfigure,'.png'],'-r600');
