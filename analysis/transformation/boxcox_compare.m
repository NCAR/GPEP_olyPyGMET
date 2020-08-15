% clc;clear;close all
filename='boxcoxa_parameter.gif';
load('/Users/localuser/Research/EMDNA/stndata_aftercheck.mat','prcp_stn')
h = figure('color','w');
zz=randperm(27275,100);
for i=1:length(zz)
    p1=prcp_stn(zz(i),:);
    p1(isnan(p1)|p1==0)=[];
    
    if length(p1)>100
        subplot(1,2,1)
        p1t=(p1.^(1/3)-1)*3;
        histogram(p1t,40)
        title('fixed lambda: 1/3')
        
        subplot(1,2,2)
        [p1t,lambda]=boxcox(p1');
        histogram(p1t,40)
        title(['optimized lambda: ',num2str(lambda,'%4f')])
        %     qqplot(p1t)
        
        % Capture the plot as an image
        frame = getframe(h);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        % Write to the GIF File
        if i == 1
            imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
        else
            imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',1);
        end
    end
    
end
