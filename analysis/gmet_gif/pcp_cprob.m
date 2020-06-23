% same date but different members
close all
clc;clear
addpath('~/m_map');

day=1;
pop=zeros(800,1300,11);
cs=zeros(800,1300,11);
rn=zeros(800,1300,11);

file1='/Users/localuser/GMET/test0622/reg_197901.nc';
p1=ncread(file1,'pop');
p1=flipud(permute(p1,[2,1,3]));

pop(:,:,1)=p1(:,:,day);
for i=1:10
    file2=['/Users/localuser/GMET/test0622/ens_197901.',num2str(i,'%.3d'),'.nc'];
    cprob=ncread(file2,'pcp_cprob');
    cprob(cprob==0)=nan;
    cprob=flipud(permute(cprob,[2,1,3]));
    % cumulative probability
    pop(:,:,i+1)=cprob(:,:,day);
    % conditional probability
    cs(:,:,i+1)=(cprob(:,:,day)-(1-pop(:,:,1)))./pop(:,:,1);
    % calculate rn
    rn(:,:,i+1) = sqrt (2) * erfinv (2*cs(:,:,i+1)-1);
end


pdata=pop;
fsize=7;
figure('color','w','unit','centimeters','position',[15,20,20,20]);
haa=tight_subplot(4,3, [.05 .05],[.03 .03],[.04 .02]);
for i=1:12
    axes(haa(i));
    if i<=11 
        imagesc(pdata(:,:,i),'alphadata',~isnan(pdata(:,:,i)));
%         xlim([700,1300]);
%         ylim([200,600]);
        colormap(jet)
        caxis([0,1])
        if i==1
            title('OI merge')
        else
            title(['Ens member ',num2str(i-1)]);
        end
%         set(gca,'ColorScale','log')
    end
    
    if i==11
        h=colorbar('south','fontsize',fsize);
        h.Position=h.Position+[0.3 0.1 0. 0.0];
    end
    
    axis off
    box off
end