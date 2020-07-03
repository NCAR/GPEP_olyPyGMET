% evaluate the regress and ensemble estimates using cross-validation method
clc;clear;close all
cvnum=10; % 10-fold cross-validation
PathInfo='/home/gut428/EMDNA/2GMET_file'; % the path of station information for each cross-validation batch
PathAll='/home/gut428/GMET/eCAI_EMDNA/output/NA_reg_ens'; % the path of estimates that are based on all stations
PathCross0='/home/gut428/GMET/eCAI_EMDNA'; % parent path of cross validation outputs
FileGridInfo='/home/gut428/GMET/eCAI_EMDNA/StnGridInfo/gridinfo_whole.nc';
name_mode='daily'; % anom or daily ensembles

year=2018:2018;
month=1:12;
ensemble=1:8;
nens=length(ensemble);
overwrite=0; % 1: whenever the settings are changed, old files need to be overwritten

% basic information
lat2D=ncread(FileGridInfo,'latitude');
lon2D=ncread(FileGridInfo,'longitude');
DEM=ncread(FileGridInfo,'elev');
mask=isnan(DEM);
lat1D=lat2D(1,:)'; 
lon1D=lon2D(:,1);
cellsize=lat1D(2)-lat1D(1);

for cv=1:cvnum
    PathCross=[PathCross0,'/CV_output_',num2str(cv),'/NA_reg_ens'];
    PathResult=[PathCross0,'/CV_output_',num2str(cv),'/Evaluation'];
    if ~exist(PathResult,'dir'); mkdir(PathResult); end
    
    OutfileRefInfo=[PathResult,'/ReferenceInfo.mat'];
    OutfileRefData=[PathResult,'/ReferenceData.mat'];
    OutfileEnsData=[PathResult,'/EnsembleData.mat'];
    OutfileEvaluate=[PathResult,'/Evaluation.mat'];
    
    % read training and testing station information
    fprintf('Reading station information\n');
    if exist(OutfileRefInfo,'file')
        load(OutfileRefInfo,'rowTest','colTest','indexTest','rowTrain','colTrain','indexTrain');
    else
        StnInfofile=[PathInfo,'/StnInfo_CrossValidate_',num2str(cv),'.mat'];
        load(StnInfofile,'StnInfo','StnInfoTest','StnInfoAll','testIDNum','trainIDNum','description');
        rowTest=floor( (StnInfoTest.lle(:,2)-lon1D(1))/cellsize )+1;
        colTest=floor( (StnInfoTest.lle(:,1)-lat1D(1))/cellsize )+1;
        indexTest=sub2ind([length(lon1D),length(lat1D)],rowTest,colTest);

        rowTrain=floor( (StnInfo.lle(:,2)-lon1D(1))/cellsize )+1;
        colTrain=floor( (StnInfo.lle(:,1)-lat1D(1))/cellsize )+1;
        indexTrain=sub2ind([length(lon1D),length(lat1D)],rowTrain,colTrain);

        save(OutfileRefInfo,'rowTest','colTest','indexTest','rowTrain','colTrain','indexTrain');
    end
    indexTest=setdiff(indexTest,indexTrain);  
    numTest= length(indexTest);
    
    % read validation data from daily regression
    fprintf('Reading reference data\n');
    if exist(OutfileRefData,'file') && overwrite~=1
        load(OutfileRefData,'dataRef');
    else
        dataRef=cell(3,1); % [days,stations]
        for yy=1:length(year)
            for mm=1:length(month)
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
                        datavalidym{vv}(dd,:)=temp(indexTest);
                    end
                end
                for vv=1:3
                    dataRef{vv}=cat(1,dataRef{vv},datavalidym{vv});
                end
            end
        end
        save(OutfileRefData,'dataRef','-v7.3');
    end
    
    % read daily_anom ensemble estimates
    fprintf('Reading daily anomaly\n');
    if exist(OutfileEnsData,'file') && overwrite~=1
        load(OutfileEnsData,'dataTar');
    else
        dataTar=cell(3,nens); % [days,stations]
        for yy=1:length(year)
            PathCrossyy=[PathCross,'/',num2str(year(yy))];
            for mm=1:length(month)
                for ee=1:nens
                   fileyme=[PathCrossyy,'/ensemble_',name_mode,'_',num2str(year(yy)*100+month(mm)),'.',num2str(ensemble(ee),'%03d'),'.nc'];
                   var=cell(3,1);
                   var{1}=ncread(fileyme,'pcp');
                   var{2}=ncread(fileyme,'t_mean');
                   var{3}=ncread(fileyme,'t_range');
                   days=size(var{1},3);
                   datavalidyme=cell(3,1);
                   datavalidyme(:)={single(zeros(days,numTest))};

                   for vv=1:3
                       for dd=1:days
                           temp=var{vv}(:,:,dd); 
                           temp(mask)=nan;
                           datavalidyme{vv}(dd,:)=temp(indexTest);
                       end
                   end

                   for vv=1:3
                       dataTar{vv,ee}=cat(1,dataTar{vv,ee},datavalidyme{vv});
                   end
                end
            end
        end
        save(OutfileEnsData,'dataTar','-v7.3');
    end
    
    % evaluation
    fprintf('Start evaluation\n');
    if ~exist(OutfileEvaluate,'file') || overwrite~=1
        metric=cell(3,nens);
        metric(:)={single(zeros(numTest,15))};
        for vv=1:3
            
            if vv==1; index2flag=1; else; index2flag=0; end
            
            for ee=1:nens
                for nn=1:numTest
                    dref=dataRef{vv}(:,nn);
                    dtar=dataTar{vv,ee}(:,nn);
                    [metricven,metname]=f_metric_cal(dref,dtar,index2flag);
                    metric{vv,ee}(nn,:)=metricven;
                end
            end
        end
        save(OutfileEvaluate,'metric','indexTest','DEM','lat2D','lon2D','metname','-v7.3');
    end
end


