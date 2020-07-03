function dataall=f_reanalysis_extract(Inpath,prefix,rowg,colg,years,yeare,datag)
dataall=[];

for yy=years:yeare
	fprintf('%s-%d--%d\n',prefix,yy,yeare);
    daysyy=datenum(yy,12,31)-datenum(yy,1,1)+1;
    file=[Inpath,'/',prefix,num2str(yy),'.nc4'];
    if ~exist(file,'file')
        ddyy=nan*zeros(daysyy,length(rowg));
    else
        data=ncread(file,'data');
        if size(data,3)~=daysyy
            error('Reanalysis data have different dates with the defined date');
        end
        ddyy=[];
        for gg=1:length(rowg)
            datagg=squeeze(data(rowg(gg),colg(gg),:));
            datagg=datagg(:);
            ddyy=cat(2,ddyy,datagg);
        end
    end
    dataall=cat(1,dataall,ddyy);
end

ndays=size(datag,1);
for gg=1:length(rowg)
    datagg=datag(:,gg);
    indval0=find(~isnan(datagg));
    if isempty(indval0)
        dataall(:,gg)=nan;
    else
        indval=[];
        for i=-2:2
            indval=cat(1,indval,indval0+i);
        end
        indval=unique(indval);
        indval(indval<1|indval>ndays)=[];

        temp=dataall(:,gg);
        temp2=temp*nan;
        temp2(indval)=temp(indval);
        dataall(:,gg)=temp2;
    end
end
end