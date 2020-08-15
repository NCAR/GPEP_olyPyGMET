clc;clear;close all

stv=[1,0.6];
range={[0.1,15],[0.1,2]};

%%% stn
load('/Users/localuser/Research/EMDNA/stndata_aftercheck.mat','stninfo')

nstn=size(prcp_stn,1);
logmean=nan*zeros(nstn,1);
logstd=nan*zeros(nstn,1);
c2=0.6;
c1=nan*zeros(nstn,1);
beta=nan*zeros(nstn,1);
for i=1:nstn
    pi=prcp_stn(i,:);
    pi=pi(pi>=0.1);
    if length(pi)>100
        logpi=log(pi);
        logmean(i)=mean(logpi);
        logstd(i)=std(logpi);
        
        % GG parameters
        p_mean=mean(pi);
        p_std=std(pi);
        p_cv=p_std/p_mean;
        
        fun=@(x)(p_cv-(gamma(x/c2)*gamma((x+2)/c2)/(gamma((x+1)/c2))^2 -1)^0.5)^2;
        x=fminsearch(fun,1);
        c1(i)=x;
        beta(i)=p_mean*gamma(x/c2)/gamma((1+x)/c2);
    end
    
end

subplot(2,2,1)
scatter(stninfo(:,3),stninfo(:,2),5,logmean,'filled');
colormap('jet')
colorbar
caxis([-1,2])
title('mean of Log(P)')
subplot(2,2,2)
scatter(stninfo(:,3),stninfo(:,2),5,logstd,'filled');
colormap('jet')
colorbar
caxis([0,2])
title('standard deviation of Log(P)')

subplot(2,2,3)
scatter(stninfo(:,3),stninfo(:,2),5,c1,'filled');
colormap('jet')
colorbar
caxis([0,2])
title('c1 of GG with fixed c2=0.6 based on P')
subplot(2,2,4)
scatter(stninfo(:,3),stninfo(:,2),5,beta,'filled');
colormap('jet')
colorbar
title('beta of GG with fixed c2=0.6 based on P')
caxis([0,5]);

%%%% rea
% load('/Users/localuser/Research/EMDNA/JRA55_downto_stn_nearest.mat','prcp_readown','stn_lle')
% 
% nstn=size(prcp_readown,1);
% logmean=nan*zeros(nstn,1);
% logstd=nan*zeros(nstn,1);
% c2=0.6;
% c1=nan*zeros(nstn,1);
% beta=nan*zeros(nstn,1);
% for i=1:nstn
%     pi=prcp_readown(i,:);
%     pi=pi(pi>=0.1);
%     if length(pi)>100
%         logpi=log(pi);
%         logmean(i)=mean(logpi);
%         logstd(i)=std(logpi);
%         
%         % GG parameters
%         p_mean=mean(pi);
%         p_std=std(pi);
%         p_cv=p_std/p_mean;
%         
%         fun=@(x)(p_cv-(gamma(x/c2)*gamma((x+2)/c2)/(gamma((x+1)/c2))^2 -1)^0.5)^2;
%         x=fminsearch(fun,1);
%         c1(i)=x;
%         beta(i)=p_mean*gamma(x/c2)/gamma((1+x)/c2);
%     end
%     
% end
% 
% 
% subplot(2,2,1)
% scatter(stn_lle(:,2),stn_lle(:,1),5,logmean,'filled');
% colormap('jet')
% colorbar
% caxis([-1,2])
% title('mean of Log(P)')
% subplot(2,2,2)
% scatter(stn_lle(:,2),stn_lle(:,1),5,logstd,'filled');
% colormap('jet')
% colorbar
% caxis([0,2])
% title('standard deviation of Log(P)')
% 
% subplot(2,2,3)
% scatter(stn_lle(:,2),stn_lle(:,1),5,c1,'filled');
% colormap('jet')
% colorbar
% caxis([0,2])
% title('c1 of GG with fixed c2=0.6 based on P')
% subplot(2,2,4)
% scatter(stn_lle(:,2),stn_lle(:,1),5,beta,'filled');
% colormap('jet')
% colorbar
% title('beta of GG with fixed c2=0.6 based on P')
% caxis([0,5]);
% 
% fig = gcf;
% fig.PaperPositionMode='auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(gcf,'-dpng',['JRA55_near','.png'],'-r600');
% 
