% calculate the variability of ensemble estimates
clc;clear;close all
Outpath='.';
Inpath='/Users/localuser/GMET/EMDNA_evaluate/ens';
year=2016:2016;
vars={'prcp','tmean','trange'};
leastnum=[200,200,200]; % the least number of gauge samples so that the gauge will be included in evaluation
varnum=length(vars);
EnsNum=[1,100];
ensnum=EnsNum(2)-EnsNum(1)+1;
suffix='';

for vv=1:varnum
    varvv=vars{vv};
    fileens=[Inpath,'/ens_',varvv,suffix,'.mat'];
    outfile=[Outpath,'/variability_',varvv,suffix,'.mat'];
    if exist(outfile,'file')
        continue;
    end
    
    load(fileens,'data_ens');
    nday=size(data_ens{1},1);
    nstn=size(data_ens{1},2);
    vstd=nan*zeros(nstn,nday);
    vmag=nan*zeros(nstn,nday);
    vrange=nan*zeros(nstn,nday);
    for i=1:nstn
        for j=1:nday
            dij=zeros(ensnum,1);
            flag=1;
            for e=EnsNum(1):EnsNum(2)
                dij(flag)=data_ens{e}(j,i);
                flag=flag+1;
            end
            vstd(i,j)=nanstd(dij);
            dij=dij-nanmean(dij);
            vmag(i,j)=mean([abs(min(dij)), abs(max(dij))]);
            vrange(i,j)=max(dij)-min(dij);
        end
    end
    save(outfile,'vstd','vmag','vrange','-v7.3');
end
