% calculate the metrics of ensemble estimates
clc;clear;close all
% Plato
Inpath='/home/gut428/GMET/EMDNA/Evaluation';
Outpath='/home/gut428/GMET/EMDNA/Evaluation';
% mac
% Inpath='/Users/localuser/GMET/results';

year=2016:2016;
vars={'prcp','tmean','trange'};
leastnum=[200,200,200]; % the least number of gauge samples so that the gauge will be included in evaluation
varnum=length(vars);
EnsNum=[1,20];
ensnum=EnsNum(2)-EnsNum(1)+1;
sufffix='_old';

for vv=1:varnum
    varvv=vars{vv};
    filestn=[Inpath,'/stn_',varvv,sufffix,'.mat'];
    fileens=[Inpath,'/ens_',varvv,sufffix,'.mat'];
    outfile=[Outpath,'/metric_',varvv,sufffix,'.mat'];
    if exist(outfile,'file')
        continue;
    end
    
    load(filestn,'data_stn','LLE');
    load(fileens,'data_ens','YEAR');
    % if YEAR is longer than year, trim the data
    date=datenum(YEAR(1),1,1):datenum(YEAR(end),12,31);
    date=datestr(date,'yyyy');
    date=mat2cell(date,ones(size(date,1),1),4);
    date=str2double(date);
    indin=ismember(date,year);
    data_stn=data_stn(indin,:);
    
    
    stnnum=size(data_stn,2);
    leastnumvv=leastnum(vv);
    
    metric=nan*zeros(stnnum,15,ensnum);
    metric4=cell(4,1);
    metric4(:)={nan*zeros(stnnum,15,ensnum)};
    flag=1;
    for ee=EnsNum(1):EnsNum(2)
        fprintf('vv %s--ee %d\n',varvv,ee);
        data_ensee=data_ens{ee}(indin,:);
        [metee,met4ee,metname]=f_metric(data_stn,data_ensee,leastnumvv,year);
        metric(:,:,flag)=metee;
        for ss=1:4  % four season
           metric4{ss}(:,:,flag)=met4ee{ss};
        end
        flag=flag+1;
    end
    save(outfile,'metric','metric4','metname','leastnum','-v7.3');
end

