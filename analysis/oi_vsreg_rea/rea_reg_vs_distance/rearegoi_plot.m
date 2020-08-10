% study the improvement of OI against station density
clc;clear;close all

Outfigure='oi_rea_reg_met';
% calculate distance
datafile='../gain_vs_distance/stn_dist.mat';
load(datafile);
% grid distance
datafile='../gain_vs_distance/data_oireg.mat';
load(datafile,'gridnum','distbin','metnum','metbin_reg','metbin_oi','metdist');
metbin1=metbin_reg;
% metbin3=metbin_oi;
datafile='../gain_vs_distance/data_oirea.mat';
load(datafile,'gridnum','distbin','metnum','metbin_rea','metbin_oi','metdist');
metbin2=metbin_rea;
metbin3=metbin_oi;



data=cell(3,2);
for i=1:2
   data{1,i}=[metbin1{1}(:,i),metbin2{1}(:,i),metbin3{1}(:,i)];
   data{2,i}=[metbin1{2}(:,i),metbin2{2}(:,i),metbin3{2}(:,i)];
   data{3,i}=[metbin1{3}(:,i),metbin2{3}(:,i),metbin3{3}(:,i)];
end

figure('color','w','unit','centimeters','position',[15,20,18,18]);
haa=tight_subplot(3,2, [.1 .1],[.07 .02],[.09 .02]);
flag=1;
for i=1:3
    for j=1:2
        axes(haa(flag))
        plot(metdist,data{i,j},'*-','LineWidth',2);
        xlim([20,200]);
        set(gca,'XScale','log');
        
        if j==1
            ylabel('CC');
        else
            if i==1 || i==3
                ylabel('NRMSE') 
            else
                ylabel('RMSE')
            end
        end
        xlabel('Distance (km)');
        
        if i== 1 && j==1
           legend({'REG','REA','OI'},'Box','off'); 
        end
        
        flag=flag+1;
    end
end


% fig = gcf;
% fig.PaperPositionMode='auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(gcf,'-dpng',[Outfigure,'.png'],'-r600');
