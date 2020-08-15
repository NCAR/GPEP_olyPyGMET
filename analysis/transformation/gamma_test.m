% clc;clear;close all
% load('/Users/localuser/Research/EMDNA/stndata_aftercheck.mat','prcp_stn')
filename='gg_pdf.gif';
h = figure('color','w');
zz=randperm(27275,100);
mse=nan*zeros(100,1);
cc=nan*zeros(100,1);
for ii=1:length(zz)
    i=zz(ii);
    % i=1;
    pi=prcp_stn(i,:);
    pi=pi(pi>=0.1);
    
    if length(pi)<100
        continue
    end
    
    p_mean=mean(pi);
    p_std=std(pi);
    p_cv=p_std/p_mean;
    
    lm2=0.6;
    lm1=0.1:0.01:15;
    diff=p_cv-(gamma(lm1/lm2).*gamma((lm1+2)/lm2)./(gamma((lm1+1)/lm2)).^2 -1).^0.5;
    diff=abs(diff);
    lm1=lm1(diff==min(diff));
    beta=p_mean*gamma(lm1/lm2)/gamma((1+lm1)/lm2);
    
    % plot epdf
    % gg
    step=0.5;
    x=step:step:40;
    gg=lm2/beta/gamma(lm1/lm2)*((x/beta).^(lm1-1)).*(exp(-(x/beta).^lm2));
    % ecdf
    epdf=zeros(length(x),1);
    for i=1:length(x)
        epdf(i)=sum(pi>=x(i)-step/2 & pi<x(i)+step/2)/length(pi);
    end

%     plot(x,gg/sum(gg),x,epdf/sum(epdf));
%     legend({'GG','EPDF'},'location','northeast');
%     xlim([0,40]);
    
    mse(ii)=mean( (gg'/sum(gg)-epdf/sum(epdf)).^2);
    cc(ii)=corr(gg'/sum(gg),epdf/sum(epdf),'type','Pearson');
%     frame = getframe(h);
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%     % Write to the GIF File
%     if ii == 1
%         imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
%     else
%         imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',1);
%     end
end