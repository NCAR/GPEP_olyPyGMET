clc;clear;close all

% Evaluation preparation
datafile='oi_evaluation.mat';
if exist(datafile,'file')
    load(datafile);
else
    filestn='/Users/localuser/Research/EMDNA/stndata_aftercheck.mat';
    load(filestn,'prcp_stn','tmean_stn','trange_stn','stninfo');
    lle=stninfo(:,2:4);
    nstn=size(lle,1);
    
    file_oi='/Users/localuser/Research/EMDNA/OImerge_stn_GWRLSBMA_prcp.mat';
    load(file_oi,'oimerge_stn');
    met_prcp_oi=nan*zeros(nstn,16);
    for g=1:nstn
        if ~isnan(prcp_stn(g,1))
            metg=f_metric_cal(prcp_stn(g,:)',oimerge_stn(g,:)',1);
            met_prcp_oi(g,:)=metg;
        end
    end
    
    file_oi='/Users/localuser/Research/EMDNA/OImerge_stn_GWRLSBMA_tmean.mat';
    load(file_oi,'oimerge_stn');
    met_tmean_oi=nan*zeros(nstn,16);
    for g=1:nstn
        if ~isnan(tmean_stn(g,1))
            metg=f_metric_cal(tmean_stn(g,:)',oimerge_stn(g,:)',1);
            met_tmean_oi(g,:)=metg;
        end
    end
    
    file_oi='/Users/localuser/Research/EMDNA/OImerge_stn_GWRLSBMA_trange.mat';
    load(file_oi,'oimerge_stn');
    met_trange_oi=nan*zeros(nstn,16);
    for g=1:nstn
        if ~isnan(trange_stn(g,1))
            metg=f_metric_cal(trange_stn(g,:)',oimerge_stn(g,:)',1);
            met_trange_oi(g,:)=metg;
        end
    end
    save(datafile,'met_prcp_oi','met_trange_oi','met_tmean_oi','lle');
end


% Evaluation preparation
datafile='reg_evaluation.mat';
if exist(datafile,'file')
    load(datafile);
else
    filestn='/Users/localuser/Research/EMDNA/stndata_aftercheck.mat';
    load(filestn,'prcp_stn','tmean_stn','trange_stn','stninfo');
    lle=stninfo(:,2:4);
    nstn=size(lle,1);
    
    file_reg='/Users/localuser/Research/EMDNA/regression_stn.mat';
    load(file_reg,'prcp','tmean','trange');
    
    met_prcp_reg=nan*zeros(nstn,16);
    met_tmean_reg=nan*zeros(nstn,16);
    met_trange_reg=nan*zeros(nstn,16);
    for g=1:nstn
        if ~isnan(prcp_stn(g,1))
            metg=f_metric_cal(prcp_stn(g,:)',prcp(g,:)',1);
            met_prcp_reg(g,:)=metg;
            metg=f_metric_cal(tmean_stn(g,:)',tmean(g,:)',1);
            met_tmean_reg(g,:)=metg;
            metg=f_metric_cal(trange_stn(g,:)',trange(g,:)',1);
            met_trange_reg(g,:)=metg;
        end
    end
    save(datafile,'met_prcp_reg','met_trange_reg','met_tmean_reg','lle');
end


