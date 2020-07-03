% basic quality control of GHCN-D validate data and save them in one single
% file for the convenience of evaluation
Inpath='/home/gut428/GMET/StnValidation';
Infile_station=[Inpath,'/GaugeValid.mat']; 
Outfile='/home/gut428/GMET/StnValidation.nc4';
period=[1979,2018];
validratio=0.7;
leastnum=1000;

% load the basic information
load(Infile_station,'GaugeValid');
LLE=GaugeValid.lle;
ID=GaugeValid.ID;
gnum=length(ID);

% initialize data
daynum=datenum(period(end),12,31)-datenum(period(1),1,1)+1;
date=datenum(period(1),1,1):datenum(period(end),12,31);
date=datestr(date,'yyyymmdd');
date=mat2cell(date,ones(daynum,1),8);
date=str2double(date);

prcp=nan*zeros(daynum,gnum);
tmean=nan*zeros(daynum,gnum);
trange=nan*zeros(daynum,gnum);

% read gauge data
indout=zeros(gnum,1);
for gg=1:gnum
    fprintf('%d--%d\n',gg,gnum);
    infile=[Inpath,'/',ID{gg},'.mat'];
    load(infile,'data');
    dategg=data(:,1);
    data(:,1)=[];
    validnumg=sum(~isnan(data));
    validratiog=validnumg/length(dategg);
    indgg=validratiog>=validratio&validnumg>=leastnum;
    if sum(indgg)==0
       indout(gg)=1;
       continue;
    end
    data(:,~indgg)=nan;
    
    [ind1,ind2]=ismember(dategg,date);
    ind2(ind2==0)=[];
    
    prcp(ind2,gg)=data(ind1,1);
    tmean(ind2,gg)=mean(data(ind1,[2,3]),2);
    trange(ind2,gg)=abs(data(ind1,3)-data(ind1,2));   
end

indout=indout==1;
prcp(:,indout)=[];
tmean(:,indout)=[];
trange(:,indout)=[];
LLE(indout,:)=[];
ID(indout)=[];
gnum=length(ID);

nccreate(Outfile,'prcp','Datatype','single',...
'Dimensions',{'daynum',daynum,'gnum',gnum},...
'Format','netcdf4','DeflateLevel',9,'FillValue',-999);
ncwrite(Outfile,'prcp',prcp);

nccreate(Outfile,'tmean','Datatype','single',...
'Dimensions',{'daynum',daynum,'gnum',gnum},...
'Format','netcdf4','DeflateLevel',9,'FillValue',-999);
ncwrite(Outfile,'tmean',tmean);

nccreate(Outfile,'trange','Datatype','single',...
'Dimensions',{'daynum',daynum,'gnum',gnum},...
'Format','netcdf4','DeflateLevel',9,'FillValue',-999);
ncwrite(Outfile,'trange',trange);

nccreate(Outfile,'LLE','Datatype','single',...
'Dimensions',{'gnum',gnum,'lle',3},...
'Format','netcdf4','DeflateLevel',9,'FillValue',-999);
ncwrite(Outfile,'LLE',LLE);

nccreate(Outfile,'date','Datatype','double',...
'Dimensions',{'daynum',daynum},...
'Format','netcdf4','DeflateLevel',9,'FillValue',-999);
ncwrite(Outfile,'date',date);

IDstr=cell2mat(ID);
nccreate(Outfile,'ID','Datatype','char',...
'Dimensions',{'gnum',gnum,'str',11},...
'Format','netcdf4','DeflateLevel',9);
ncwrite(Outfile,'ID',IDstr);

