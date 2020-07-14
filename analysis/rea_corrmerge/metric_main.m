clc;clear;close all

% Evaluation preparation
datafile='prcp_evaluation.mat';
if exist(datafile,'file')
    load(datafile);
else
    filestn='/Users/localuser/Research/EMDNA/stndata_aftercheck.mat';
    file_rearaw={'/Users/localuser/Research/EMDNA/ERA5_downto_stn_nearest.mat',...
        '/Users/localuser/Research/EMDNA/MERRA2_downto_stn_nearest.mat',...
        '/Users/localuser/Research/EMDNA/JRA55_downto_stn_nearest.mat'};
    file_readown={'/Users/localuser/Research/EMDNA/ERA5_downto_stn_GWR.mat',...
        '/Users/localuser/Research/EMDNA/MERRA2_downto_stn_GWR.mat',...
        '/Users/localuser/Research/EMDNA/JRA55_downto_stn_GWR.mat'};
    file_reacorr='/Users/localuser/Research/EMDNA/mergecorr_stn_prcp_GWRLS_BMA.mat';
    
    
    load(filestn,'prcp_stn','stninfo');
    lle=stninfo(:,2:4);
    nstn=size(lle,1);
    % evaluate raw reanalysis
    met_raw=nan*zeros(3,nstn,16);
    for i=1:3
        load(file_rearaw{i},'prcp_readown');
        for g=1:nstn
            if ~isnan(prcp_stn(g,1))
                metg=f_metric_cal(prcp_stn(g,:)',prcp_readown(g,:)',1);
                met_raw(i,g,:)=metg;
            end
        end
    end
    
    % evaluate downscaled reanalysis
    met_down=nan*zeros(3,nstn,16);
    for i=1:3
        load(file_readown{i},'prcp_readown');
        for g=1:nstn
            if ~isnan(prcp_stn(g,1))
                metg=f_metric_cal(prcp_stn(g,:)',prcp_readown(g,:)',1);
                met_down(i,g,:)=metg;
            end
        end
    end
    
    % evaluate corrected/merged data
    load(file_reacorr,'reacorr_stn1','reacorr_stn2','reacorr_stn3', 'reamerge_stn');
    met_corr=nan*zeros(3,nstn,16);
    met_merge=nan*zeros(nstn,16);
    for g=1:nstn
        if ~isnan(prcp_stn(g,1))
            metg=f_metric_cal(prcp_stn(g,:)',reacorr_stn1(g,:)',1);
            met_corr(1,g,:)=metg;
            metg=f_metric_cal(prcp_stn(g,:)',reacorr_stn2(g,:)',1);
            met_corr(2,g,:)=metg;
            metg=f_metric_cal(prcp_stn(g,:)',reacorr_stn3(g,:)',1);
            met_corr(3,g,:)=metg;
            metg=f_metric_cal(prcp_stn(g,:)',reamerge_stn(g,:)',1);
            met_merge(g,:)=metg;
        end
    end
    save(datafile,'met_merge','met_corr','met_raw','met_down','lle');
end


% Evaluation preparation
datafile='tmean_evaluation.mat';
if exist(datafile,'file')
    load(datafile);
