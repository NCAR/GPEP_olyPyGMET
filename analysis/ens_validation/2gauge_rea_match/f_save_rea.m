function f_save_rea(gridfile,prcp,tmean,ID,LLE,rowg,colg,date,BasicInfo,DEM_rea)
if exist(gridfile,'file')
    delete(gridfile);
end

days=length(date);
gnum=length(ID);
if iscell(ID)
    IDstr=cell2mat(ID);
else
    IDstr=ID;
end
rowcolele=[rowg,colg,DEM_rea];

prcp(isnan(prcp))=-999;
nccreate(gridfile,'prcp','Datatype','single',...
    'Dimensions',{'days',days,'gnum',gnum},...
    'Format','netcdf4','DeflateLevel',9,'FillValue',-999);
ncwrite(gridfile,'prcp',prcp);
ncwriteatt(gridfile,'prcp','description','reanalysis data matched with gauges');
ncwriteatt(gridfile,'prcp','row','date');
ncwriteatt(gridfile,'prcp','col','corresponding to each gauge in ID');
ncwriteatt(gridfile,'prcp','unit','mm/d');

tmean(isnan(tmean))=-999;
nccreate(gridfile,'tmean','Datatype','single',...
    'Dimensions',{'days',days,'gnum',gnum},...
    'Format','netcdf4','DeflateLevel',9,'FillValue',-999);
ncwrite(gridfile,'tmean',tmean);
ncwriteatt(gridfile,'tmean','description','reanalysis data matched with gauges');
ncwriteatt(gridfile,'tmean','row','date');
ncwriteatt(gridfile,'tmean','col','corresponding to each gauge in ID');
ncwriteatt(gridfile,'tmean','unit','C');

nccreate(gridfile,'date','Datatype','double',...
    'Dimensions',{'days',days},...
    'Format','netcdf4','DeflateLevel',9,'FillValue',-999);
ncwrite(gridfile,'date',date);
ncwriteatt(gridfile,'date','description','yyyymmdd');

nccreate(gridfile,'ID','Datatype','char',...
    'Dimensions',{'gnum',gnum,'dimID',size(IDstr,2)},...
    'Format','netcdf4','DeflateLevel',9);
ncwrite(gridfile,'ID',IDstr);

nccreate(gridfile,'LLE','Datatype','double',...
    'Dimensions',{'gnum',gnum,'dimLLE',size(LLE,2)},...
    'Format','netcdf4','DeflateLevel',9,'FillValue',-999);
ncwrite(gridfile,'LLE',LLE);
ncwriteatt(gridfile,'LLE','description','lat lon elev');

nccreate(gridfile,'rowcolele','Datatype','double',...
    'Dimensions',{'gnum',gnum,'dimRCE',size(rowcolele,2)},...
    'Format','netcdf4','DeflateLevel',9,'FillValue',-999);
ncwrite(gridfile,'rowcolele',rowcolele);
ncwriteatt(gridfile,'rowcolele','description','row col elevation of reanalysis grids');

nccreate(gridfile,'BasicInfo','Datatype','double',...
    'Dimensions',{'dimBI',length(BasicInfo)},...
    'Format','netcdf4','DeflateLevel',9,'FillValue',-999);
ncwrite(gridfile,'BasicInfo',BasicInfo);
ncwriteatt(gridfile,'BasicInfo','description','Xll,Yll,tXll,tYll,cellsize');
end