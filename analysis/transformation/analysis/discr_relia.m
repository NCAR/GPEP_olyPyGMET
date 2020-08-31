clc;clear;close all
filename='discr_relia_gif';
% h=figure('color','w','unit','centimeters','position',[10,10,10,16]);
for n=1:21
    Outfigure=['discr_relia_',num2str(n)];
    if n<=20
        load(['reliab_discri_data_2016_',num2str(n),'.mat']);
    else
       load(['reliab_discri_data_2016_fixbc.mat']); 
    end
    rnr_use=[1,3,4,5];
    RNRuse=thresh(rnr_use);
    reliab_data=reliab_data(:,:,rnr_use);
    discri_data=discri_data(:,:,rnr_use);
    
    data=cell(length(rnr_use),2);
    for i=1:length(rnr_use)
        data{i,1}=discri_data(:,:,i);
        data{i,2}=reliab_data(:,:,i);
    end
    
    basicfont=5;
    titles={{['Function ',num2str(n)],'(a) Discrimination'},{['Function ',num2str(n)],'(b) Reliability'},...
        '(c) Discrimination','(d) Reliability',...
        '(e) Discrimination','(f) Reliability',...
        '(g) Discrimination','(h) Reliability'};
    legends={'No Precipitation','Precipitation'};
    figure('color','w','unit','centimeters','position',[10,10,10,16]);
    haa=tight_subplot(4,2, [.03 .1],[.05 .01],[.08 .02]);
    flag=1;
    for i=1:4
        for j=1:2
            axes(haa(flag));
            if j==1
                hold on
                plot(bin,data{i,j}(:,2),'.-k');
                plot(bin,data{i,j}(:,1),'.-r');
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
    print(gcf,'-dpng',[Outfigure,'.png'],'-r300');
%         Capture the plot as an image
%         
%     frame = getframe(h);
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%     % Write to the GIF File
%     if n == 1
%         imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
%     else
%         imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',1);
%     end
    
end