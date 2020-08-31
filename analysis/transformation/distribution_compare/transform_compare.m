clc;clear;close all

load('/Users/localuser/Research/EMDNA/stndata_aftercheck.mat','prcp_stn')
nstn=size(prcp_stn,1);

bc_param=nan*zeros(nstn,1);
s10_param=nan*zeros(nstn,1);

for i=1:nstn
    fprintf('%d\n',i);
    pi=prcp_stn(i,:);
    pi(isnan(pi)|pi<0.1)=[];
    if length(pi)>1000
        [pi_bc,lambda]=boxcox(pi');
        bc_param(i)=lambda;

        b=-5:0.01:5;
        p_10=nan*zeros(length(b),1);
        for j=1:length(b)
            pi_10=b(j)*log(pi+1)+log(pi);
            [h,p_10(j)]= kstest((pi_10-mean(pi_10))/std(pi_10));
        end
        s10_param(i)=b(p_10==max(p_10));
    end
end

% fun_bc=@(x) (pi.^x-1)/x;
% fun_s10=@(x) x*log(pi+1)+log(pi);