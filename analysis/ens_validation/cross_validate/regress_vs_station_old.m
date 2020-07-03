% compare daily regression with actual station data in testing grids to
% make sure that daily regression can be used to evaluate ensemble
% estimates
clc;clear;close all
cvnum=1:1; % 10-fold cross-validation
PathInfo='/home/gut428/EMDNA/2GMET_file'; % the path of station information for each cross-validation batch
PathAll='/home/gut428/GMET/eCAI_EMDNA/output/NA_reg_ens'; % the path of estimates that are based on all stations
PathStn='/home/gut428/GMET/StnInput_daily';
PathCross0='/home/gut428/GMET/eCAI_EMDNA'; % parent path of cross validation outputs
FileGridInfo='/home/gut428/GMET/eCAI_EMDNA/StnGridInfo/gridinfo_whole.nc';
name_mode='daily'; % anom or daily ensembles

year=2018:2018;
month=3:3;

% dateall
date=datenum(1979,1,1):datenum(2018,12,31);
date=datestr(date,'yyyymm');
date=num2cell(date,2);
date=str2double(date);
ym=zeros(length(year)*length(month),1);
flag=1;
for i=1:length(year)
    for j=1:length(month)
       ym(flag)=year(i)*100+month(j); 
    end
end
indexdate=ismember(date,ym);
ndays=sum(indexdate);
% basic information
lat2D=ncread(FileGridInfo,'latitude');
lon2D=ncread(FileGridInfo,'longitude');
DEM=ncread(FileGridInfo,'elev');
mask=isnan(DEM);
lat1D=lat2D(1,:)';
lon1D=lon2D(:,1);
cellsize=lat1D(2)-lat1D(1);

for cv=1:length(cvnum)
    cvv=cvnum(cv);
    PathCross=[PathCross0,'/CV_output_',num2str(cvv),'/NA_reg_ens'];
    PathResult=[PathCross0,'/CV_output_',num2str(cvv),'/RegressEvaluation'];
    if ~exist(PathResult,'dir'); mkdir(PathResult); end
    yearstr=[num2str(year(1)),'-',num2str(year(end))];
    
    OutfileStnInfo=[PathResult,'/StnInfo.mat'];
    OutfileStnData=[PathResult,'/StnData_',yearstr,'.mat'];
    OutfileRegData=[PathResult,'/RegressionData_',yearstr,'.mat'];
    OutfileEvaluate=[PathResult,'/RegEvaluation_',name_mode,'_',yearstr,'.mat'];
    
    % read training and testing station information
    fprintf('Reading station information\n');
    if exist(OutfileStnInfo,'file')
        load(OutfileStnInfo,'rowTest','colTest','indexTest','rowTrain','colTrain','indexTrain');
    else
        StnInfofile=[PathInfo,'/StnInfo_CrossValidate_',num2str(cvv),'.mat'];
        load(StnInfofile,'StnInfo','StnInfoTest','StnInfoAll','testIDNum','trainIDNum','description');
        rowTest=floor( (StnInfoTest.lle(:,2)-(lon1D(1)-cellsize/2))/cellsize )+1;
        colTest=floor( (StnInfoTest.lle(:,1)-(lat1D(1)-cellsize/2))/cellsize )+1;
        indexTest=sub2ind([length(lon1D),length(lat1D)],rowTest,colTest);
        
        rowTrain=floor( (StnInfo.lle(:,2)-lon1D(1))/cellsize )+1;
        colTrain=floor( (StnInfo.lle(:,1)-lat1D(1))/cellsize )+1;
        indexTrain=sub2ind([length(lon1D),length(lat1D)],rowTrain,colTrain);
        
        save(OutfileStnInfo,'rowTest','StnInfoTest','colTest','indexTest','rowTrain','colTrain','indexTrain');
    end
    indexTest2=setdiff(indexTest,indexTrain); % difference and unique
    numTest= length(indexTest2);
    
    % read station data for these test grids
    fprintf('Reading station data\n');
    if exist(OutfileStnData,'file') && overwrite~=1
        load(OutfileStnData,'dataStn');
    else
        dataStn=cell(3,1); % [days,stations]
        dataStn(:)={nan*zeros(ndays,numTest)};
        for gg=1:length(indexTest2)
            IDg=StnInfoTest.ID(indexTest==indexTest2(gg));
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
        save(OutfileStnData,'dataStn','-v7.3');
    end
    
    % read validation data from daily regression
    fprintf('Reading regression data\n');
    if exist(OutfileRegData,'file') && overwrite~=1
        load(OutfileRegData,'dataRef');
    else
        dataReg=cell(3,1); % [days,stations]
        for yy=1:length(year)
            for mm=1:length(month)
                fprintf('%d--%d\n',year(yy),month(mm));
                fileym=[PathAll,'/',num2str(year(yy)),'/regress_daily_',num2str(year(yy)*100+month(mm)),'.nc'];
                var=cell(3,1);
                pop=ncread(fileym,'pop');
                var{1}=ncread(fileym,'pcp');
                var{2}=ncread(fileym,'tmean');
                var{3}=ncread(fileym,'trange');
                
                % prcp: reverse box-cox transformation and pop criteria
                var{1}=(var{1}/4+1).^4;
                var{1}(var{1}<0.01)=0.01;
                var{1}(pop<0.5)=0;
                
                days=size(var{1},3);
                datavalidym=cell(3,1);
                datavalidym(:)={single(zeros(days,numTest))};
                for vv=1:3
                    for dd=1:days
                        temp=var{vv}(:,:,dd);
                        temp(mask)=nan;
                        datavalidym{vv}(dd,:)=temp(indexTest2);
                    end
                end
                for vv=1:3
                    dataReg{vv}=cat(1,dataReg{vv},datavalidym{vv});
                end
            end
        end
        save(OutfileRegData,'dataReg','-v7.3');
    end
    
    % read daily_anom or daily regression estimates
    
    
    % evaluation
    fprintf('Start evaluation\n');
    if ~exist(OutfileEvaluate,'file') || overwrite==1
        
        metric=cell(3,1);
        metric(:)={single(zeros(numTest,15))};
        for vv=1:3
            if vv==1; index2flag=1; else; index2flag=0; end  
                for nn=1:numTest
                    dref=dataStn{vv}(:,nn);
                    dtar=dataReg{vv}(:,nn);
                    [metricvn,metname]=f_metric_cal(dref,dtar,index2flag);
                    metric{vv}(nn,:)=metricvn;
                end
        end
        save(OutfileEvaluate,'metric','indexTest','DEM','lat2D','lon2D','metname','-v7.3');
    end
end
