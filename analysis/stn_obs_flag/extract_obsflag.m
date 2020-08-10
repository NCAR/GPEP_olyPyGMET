% extract obs flag of the station data
clc;clear;close all
file1='/Users/localuser/Research/EMDNA/stndata_aftercheck.mat';
file2='/Users/localuser/Research/GapFill/SCD_NorthAmerica.nc4';
outfile='/Users/localuser/Research/EMDNA/stndata_aftercheck_obsflag.mat';


load(file1,'stnID')
stnID=num2cell(stnID,2);

IDall=ncread(file2,'ID');
IDall=num2cell(IDall,2);

[ind1,ind2]=ismember(stnID,IDall);
ind2(ind2==0)=[];

prcp_flag=zeros(length(stnID),14610);
prcp_flag0=ncread(file2,'prcp_flag');
prcp_flag0=prcp_flag0';
prcp_flag(ind1,:)=prcp_flag0(ind2,:);

tmin_flag=zeros(length(stnID),14610);
tmin_flag0=ncread(file2,'tmin_flag');
tmin_flag0=tmin_flag0';
tmin_flag(ind1,:)=tmin_flag0(ind2,:);

tmax_flag=zeros(length(stnID),14610);
tmax_flag0=ncread(file2,'tmax_flag');
tmax_flag0=tmax_flag0';
tmax_flag(ind1,:)=tmax_flag0(ind2,:);

temp_flag=tmax_flag*0;
temp_flag(tmin_flag==1 & tmax_flag==1)=1;

save(outfile,'prcp_flag','temp_flag','stnID','-v7.3');