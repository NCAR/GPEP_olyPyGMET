clc;clear;close all
addpath('~/m_map/');
file='/Users/localuser/Research/EMDNA/ens_allmember/EMDNA_201606_prcp.mat';
load(file,'prcp');
prcp=permute(prcp,[2,1,3]);
prcp=flipud(prcp);


lat=85-0.05:-0.1:5+0.05;
lon=-180+0.05:0.1:-50-0.05;


fsize=15;
h = figure('color','w');
% axis tight manual % this ensures that getframe() returns a consistent size
filename = 'prcp_201606.gif';
for n = 1:100
    imagesc(prcp(:,:,n),'alphadata',prcp(:,:,n)>=0);
    hold off
    shading flat
    caxis([0,8]);
    colormap(gca,m_colmap('jet',60));
    title(['2016-06 Member ',num2str(n)],'fontsize',fsize);
    axis off
    
    ch=colorbar('south');
    ch.TickDirection='in';
    ch.Position=ch.Position+[0.14, -0.1, -0.2, -0.01];
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