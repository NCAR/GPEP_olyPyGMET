% same date but different members
close all
clc;clear
addpath('~/m_map');

day=1;
pall=zeros(800,1300,11);

file1='/Users/localuser/GMET/test0622/reg_197901.nc';
p1=ncread(file1,'pcp');
p1=(p1/4+1).^4;
p1=flipud(permute(p1,[2,1,3]));

pall(:,:,1)=p1(:,:,day);
for i=1:10
    file2=['/Users/localuser/GMET/test0622/ens_197901.',num2str(i,'%.3d'),'.nc'];
    prcp=ncread(file2,'pcp');
    prcp(prcp<0)=nan;
    prcp=flipud(permute(prcp,[2,1,3]));
    pall(:,:,i+1)=prcp(:,:,day);
end

fsize=7;
figure('color','w','unit','centimeters','position',[15,20,20,20]);
haa=tight_subplot(4,3, [.05 .05],[.03 .03],[.04 .02]);
for i=1:12
    axes(haa(i));
    if i<=11
        imagesc(pall(:,:,i),'alphadata',~isnan(pall(:,:,i)));
        xlim([700,1300]);
        ylim([200,600]);
        colormap(jet)
        caxis([0,80])
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