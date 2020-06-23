% same date but different members
close all
clc;clear
addpath('~/m_map');

dall=zeros(800,1300,11);

file1='/Users/localuser/GMET/test0622/reg_197901.nc';
d1=ncread(file1,'tmean');
d1=flipud(permute(d1,[2,1,3]));

dall(:,:,1)=d1(:,:,1);
for i=1:10
    file2=['/Users/localuser/GMET/test0622/ens_197901.',num2str(i,'%.3d'),'.nc'];
    di=ncread(file2,'t_mean');
    di(di<-100)=nan;
    di=flipud(permute(di,[2,1,3]));
    dall(:,:,i+1)=di(:,:,1);
end

fsize=7;
figure('color','w','unit','centimeters','position',[15,20,20,20]);
haa=tight_subplot(4,3, [.05 .05],[.03 .03],[.04 .02]);
for i=1:12
    axes(haa(i));
    if i<=11
        imagesc(dall(:,:,i),'alphadata',~isnan(dall(:,:,i)));
        colormap(jet)
        caxis([-30,10])
        if i==1
            title('OI merge')
        else
            title(['Ens member ',num2str(i-1)]);
        end
%         set(gca,'ColorScale','log')
    end
    
    if i==11
        h=colorbar('south','fontsize',fsize);
%         set(get(h,'ylabel'),'String',colortitles{i},'fontsize',fsize);
        h.Position=h.Position+[0.3 0.1 0. 0.0];
    end
    
    axis off
    box off
end