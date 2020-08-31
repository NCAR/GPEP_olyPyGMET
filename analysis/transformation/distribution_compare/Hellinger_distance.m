% clc;clear;close all
% 
% load('/Users/localuser/Research/EMDNA/stndata_aftercheck.mat','prcp_stn','stninfo')
% nstn=size(prcp_stn,1);

param_wbl=load('weibull_stn_param.mat','a','b');
param_gg=load('gg_rea_param.mat','beta', 'c1', 'c2');
param_ll=load('lognormal_stn_param.mat','param_mean','param_std');

step=0.5;
x=0.25:step:40;

helldist=nan*zeros(nstn,2);
for i=1:nstn
    pi=prcp_stn(i,:);
    pi=pi(pi>=0.1);
    
    if length(pi)>1000
        epdf=zeros(1,length(x));
        for j=1:length(x)
            epdf(j)=sum(pi>=x(j)-step/2 & pi<x(j)+step/2)/length(pi);
        end
        epdf=epdf/sum(epdf);
        
        wbl_pdf = wblpdf(x,param_wbl.a(i),param_wbl.b(i));
        wbl_pdf = wbl_pdf/sum(wbl_pdf);
        
        gg_pdf=param_gg.c2(i)/param_gg.beta(i)/gamma(param_gg.c1(i)/param_gg.c2(i))*...
            ((x/param_gg.beta(i)).^(param_gg.c1(i)-1)).*(exp(-(x/param_gg.beta(i)).^param_gg.c2(i)));
        gg_pdf=gg_pdf/sum(gg_pdf);
        
        ll_pdf = lognpdf(x,param_ll.param_mean(i),param_ll.param_std(i));
        ll_pdf = ll_pdf/sum(ll_pdf);
        
        
        helldist(i,1)=0.5*sum((epdf.^0.5-wbl_pdf.^0.5).^2*step);
        helldist(i,2)=0.5*sum((epdf.^0.5-gg_pdf.^0.5).^2*step);
        helldist(i,3)=0.5*sum((epdf.^0.5-ll_pdf.^0.5).^2*step);      
        
%         close
%         plot(x,epdf,'-*k',x,wbl_pdf,'-r',x,gg_pdf,'-b',x,ll_pdf,'-g');
%         legend({'EPDF','WBL_PDF','GG_PDF','LL_PDF'});
    end
end

subplot(1,3,1)
histogram(helldist(:,1))
title('Weibull distance')
subplot(1,3,2)
histogram(helldist(:,1)-helldist(:,2))
title('Weibull minus GG')
subplot(1,3,3)
histogram(helldist(:,1)-helldist(:,3))
title('Weibull minus Lognormal')



