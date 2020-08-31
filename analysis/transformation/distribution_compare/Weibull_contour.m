% clc;clear;close all
% load('/Users/localuser/Research/EMDNA/stndata_aftercheck.mat','prcp_stn','stninfo')
% nstn=size(prcp_stn,1);
a=0.1:0.1:25;
b=0.1:0.01:2;
for i=10000:10000
    pi=prcp_stn(i,:);
    pi=pi(pi>=0.1);
    
    if length(pi)>1000
        p_mean=mean(pi);
        p_std=std(pi);
        cs=skewness(pi);
        cv=p_std/p_mean;
        
        llike=nan*zeros(length(a),length(b));
        
        for i1=1:length(a)
            for i2=1:length(b)
                llike(i1,i2)=wbllike([a(i1),b(i2)],pi);
            end
        end
        parmHat = wblfit(double(pi));
    end
end

% step=0.5;
% x=step:step:40;
% ywbl = wblpdf(x,parmHat(1),parmHat(2));
% % ecdf
% epdf=zeros(length(x),1);
% for i=1:length(x)
%     epdf(i)=sum(pi>=x(i)-step/2 & pi<x(i)+step/2)/length(pi);
% end
% plot(x,ywbl/sum(ywbl),x,epdf/sum(epdf));
% legend({'WBL','EPDF'},'location','northeast');
% xlim([0,40]);

close
[B,A] = meshgrid(b,a);
contour(A,B,llike,0:1000:100000);
% contour(A,B,llike,16000:100:20000);
% caxis([16000,20000]);
% xlim([3,8])
% ylim([0.5,1.2]);
colormap('jet')
colorbar
xlabel('a');
ylabel('b');

