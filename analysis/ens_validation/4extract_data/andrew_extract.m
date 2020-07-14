clc;clear;close all
% extract validation station data and the matched ensemble estimates
Infile_gauge='/home/gut428/GMET/StnValidation.nc4';
Inpath_ensemble='/home/gut428/Andrew_GMET';
Outpath='/home/gut428/GMET/EMDNA_ens_evaluation';
varall={'prcp','tmean','trange'}; % station vars
YEAR=2016:2016;
leastnum=[200,200,200]; % the least number of gauge samples so that the gauge will be included in evaluation
EnsNum=[1,100];
Info.latrange=[25.0625,53.0625]; % this must be consistent with ensemble estimates
Info.lonrange=[-124.9375, -66.937];
Info.cellsize=0.125;
sufffix='_andrew';

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
        f_ens_data_andrew(Inpath_ensemble,Outfile_ens,Outfile_stn,varvv,YEAR,EnsNum);
    end
end



