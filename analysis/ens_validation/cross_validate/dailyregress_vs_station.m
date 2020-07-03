clc;clear;close all
FileGrid='/home/gut428/GMET/eCAI_EMDNA/StnGridInfo/gridinfo_whole.nc';
FileStn='/home/gut428/EMDNA/1StationInput/StnInfo.mat';
PathReg='/home/gut428/GMET/eCAI_EMDNA/output/NA_reg_ens';
PathStn='/home/gut428/GMET/StnInput_daily';

OutfileStnData='/home/gut428/GMET/eCAI_EMDNA/output/NA_reg_ens/DailyRegression_VS_Stn_2018/StnData.mat';
OutfileRegData='/home/gut428/GMET/eCAI_EMDNA/output/NA_reg_ens/DailyRegression_VS_Stn_2018/RegressionData.mat';
OutfileEvaluate='/home/gut428/GMET/eCAI_EMDNA/output/NA_reg_ens/DailyRegression_VS_Stn_2018/RegEvaluation.mat';

year=2018:2018;
month=1:12;


date=datenum(1979,1,1):datenum(2018,12,31);
date=datestr(date,'yyyymm');
date=num2cell(date,2);
date=str2double(date);
ym=zeros(length(year)*length(month),1);
flag=1;
for i=1:length(year)
    for j=1:length(month)
        ym(flag)=year(i)*100+month(j);
        flag=flag+1;
    end
end
indexdate=ismember(date,ym);
ndays=sum(indexdate);

% basic information
lat2D=ncread(FileGrid,'latitude');
lon2D=ncread(FileGrid,'longitude');
DEM=ncread(FileGrid,'elev');
mask=isnan(DEM);
lat1D=lat2D(1,:)';
lon1D=lon2D(:,1);
cellsize=lat1D(2)-lat1D(1);

% station information
fprintf('Reading station information\n');

load(FileStn,'StnInfo');
rowStn=floor( (StnInfo.lle(:,2)-(lon1D(1)-cellsize/2))/cellsize )+1;
colStn=floor( (StnInfo.lle(:,1)-(lat1D(1)-cellsize/2))/cellsize )+1;
indexStn=sub2ind([length(lon1D),length(lat1D)],rowStn,colStn);
indexStnu=unique(indexStn);
numGrid=length(indexStnu);

% read station data for these test grids
fprintf('Reading station data\n');
if exist(OutfileStnData,'file')
    load(OutfileStnData,'dataStn');
else
    dataStn=cell(3,1); % [days,stations]
    dataStn(:)={nan*zeros(ndays,numGrid)};
    for gg=1:numGrid
        fprintf('%d\n',gg);
        IDg=StnInfo.ID(indexStn==indexStnu(gg));
        datagg=cell(3,1);
        for ggi=1:length(IDg)
            filegi=[PathStn,'/',IDg{ggi},'.nc'];
            try
                temp=ncread(filegi,'prcp');
                datagg{1}=cat(2,datagg{1},temp(indexdate));
            catch
            end
            try
                temp=ncread(filegi,'tmin');
                datagg{2}=cat(2,datagg{2},temp(indexdate));
            catch
            end
            try
                temp=ncread(filegi,'tmax');
                datagg{3}=cat(2,datagg{3},temp(indexdate));
            catch
            end
        end
        for i=1:3
            if isempty(datagg{i})
                datagg{i}=nan*zeros(ndays,1);
            elseif size(datagg{i},2)>1
                datagg{i}=nanmean(datagg{i},2);
            end
        end
        
        temp1=(datagg{2}+datagg{3})/2;
        temp2=(datagg{3}-datagg{2});
        datagg{2}=temp1;
        datagg{3}=temp2;
        
        for i=1:3
            dataStn{i}(:,gg)=datagg{i};
        end
    end
    save(OutfileStnData,'dataStn','rowStn','colStn','indexStn','indexStnu','StnInfo','-v7.3');
end


% read regression data
fprintf('Reading regression data\n');
if exist(OutfileRegData,'file')
    load(OutfileRegData,'dataReg');
else
    dataReg=cell(3,1); % [days,stations]
    for yy=1:length(year)
        for mm=1:length(month)
            fprintf('%d--%d\n',year(yy),month(mm));
            fileym=[PathReg,'/',num2str(year(yy)),'/regress_daily_',num2str(year(yy)*100+month(mm)),'.nc'];
            var=cell(3,1);
            pop=ncread(fileym,'pop');
            var{1}=ncread(fileym,'pcp');
            var{2}=ncread(fileym,'tmean');
            var{3}=ncread(fileym,'trange');
            
            % prcp: reverse box-cox transformation and pop criteria
            var{1}=(var{1}/4+1).^4;
            var{1}(var{1}<0.01)=0.01;
%             var{1}(pop<0.5)=0;
            
            days=size(var{1},3);
            datavalidym=cell(3,1);
            datavalidym(:)={single(zeros(days,numGrid))};
            for vv=1:3
                for dd=1:days
                    temp=var{vv}(:,:,dd);
                    temp(mask)=nan;
                    datavalidym{vv}(dd,:)=temp(indexStnu);
                end
            end
            for vv=1:3
                dataReg{vv}=cat(1,dataReg{vv},datavalidym{vv});
            end
        end
    end
    save(OutfileRegData,'dataReg','-v7.3');
end


% evaluation
fprintf('Start evaluation\n');
if ~exist(OutfileEvaluate,'file')
    metric=cell(3,1);
    metric(:)={single(zeros(numGrid,15))};
    for vv=1:3
        if vv==1; index2flag=1; else; index2flag=0; end
        for nn=1:numGrid
            dref=dataStn{vv}(:,nn);
            dtar=dataReg{vv}(:,nn);
            [metricvn,metname]=f_metric_cal(dref,dtar,index2flag);
            metric{vv}(nn,:)=metricvn;
        end
    end
    save(OutfileEvaluate,'metric','lat2D','lon2D','metname','-v7.3');
end