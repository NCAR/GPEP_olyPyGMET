clc;clear;close all
% extract validation station data and the matched ensemble estimates
Infile_gauge='/home/gut428/GMET/StnValidation.nc4';
% Inpath_ensemble='/datastore/GLOBALWATER/CommonData/EMDNA';
Inpath_ensemble='/datastore/GLOBALWATER/CommonData/EMDNA_new/EMDNA_ens3';
Outpath='/home/gut428/GMET/EMDNA_ens_evaluation';
varall={'prcp','tmean','trange'}; % station vars
YEAR=2016:2016;
leastnum=[200,200,200]; % the least number of gauge samples so that the gauge will be included in evaluation
EnsNum=[1,100];
Info.latrange=[5,85]; % this must be consistent with ensemble estimates
Info.lonrange=[-180,-50];
Info.cellsize=0.1;
sufffix='_scale1.5';

% read data and save
varnum=length(varall);
for vv=1:varnum
    varvv=varall{vv};
    fprintf('Processing station %s\n',varvv);
    leastnumvv=leastnum(vv);
    Outfile_stn=[Outpath,'/stn_',varvv,sufffix,'.mat'];
    if ~exist(Outfile_stn,'file')
        f_gauge_data(Infile_gauge,Outfile_stn,varvv,leastnumvv,YEAR,Info);
    end

    fprintf('Processing ensemble %s\n',varvv);
    Outfile_ens=[Outpath,'/ens_',varvv,sufffix,'.mat'];
    if ~exist(Outfile_ens,'file')
        if strcmp(varvv,'prcp')
           varvv2='pcp'; 
        end
        if strcmp(varvv,'tmean')
           varvv2='t_mean'; 
        end
        if strcmp(varvv,'trange')
           varvv2='t_range'; 
        end
        f_ens_data(Inpath_ensemble,Outfile_ens,Outfile_stn,varvv2,YEAR,EnsNum);
    end
end



