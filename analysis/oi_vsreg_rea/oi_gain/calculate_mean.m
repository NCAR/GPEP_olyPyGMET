clc;clear
fileflag='/Users/localuser/Research/EMDNA/stndata_aftercheck_obsflag.mat';
load(fileflag,'prcp_flag','temp_flag');
flag=cell(3,1);
flag{1}=prcp_flag;
flag{2}=temp_flag;
flag{3}=temp_flag;
clear prcp_flag temp_flag

file={'/Users/localuser/Research/EMDNA/OImerge_stn_GWRLSBMA_prcp.mat',...
    '/Users/localuser/Research/EMDNA/OImerge_stn_GWRLSBMA_tmean.mat',...
    '/Users/localuser/Research/EMDNA/OImerge_stn_GWRLSBMA_trange.mat'};
mean_oi=[];
for i=1:3
    load(file{i},'oimerge_stn');
    oimerge_stn(flag{i}~=1)=nan;
    mv=nanmean(oimerge_stn,2);
    mean_oi(:,i)=mv;
end

file={'/Users/localuser/Research/EMDNA/mergecorr_stn_prcp_GWRLS_BMA.mat',...
    '/Users/localuser/Research/EMDNA/mergecorr_stn_tmean_GWRLS_BMA.mat',...
    '/Users/localuser/Research/EMDNA/mergecorr_stn_trange_GWRLS_BMA.mat'};
mean_bma=[];
for i=1:3
    load(file{i},'reamerge_stn');
    reamerge_stn(flag{i}~=1)=nan;
    mean_bma(:,i)=nanmean(reamerge_stn,2);
end

file='/Users/localuser/Research/EMDNA/regression_stn.mat';
load(file,'prcp', 'tmean','trange');
mean_reg=[];
data=cell(3,1);
data{1}=prcp;
data{2}=tmean;
data{3}=trange;
for i=1:3
    data{i}(flag{i}~=1)=nan;
    mv=nanmean(data{i},2);
    mean_reg(:,i)=mv;
end

file='/Users/localuser/Research/EMDNA/stndata_aftercheck.mat';
load(file,'prcp_stn', 'tmean_stn','trange_stn');
mean_stn=[];
data=cell(3,1);
data{1}=prcp;
data{2}=tmean;
data{3}=trange;
for i=1:3
    data{i}(flag{i}~=1)=nan;
    mv=nanmean(data{i},2);
    mean_stn(:,i)=mv;
end

save('mean_value.mat','mean_oi','mean_reg','mean_bma','mean_stn');


