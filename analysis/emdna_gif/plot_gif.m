clc;clear;close all
addpath('~/m_map/');
file='/Users/localuser/Research/EMDNA/ens_allmember/EMDNA_201606_prcp.mat';
load(file,'prcp');
prcp=permute(prcp,[2,1,3]);
prcp=flipud(prcp);


lat=85-0.05:-0.1:5+0.05;
lon=-180+0.05:0.1:-50-0.05;


fsize=12;
h = figure('color','w');
% axis tight manual % this ensures that getframe() returns a consistent size
filename = 'prcp_201606_10member.gif';
for n = 1:10
    m_proj('Miller','lon',[-180 -50],'lat',[5 85]);
    m_pcolor(lon,lat,prcp(:,:,n));
%     imagesc(prcp(:,:,n),'alphadata',prcp(:,:,n)>=0);
    shading flat
    m_grid('linewi',0.5,'tickdir','in','fontsize',fsize);
    caxis([0,8]);
    colormap(gca,'winter');
    title(['2016-06 Member ',num2str(n)],'fontsize',fsize+5);
    axis off
    
    ch=colorbar('eastoutside','fontsize',fsize);
    ch.TickDirection='in';
    ch.Position=ch.Position+[0.07, 0, 0, 0];
    title(ch,'mm/d');
    
    % Capture the plot as an image
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if n == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.2);
    end
end