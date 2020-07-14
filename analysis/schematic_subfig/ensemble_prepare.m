clc;clear;close all

load('stninfo.mat');
row=floor((85-stninfo(:,2))/0.1)+1;
col=floor((stninfo(:,3)+180)/0.1)+1;
indrc=sub2ind([800,1300],row,col);
nstn=length(row);

vars1={'pcp','tmean','trange'};
vars2={'pcp','t_mean','t_range'};

dstn=single(nan*zeros(3,366,nstn));
path1='/datastore/GLOBALWATER/CommonData/EMDNA_new/GMET_OIinput';
flag=0;
for i=1:12
    fprintf('%d\n',i);
    file=[path1,'/reg_',num2str(i+201600),'.nc'];
    for v=1:3
        d=ncread(file,vars1{v});
        d=flipud(permute(d,[2,1,3]));
        days=size(d,3);
        for j=1:days
            temp=d(:,:,j);
            dstn(v,j+flag,:)=temp(indrc);
        end
    end
    flag=flag+days;
end

path2='/datastore/GLOBALWATER/CommonData/EMDNA_new/EMDNA_ens2/2016';
dens=single(nan*zeros(3,366,nstn,100));
flag=0;
for i=1:12
    for e=1:100
        fprintf('%d--%d\n',i,e);
        file=[path2,'/ens_',num2str(i+201600),'.',num2str(e,'%03d'),'.nc'];
        for v=1:3
            d=ncread(file,vars2{v});
            d=flipud(permute(d,[2,1,3]));
            days=size(d,3);
            for j=1:days
                temp=d(:,:,j);
                dens(v,j+flag,:,e)=temp(indrc);
            end
        end
    end
    flag=flag+days;
end

usedata=1:100:nstn;
induse=ismember(1:nstn,usedata);

dens(:,:,~induse,:)=[];
dstn(:,:,~induse)=[];
stninfo(~induse,:)=[];
save('ensemble_data_2016.mat','dstn','dens','stninfo','-v7.3');