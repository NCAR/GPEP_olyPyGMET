% evaluate the regress estimates using cross-validation method
clc;clear;close all
cvnum=1:1; % 10-fold cross-validation
PathInfo='/home/gut428/EMDNA/2GMET_file'; % the path of station information for each cross-validation batch
PathAll='/home/gut428/GMET/eCAI_EMDNA/output/NA_reg_ens'; % the path of estimates that are based on all stations
PathCross0='/home/gut428/GMET/eCAI_EMDNA'; % parent path of cross validation outputs
FileGridInfo='/home/gut428/GMET/eCAI_EMDNA/StnGridInfo/gridinfo_whole.nc';

name_mode='anom'; % anom or daily ensembles

year=2018:2018;
month=[1,3:12];
overwrite=0; % 1: whenever the settings are changed, old files need to be overwritten

ensflag=0; %1: read ensemble instead of ensemble data
stnflag=1; %1: also use original station data to evaluate
ensemble=1:29;
nens=length(ensemble);

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
    PathResult=[PathCross0,'/CV_output_',num2str(cvv),'/DailyRegressEvaluation'];
    if ~exist(PathResult,'dir'); mkdir(PathResult); end
    yearstr=[num2str(year(1)),'-',num2str(year(end))];
    
    OutfileRefInfo=[PathResult,'/ReferenceInfo.mat'];
    OutfileRefData=[PathResult,'/ReferenceData_',yearstr,'.mat'];
    
    if ensflag==1
        OutfileTarData=[PathResult,'/TargetData_ensemble_',name_mode,'_',yearstr,'.mat'];
        OutfileEvaluate=[PathResult,'/Evaluation_ensemble_',name_mode,'_',yearstr,'.mat'];
        if stnflag==1
            OutfileStnEvaluate=[PathResult,'/StnEvaluation_ensemble_',name_mode,'_',yearstr,'.mat'];
        end
    else
        OutfileTarData=[PathResult,'/TargetData_regression_',name_mode,'_',yearstr,'.mat'];
        OutfileEvaluate=[PathResult,'/Evaluation_regression_',name_mode,'_',yearstr,'.mat'];
        if stnflag==1
            OutfileStnEvaluate=[PathResult,'/StnEvaluation_regression_',name_mode,'_',yearstr,'.mat'];
        end
    end
    
    
    
    % read training and testing station information
    fprintf('Reading station information\n');
    if exist(OutfileRefInfo,'file')
        load(OutfileRefInfo,'rowTest','colTest','indexTest','rowTrain','colTrain','indexTrain');
    else
        StnInfofile=[PathInfo,'/StnInfo_CrossValidate_',num2str(cvv),'.mat'];
        load(StnInfofile,'StnInfo','StnInfoTest','StnInfoAll','testIDNum','trainIDNum','description');
        rowTest=floor( (StnInfoTest.lle(:,2)-(lon1D(1)-cellsize/2))/cellsize )+1;
        colTest=floor( (StnInfoTest.lle(:,1)-(lat1D(1)-cellsize/2))/cellsize )+1;
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
%         if strcmp(name_mode,'anom')
%             for i=1:3
%                 dataRef{i}(32:59,:)=[];
%             end
%         end
    else
        dataRef=cell(3,1); % [days,stations]
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
%                 var{1}(pop<0.5)=0;
                
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
        save(OutfileRefData,'dataRef','indexTest','-v7.3');
    end
    
    % read daily_anom or daily regression estimates
    fprintf('Reading daily_anomaly or daily\n');
    if exist(OutfileTarData,'file') && overwrite~=1
        load(OutfileTarData,'dataTar');
    elseif ensflag~=1
        dataTar=cell(3,1); % [days,stations]
        for yy=1:length(year)
            PathCrossyy=[PathCross,'/',num2str(year(yy))];
            for mm=1:length(month)
                fprintf('%d--%d\n',year(yy),month(mm));
                if strcmp(name_mode,'daily')
                    fileyme=[PathCrossyy,'/regress_',name_mode,'_',num2str(year(yy)*100+month(mm)),'.nc'];
                    var=cell(3,1);
                    var{1}=ncread(fileyme,'pcp');
                    var{2}=ncread(fileyme,'tmean');
                    var{3}=ncread(fileyme,'trange');
                    
                    pop=ncread(fileyme,'pop');
                    var{1}=(var{1}/4+1).^4;
                    var{1}(var{1}<0.1)=0.1;
