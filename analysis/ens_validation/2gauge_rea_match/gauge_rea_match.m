% according to the locations of rain gauges, extract reanalysis
% precipitation
clc;clear;close all
% plato path
Infile_gauge='/home/gut428/GMET/DataInput/ghcn-d_validate/GHCND_Validation.nc4';
FileDEMHigh='/home/gut428/GMET/NA_basic/MERIT_DEM/NA_DEM_010deg_trim.asc';
Inpath_rea={'/datastore/GLOBALWATER/CommonData/Prcp_GMET/ERA5_YearNC',...
    '/datastore/GLOBALWATER/CommonData/Prcp_GMET/JRA55_YearNC',....
    '/datastore/GLOBALWATER/CommonData/Prcp_GMET/MERRA2_YearNC'};
Outpath='/home/gut428/GMET/DataInput/Gauge_Reanalysis2';

prefixall{1}={'ERA5_prcp_','ERA5_tmean_'};
prefixall{2}={'JRA55_prcp_','JRA55_tmean_'};
prefixall{3}={'MERRA2_prcp_','MERRA2_tmean_'};
Vars={'prcp','tmean'};
prefixout={'ERA5_validate','JRA55_validate','MERRA2_validate'};

years=1979;  % if the date is not complete, fill it using nan
yeare=2018;

%% basic information of date, study area, stations
date=datenum(years,1,1):datenum(yeare,12,31); date=date';
date=datestr(date,'yyyymmdd');
date=mat2cell(date,ones(length(date),1),8);
date=str2double(date);
% basic info of the study area and the extracted reanalysis data
DEMRea=arcgridread_tgq(FileDEMHigh);

tXll=DEMRea.xll2;  % top right
tYll=DEMRea.yll2;
Xll=DEMRea.xll;   % bottom left
Yll=DEMRea.yll;
cellsize=DEMRea.cellsize;
nrows=(tYll-Yll)/cellsize;
ncols=(tXll-Xll)/cellsize;
BasicInfo=[Xll,Yll,tXll,tYll,cellsize];

DEMRea=DEMRea.mask;

%% load gauge info
ID=ncread(Infile_gauge,'ID');
LLE=ncread(Infile_gauge,'LLE');
Gprcp=ncread(Infile_gauge,'prcp');
Gtmean=ncread(Infile_gauge,'tmean');
Gtrange=ncread(Infile_gauge,'trange');

rowg=floor((tYll-LLE(:,1))/cellsize)+1;
colg=floor((LLE(:,2)-Xll)/cellsize)+1;
indexg=sub2ind([nrows,ncols],rowg,colg);
DEM_rea=DEMRea(indexg);

%% get the matched data
for i=1:length(Inpath_rea)
    prefix=prefixall{i};
    Outfile=[Outpath,'/',prefixout{i},'.nc4'];
    if exist(Outfile,'file')
        continue;
    end
    for j=1:length(prefix)
        fprintf('%d--%s\n',i,prefix{j});
        varg=['G',Vars{j}];
        commj=[Vars{j},'=f_reanalysis_extract(Inpath_rea{i},prefix{j},rowg,colg,years,yeare,',varg,');'];
        eval(commj);
    end    
    f_save_rea(Outfile,prcp,tmean,ID,LLE,rowg,colg,date,BasicInfo,DEM_rea);
end
clear prcp tmin tmax tmean