else
    filestn='/Users/localuser/Research/EMDNA/stndata_aftercheck.mat';
    file_rearaw={'/Users/localuser/Research/EMDNA/ERA5_downto_stn_nearest.mat',...
        '/Users/localuser/Research/EMDNA/MERRA2_downto_stn_nearest.mat',...
        '/Users/localuser/Research/EMDNA/JRA55_downto_stn_nearest.mat'};
    file_readown={'/Users/localuser/Research/EMDNA/ERA5_downto_stn_GWR.mat',...
        '/Users/localuser/Research/EMDNA/MERRA2_downto_stn_GWR.mat',...
        '/Users/localuser/Research/EMDNA/JRA55_downto_stn_GWR.mat'};
    file_reacorr='/Users/localuser/Research/EMDNA/mergecorr_stn_tmean_GWRLS_BMA.mat';
    
    
    load(filestn,'tmean_stn','stninfo');
    lle=stninfo(:,2:4);
    nstn=size(lle,1);
    % evaluate raw reanalysis
    met_raw=nan*zeros(3,nstn,16);
    for i=1:3
        load(file_rearaw{i},'tmean_readown');
        for g=1:nstn
            if ~isnan(tmean_stn(g,1))
                metg=f_metric_cal(tmean_stn(g,:)',tmean_readown(g,:)',1);
                met_raw(i,g,:)=metg;
            end
        end
    end
    
    % evaluate downscaled reanalysis
    met_down=nan*zeros(3,nstn,16);
    for i=1:3
        load(file_readown{i},'tmean_readown');
        for g=1:nstn
            if ~isnan(tmean_stn(g,1))
                metg=f_metric_cal(tmean_stn(g,:)',tmean_readown(g,:)',1);
                met_down(i,g,:)=metg;
            end
        end
    end
    
    % evaluate corrected/merged data
    load(file_reacorr,'reacorr_stn1','reacorr_stn2','reacorr_stn3', 'reamerge_stn');
    met_corr=nan*zeros(3,nstn,16);
    met_merge=nan*zeros(nstn,16);
    for g=1:nstn
        if ~isnan(tmean_stn(g,1))
            metg=f_metric_cal(tmean_stn(g,:)',reacorr_stn1(g,:)',1);
            met_corr(1,g,:)=metg;
            metg=f_metric_cal(tmean_stn(g,:)',reacorr_stn2(g,:)',1);
            met_corr(2,g,:)=metg;
            metg=f_metric_cal(tmean_stn(g,:)',reacorr_stn3(g,:)',1);
            met_corr(3,g,:)=metg;
            metg=f_metric_cal(tmean_stn(g,:)',reamerge_stn(g,:)',1);
            met_merge(g,:)=metg;
        end
    end
    save(datafile,'met_merge','met_corr','met_raw','met_down','lle');
end

% Evaluation preparation
datafile='trange_evaluation.mat';
if exist(datafile,'file')
    load(datafile);
else
    filestn='/Users/localuser/Research/EMDNA/stndata_aftercheck.mat';
    file_rearaw={'/Users/localuser/Research/EMDNA/ERA5_downto_stn_nearest.mat',...
        '/Users/localuser/Research/EMDNA/MERRA2_downto_stn_nearest.mat',...
        '/Users/localuser/Research/EMDNA/JRA55_downto_stn_nearest.mat'};
    file_readown={'/Users/localuser/Research/EMDNA/ERA5_downto_stn_GWR.mat',...
        '/Users/localuser/Research/EMDNA/MERRA2_downto_stn_GWR.mat',...
        '/Users/localuser/Research/EMDNA/JRA55_downto_stn_GWR.mat'};
    file_reacorr='/Users/localuser/Research/EMDNA/mergecorr_stn_trange_GWRLS_BMA.mat';
    
    
    load(filestn,'trange_stn','stninfo');
    lle=stninfo(:,2:4);
    nstn=size(lle,1);
    % evaluate raw reanalysis
    met_raw=nan*zeros(3,nstn,16);
    for i=1:3
        load(file_rearaw{i},'trange_readown');
        for g=1:nstn
            if ~isnan(trange_stn(g,1))
                metg=f_metric_cal(trange_stn(g,:)',trange_readown(g,:)',1);
                met_raw(i,g,:)=metg;
            end
        end
    end
    
    % evaluate downscaled reanalysis
    met_down=nan*zeros(3,nstn,16);
    for i=1:3
        load(file_readown{i},'trange_readown');
        for g=1:nstn
            if ~isnan(trange_stn(g,1))
                metg=f_metric_cal(trange_stn(g,:)',trange_readown(g,:)',1);
                met_down(i,g,:)=metg;
            end
        end
    end
    
    % evaluate corrected/merged data
    load(file_reacorr,'reacorr_stn1','reacorr_stn2','reacorr_stn3', 'reamerge_stn');
    met_corr=nan*zeros(3,nstn,16);
    met_merge=nan*zeros(nstn,16);
    for g=1:nstn
        if ~isnan(trange_stn(g,1))
            metg=f_metric_cal(trange_stn(g,:)',reacorr_stn1(g,:)',1);
            met_corr(1,g,:)=metg;
            metg=f_metric_cal(trange_stn(g,:)',reacorr_stn2(g,:)',1);
            met_corr(2,g,:)=metg;
            metg=f_metric_cal(trange_stn(g,:)',reacorr_stn3(g,:)',1);
            met_corr(3,g,:)=metg;
            metg=f_metric_cal(trange_stn(g,:)',reamerge_stn(g,:)',1);
            met_merge(g,:)=metg;
        end
    end
    save(datafile,'met_merge','met_corr','met_raw','met_down','lle');
end
