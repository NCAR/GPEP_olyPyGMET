kge=cell(3,1);
for vv=1:3
    for ee=1:8
        temp(:,1)=metric_daily{vv,ee}(:,12);
        temp(:,2)=metric_anom{vv,ee}(:,12);
        kge{vv}=cat(1,kge{vv},temp);
    end
end


file1='~/Downloads/ALL/regress_climo_201801.nc';
file2='~/Downloads/CV1/regress_climo_201801.nc';
trange1=ncread(file1,'trange');
trange2=ncread(file2,'trange');
diff=trange1-trange2;
diff(trange1==0)=[];

file1='~/Downloads/CV1/ensemble_anom_201801.001.nc';
file2='~/Downloads/CV1/regress_daily_201801.nc';
file3='~/Downloads/CV1/regress_climo_201801.nc';
file4='~/Downloads/CV1/regress_anom_201801.nc';
trange1=ncread(file1,'t_range');
trange2=ncread(file2,'trange');
% trange3=ncread(file3,'trange');
% trange4=ncread(file4,'trange');
% trange3=repmat(trange3,1,1,31);
% trange5=trange3+trange4;
% trange1=nanmean(trange1,3);
% trange2=nanmean(trange2,3);
diff=trange1-trange2;
diff(trange1==0)=[];
histogram(diff,-20:0.1:20)

file1='~/Downloads/CV1/regress_climo_201801.nc';
file2='~/Downloads/CV1/regress_anom_201801.nc';
trclimo=ncread(file1,'trange');
tranom=ncread(file2,'trange'); % anomly regression trange almost >0


file1='~/Downloads/GHCA006158667_daily.nc';
file2='~/Downloads/GHCA006158667_climo.nc';
file3='~/Downloads/GHCA006158667_anom.nc';
tmin1=ncread(file1,'tmin',14246,31);
tmin2=ncread(file2,'tmin',469,1);
tmin3=ncread(file3,'tmin',14246,31);
tmax1=ncread(file1,'tmax',14246,31);
tmax2=ncread(file2,'tmax',469,1);
tmax3=ncread(file3,'tmax',14246,31); % station anomaly trange ><0

file4='~/Downloads/GHUSC00303087.nc';
tmin4=ncread(file4,'tmin',14246,31);
tmax4=ncread(file4,'tmax',14246,31);


