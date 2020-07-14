function f_ens_data_andrew(Inpath_ensemble,Outfile_ens,Outfile_stn,var_ensvv,YEAR,EnsNum)
% load station data
load(Outfile_stn,'data_stn','indrc','date');
gnum=size(data_stn,2);
enum=EnsNum(2)-EnsNum(1)+1;
% 
data_ens=cell(enum,1);
data_ens(:)={nan*zeros(size(data_stn))};
flag=1;
for yy=YEAR(1):YEAR(end)
        fprintf('Read ensemble %s: years %d--yeare %d\n',var_ensvv,yy,YEAR(end));
        % number of days of the year
        daysy=datenum(yy,12,31)-datenum(yy,1,1)+1;
        data_stny=data_stn(flag:flag+daysy-1,:);
        % read ensemble data
        datam=cell(enum,1); % for parfor
        for ens=1:enum
            ense=EnsNum(1)+ens-1;
            fprintf('Read ensemble %s: ens %d--years %d--yeare %d\n',var_ensvv,ense,yy,YEAR(end));
            
            file=[Inpath_ensemble,'/conus_daily_eighth_',num2str(yy),'0101_',num2str(yy),'1231_',num2str(ense,'%.3d'),'.nc4'];
            if strcmp(var_ensvv,'prcp'); var_ensvv='pcp'; end
            if strcmp(var_ensvv,'tmean'); var_ensvv='t_mean'; end
            if strcmp(var_ensvv,'trange'); var_ensvv='t_range'; end
            datavv=ncread(file,var_ensvv);
            datavv=flipud(permute(datavv,[2,1,3]));

            % extract corresponding gauge data
            % index
            nrows=size(datavv,1);
            ncols=size(datavv,2);
            indrcm=[];
            for dd=1:daysy
                indrcm=cat(1,indrcm,indrc+nrows*ncols*(dd-1));
            end
            % extract
            datavv=reshape(datavv,nrows,[]);
            temp=datavv(indrcm);
            temp=reshape(temp,gnum,daysy);
            temp=temp';
            temp(isnan(data_stny))=nan;
            datam{ens}=temp;
        end
        
        for ens=1:enum
            data_ens{ens}(flag:flag+daysy-1,:)=datam{ens};
        end
        flag=flag+daysy;
end
save(Outfile_ens,'data_ens','YEAR','-v7.3');
end