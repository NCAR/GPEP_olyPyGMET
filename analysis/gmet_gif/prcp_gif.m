clc;clear;close all
addpath('~/m_map');
file1='/Users/localuser/GMET/test0622/reg_197901.nc';
file2='/Users/localuser/GMET/test0622/ens_197901.001.nc';



p1=ncread(file1,'pcp');
p1=(p1/4+1).^4;
p2=ncread(file2,'pcp');
p2(p2<0)=nan;

p1=flipud(permute(p1,[2,1,3]));
p2=flipud(permute(p2,[2,1,3]));

pall=cell(2,1);
pall{1}=p1;pall{2}=p2;

% read basic information
shapefile='~/Google Drive/Datasets/Shapefiles/North America/From MERIT DEM/North_America.shp';
shp=shaperead(shapefile);
lat=ncread(file1,'latitude');
lon=ncread(file1,'longitude');
lat=fliplr(lat(1,:));
lon=lon(:,1);


ti={'OImerge','Ens member1'};
fsize=8;
h = figure('color','w');
% axis tight manual % this ensures that getframe() returns a consistent size
filename = 'prcp_197901.gif';
for n = 1:31
    for m=1:2
        subplot(1,2,m)
        % Draw plot 
        m_proj('Miller','lon',[-180 -50],'lat',[5 85]);
        hold on
        %shp
        for q=1:length(shp)
            ll1=shp(q).X; ll2=shp(q).Y; % delete Hawaii
            m_line(ll1,ll2,'color','k');
        end
        m_pcolor(lon,lat,pall{m}(:,:,n));
        hold off
        shading flat
        colormap(gca,m_colmap('diverging',20));
        m_grid('linewi',1,'tickdir','out','fontsize',fsize);
        caxis([0,20])
        ch=colorbar('south','fontsize',fsize);
        ch.AxisLocation='out';
        ylabel(ch,'mm/day');
        ch.Position=ch.Position-[0 0.1 0. 0.02];
        title([ti{m},': 1979-01-',num2str(n,'%.2d')]);
    end
    
    
    
    % Capture the plot as an image
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if n == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',1);
    end
end