function f_ens_data(Inpath_ensemble,Outfile_ens,Outfile_stn,var_ensvv,YEAR,EnsNum)
% load station data
load(Outfile_stn,'data_stn','indrc3D','date');
gnum=size(data_stn,2);
enum=EnsNum(2)-EnsNum(1)+1;
% 
data_ens=cell(enum,1);
data_ens(:)={nan*zeros(size(data_stn))};
flag=1;
for yy=YEAR(1):YEAR(end)
    Inpathyy=[Inpath_ensemble,'/',num2str(yy)];
    for mm=1:12
        fprintf('Read ensemble %s: month %d--years %d--yeare %d\n',var_ensvv,mm,yy,YEAR(end));
        % number of days of the month
        switch mm
            case {1,3,5,7,8,10,12}
                daysm=31;
                indrcm=indrc3D{4};
            case {4,6,9,11}
                daysm=30;
                indrcm=indrc3D{3};
            case 2
                if (mod(yy,4)==0&&mod(yy,100)~=0)||mod(yy,400)==0
                    daysm=29;
                    indrcm=indrc3D{2};
                else
                    daysm=28;
                    indrcm=indrc3D{1};
                end
        end
        data_stnym=data_stn(flag:flag+daysm-1,:);
        % read ensemble data
        datam=cell(enum,1); % for parfor
        for ens=1:enum
            ense=EnsNum(1)+ens-1;
            fprintf('Read ensemble %s: ens %d--month %d--years %d--yeare %d\n',var_ensvv,ense,mm,yy,YEAR(end));
            file=[Inpathyy,'/ens_',num2str(yy*100+mm),'.',num2str(ense,'%.3d'),'.nc'];
            datavv=ncread(file,var_ensvv);
            datavv=permute(datavv,[2,1,3]);
            datavv=flipud(datavv);
            % extract corresponding gauge data
            nrows=size(datavv,1);
            datavv=reshape(datavv,nrows,[]);
            temp=datavv(indrcm);
            temp=reshape(temp,gnum,daysm);
            temp=temp';
            temp(isnan(data_stnym))=nan;
            datam{ens}=temp;
        end
        
        for ens=1:enum
            data_ens{ens}(flag:flag+daysm-1,:)=datam{ens};
        end
        flag=flag+daysm;
    end
end

save(Outfile_ens,'data_ens','YEAR','-v7.3');
end