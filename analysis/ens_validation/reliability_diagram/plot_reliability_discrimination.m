clc;clear;close all
Outfigure='Discrimination_Reliability';
% plot reliablity diagrams
% mac path
Infile_gauge='/Users/localuser/GMET/EMDNA_evaluate/ens/stn_prcp.mat';
Infile_ensemble='/Users/localuser/GMET/EMDNA_evaluate/ens/ens_prcp.mat';

% Plato path
% Infile_gauge='/home/gut428/GMET/EMDNA_ens_evaluation/stn_prcp_andrew.mat';
% Infile_ensemble='/home/gut428/GMET/EMDNA_ens_evaluation/ens_prcp_andrew.mat';
File_prob='Probability_data.mat';
YEAR=2016:2016;
leastnum=300; % the least number of gauge samples so that the gauge will be included in evaluation
RNR_threshold=[0,1,10,25,50]; % rain or no rain
Info.latrange=[5,85]; % this must be consistent with ensemble estimates
Info.lonrange=[-180,-50];
Info.cellsize=0.1;
% data preparation
[prob_ens,prob_stn]=f_probability_data(File_prob,Infile_gauge,Infile_ensemble,RNR_threshold);

bin=0:0.1:1;
rnr_use=[1,3,4,5];
reliability_data=f_reliability_data(prob_ens,prob_stn,bin,rnr_use);
discrimination_data=f_discrimination_data(prob_ens,prob_stn,bin,rnr_use);

% plot
bin2=(bin(1)+0.05):0.1:(1-0.05);
RNRuse=RNR_threshold(rnr_use);
data=cell(length(rnr_use),2);
data(:,1)=discrimination_data;
data(:,2)=reliability_data;
basicfont=5;
titles={'(a) Discrimination','(b) Reliability',...
    '(c) Discrimination','(d) Reliability',...
    '(e) Discrimination','(f) Reliability',...
    '(g) Discrimination','(h) Reliability'};
legends={'No Precipitation','Precipitation'};
figure('color','w','unit','centimeters','position',[5,2,10,16]);
haa=tight_subplot(4,2, [.03 .1],[.05 .03],[.08 .04]);
flag=1;
for i=1:4
    for j=1:2
        axes(haa(flag));
        if j==1
            hold on
            plot(bin2,data{i,j}(:,1),'.-k');
            plot(bin2,data{i,j}(:,2),'.-r');
            hold off
            set(gca,'xlim',[0,1],'ylim',[0,1],...
                'xtick',0:0.2:1,'xticklabel',0:0.2:1,'ytick',0:0.2:1,'yticklabel',0:0.2:1,'fontsize',basicfont);
            if i==4
                xlabel('Estimated Probability','fontsize',basicfont);
            end
            ylabel('Relative Frequency','fontsize',basicfont);
            th=title(titles{flag},'fontsize',basicfont+1);
            th.Position(2)=0.9;
            lh=legend(legends,'box','off','fontsize',basicfont,'Location','east');
            text(0.2,0.7,['P > ',num2str(RNRuse(i)),' mm'],'fontsize',basicfont);
        elseif j==2
            hold on
            plot(data{i,j}(:,2),data{i,j}(:,1),'.-b');
            plot([0,1],[0,1],'-k');
            hold off
            set(gca,'xlim',[0,1],'ylim',[0,1],...
                'xtick',0:0.2:1,'xticklabel',0:0.2:1,'ytick',0:0.2:1,'yticklabel',0:0.2:1,'fontsize',basicfont);
            if i==4
            xlabel('Estimated Probability','fontsize',basicfont);
            end
            ylabel('Observed Probability','fontsize',basicfont);
            th=title(titles{flag},'fontsize',basicfont+1);
            th.Position(2)=0.9;
            text(0.2,0.7,['P > ',num2str(RNRuse(i)),' mm'],'fontsize',basicfont);
        end
        flag=flag+1;
    end
end

fig = gcf;
fig.PaperPositionMode='auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(gcf,'-djpeg',[Outfigure,'.jpg'],'-r600');