%                     var{1}(pop<0.5)=0;
                    
                    days=size(var{1},3);
                elseif strcmp(name_mode,'anom')
                    % read climatological mean data
                    fileclimo=[PathCrossyy,'/ENS_CLIMO_',num2str(mm,'%02d'),'.nc'];
                    varclimo=cell(3,1);
                    varclimo{1}=ncread(fileclimo,'pcp'); % actual precipitation, don't need recover
                    varclimo{2}=ncread(fileclimo,'t_mean');
                    varclimo{3}=ncread(fileclimo,'t_range');
                    
                    % read anomaly data
                    fileyme=[PathCrossyy,'/regress_',name_mode,'_',num2str(year(yy)*100+month(mm)),'.nc'];
                    var=cell(3,1);
                    var{1}=ncread(fileyme,'pcp');
                    var{2}=ncread(fileyme,'tmean');
                    var{3}=ncread(fileyme,'trange');
                    days=size(var{1},3);
                    pop=ncread(fileyme,'pop');
                    var{1}=(var{1}/3+1).^3;
                    
                    var{1}=var{1}.*repmat(varclimo{1},1,1,days);
                    var{2}=var{2}+repmat(varclimo{2},1,1,days);
                    var{3}=var{3}+repmat(varclimo{3},1,1,days);
                    
                    var{1}(var{1}<0.1)=0.1;
%                     var{1}(pop<0.5)=0;
                end
                
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
                    dataTar{vv}=cat(1,dataTar{vv},datavalidym{vv});
                end
            end
        end
        save(OutfileTarData,'dataTar','indexTest','-v7.3');
    elseif ensflag==1
        dataTar=cell(3,nens); % [days,stations]
        for yy=1:length(year)
            PathCrossyy=[PathCross,'/',num2str(year(yy))];
            for mm=1:length(month)
                for ee=1:nens
                    fprintf('%d--%d--%d\n',year(yy),month(mm),ensemble(ee));
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
        save(OutfileTarData,'dataTar','indexTest','-v7.3');
    end
    
    % evaluation
    fprintf('Start evaluation\n');
    if ~exist(OutfileEvaluate,'file') || overwrite==1
        if ensflag==1
            dataTar2=cell(3,1);
            dataTar2(:)={zeros(size(dataTar{1}))};
            for vv=1:3
                for ee=1:length(ensemble)
                    dataTar2{vv}=dataTar2{vv}+dataTar{vv,ee};
                end
                dataTar{vv,ee+1}=dataTar2{vv}/length(ensemble);
            end
            num2=length(ensemble)+1; % the last one is the mean of all ensembles
        else
            num2=1;
        end
        
        metric=cell(3,num2);
        metric(:)={single(zeros(numTest,15))};
        for vv=1:3
            if vv==1; index2flag=1; else; index2flag=0; end
            for ee=1:num2
                for nn=1:numTest
                    dref=dataRef{vv}(:,nn);
                    dtar=dataTar{vv,ee}(:,nn);
                    [metricvn,metname]=f_metric_cal(dref,dtar,index2flag);
                    metric{vv,ee}(nn,:)=metricvn;
                end
            end
        end
        save(OutfileEvaluate,'metric','indexTest','DEM','lat2D','lon2D','metname','-v7.3');
    end
    
    % station-based ensemble evalutation
    if stnflag==1
        file='/home/gut428/GMET/eCAI_EMDNA/output/NA_reg_ens/DailyRegression_VS_Stn_2018/StnData.mat';
        ddd=load(file);
        [ind1,ind2]=ismember(indexTest,ddd.indexStnu);
        for i=1:3
            dataRef{i}=ddd.dataStn{i}(:,ind2);
        end

        for i=1:3
            dataRef{i}(32:59,:)=[];
        end

        
        if ~exist(OutfileStnEvaluate,'file') || overwrite==1
            if ensflag==1
                dataTar2=cell(3,1);
                dataTar2(:)={zeros(size(dataTar{1}))};
                for vv=1:3
                    for ee=1:length(ensemble)
                        dataTar2{vv}=dataTar2{vv}+dataTar{vv,ee};
                    end
                    dataTar{vv,ee+1}=dataTar2{vv}/length(ensemble);
                end
                num2=length(ensemble)+1; % the last one is the mean of all ensembles
            else
                num2=1;
            end
            
            metric=cell(3,num2);
            metric(:)={single(zeros(numTest,15))};
            for vv=1:3
                if vv==1; index2flag=1; else; index2flag=0; end
                for ee=1:num2
                    for nn=1:numTest
                        dref=dataRef{vv}(:,nn);
                        dtar=dataTar{vv,ee}(:,nn);
                        [metricvn,metname]=f_metric_cal(dref,dtar,index2flag);
                        metric{vv,ee}(nn,:)=metricvn;
                    end
                end
            end
            save(OutfileStnEvaluate,'metric','indexTest','DEM','lat2D','lon2D','metname','-v7.3');
        end
        
    end
end
