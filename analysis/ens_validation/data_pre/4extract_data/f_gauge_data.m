function f_gauge_data(Infile_gauge,Outfile_stn,var_stnvv,leastnumvv,YEAR,Info)
if exist(Outfile_stn,'file')
   return; 
end

LLE=ncread(Infile_gauge,'LLE');
data_stn=ncread(Infile_gauge,var_stnvv);
date=ncread(Infile_gauge,'date');
% date within years
yearg=floor(date/10000);
indy=yearg>=YEAR(1)&yearg<=YEAR(end);
data_stn=data_stn(indy,:);
date=date(indy);
% least number of samples
pnum=sum(~isnan(data_stn));
indp=pnum>=leastnumvv;
LLE=LLE(indp,:);
data_stn=data_stn(:,indp);
% the row and col
nrows=floor((Info.latrange(2)-Info.latrange(1))/Info.cellsize);
ncols=floor((Info.lonrange(2)-Info.lonrange(1))/Info.cellsize);
rowg=floor((Info.latrange(2)-LLE(:,1))/Info.cellsize)+1;
colg=floor((LLE(:,2)-Info.lonrange(1))/Info.cellsize)+1;

indout=rowg<1|rowg>nrows|colg<1|colg>ncols;
rowg(indout)=[];colg(indout)=[];
LLE(indout,:)=[];
data_stn(:,indout)=[];

indrc=sub2ind([nrows,ncols],rowg,colg);

days=[28,29,30,31];
indrc3D=cell(length(days),1);
for i=1:length(days)
    dayi=days(i);
    temp=[];
    for j=1:dayi
       temp=cat(1,temp,indrc+nrows*ncols*(j-1)); 
    end
   indrc3D{i}=temp;
end

save(Outfile_stn,'LLE','data_stn','date','nrows','ncols','indrc','indrc3D','-v7.3');
end