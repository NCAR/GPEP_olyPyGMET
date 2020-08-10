% study the improvement of OI against station density
clc;clear;close all

Outfigure='dist_reg_rea';
% calculate distance
datafile='../gain_vs_distance/stn_dist.mat';
load(datafile);
load('data_oiregrea.mat','metbin_reg', 'metbin_oi', 'metbin_rea','metdist');

data=cell(3,2);
for i=1:2
   data{1,i}=[metbin_rea{1}(:,i),metbin_reg{1}(:,i),metbin_oi{1}(:,i)];
   data{2,i}=[metbin_rea{2}(:,i),metbin_reg{2}(:,i),metbin_oi{2}(:,i)];
   data{3,i}=[metbin_rea{3}(:,i),metbin_reg{3}(:,i),metbin_oi{3}(:,i)];
end

figure('color','w','unit','centimeters','position',[15,20,18,18]);
haa=tight_subplot(3,2, [.12 .05],[.11 .02],[.06 .06]);
flag=1;
for i=1:3
    for j=1:2
        axes(haa(flag))
        plot(metdist,data{i,j},'.-');
%         xlim([100,500]);
        legend({'REA','REG','OI'});
        flag=flag+1;
    end
end


% fig = gcf;
% fig.PaperPositionMode='auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(gcf,'-dpng',[Outfigure,'.png'],'-r600');
