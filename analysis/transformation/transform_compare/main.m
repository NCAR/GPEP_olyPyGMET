clc;clear;close all
load('/Users/localuser/Research/EMDNA/stndata_aftercheck.mat','prcp_stn')
nstn=size(prcp_stn,1);
param_bc=nan*zeros(nstn,2);
param_s9=nan*zeros(nstn,2);
for i=1:nstn
    fprintf('%d\n',i);
    pi=prcp_stn(i,:);
    pi(isnan(pi)|pi<=0.1)=[];
    if length(pi)>500
        [x,fval]=f_bc_optimize(pi);
        param_bc(i,1)=x;
        param_bc(i,2)=fval;
        
        [x,fval]=f_s9_optimize(pi);
        param_s9(i,1)=x;
        param_s9(i,2)=fval;
        
        % plot test
        %         pp=pi;
        %         trans_bc=@(x) (pp.^x-1)/x;
        %         trans_s9=@(x) (pp+1).^x+log(pp);
        %         subplot(1,2,1)
        %         histogram(trans_bc(param_bc(i,1)),40);
        %         subplot(1,2,2)
        %         histogram(trans_s9(param_s9(i,1)),40);
    end
end

save parameter.mat param_s9 param_bc


% plot test
for i=1:100:nstn
    pi=prcp_stn(i,:);
    pi(isnan(pi)|pi<=0.1)=[];
    pp=pi;
    trans_bc=@(x) (pp.^x-1)/x;
    trans_s9=@(x) (pp+1).^x+log(pp);
    subplot(1,3,1)
    histogram(pp,40);
    title('Raw');
    subplot(1,3,2)
    histogram(trans_bc(param_bc(i,1)),40);
    title('Box-Cox');
    subplot(1,3,3)
    histogram(trans_s9(param_s9(i,1)),40);
    title('S9');
    pause
end

subplot(1,2,1)
histogram(param_bc(:,1),40)
title('Box-Cox parameter');
subplot(1,2,2)
histogram(param_s9(:,1),40)
title('Simon-9 parameter');






