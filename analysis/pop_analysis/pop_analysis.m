clc;clear;close all

datafile='pop_evaluation.mat';
if exist(datafile,'file')
    load(datafile);
else
    % load pop data
    filestn='/Users/localuser/Research/EMDNA/stndata_aftercheck.mat';
    load(filestn,'prcp_stn','stninfo','date_ymd');
    mm=mod(floor(date_ymd/100),100);
    lle=stninfo(:,2:4);
    nstn=size(lle,1);
    pop_stn=prcp_stn;
    pop_stn(pop_stn>0)=1; clear prcp_stn
    
    file='/Users/localuser/Research/EMDNA/regression_stn.mat';
    load(file,'pop');
    pop_reg=pop; clear pop
    
    file='/Users/localuser/Research/EMDNA/merge_stn_pop_GWR_BMA.mat';
    load(file,'reamerge_stn');
    pop_bma=reamerge_stn; clear reamerge_stn
    
    file='/Users/localuser/Research/EMDNA/OImerge_stn_GWRBMA_pop.mat';
    load(file,'oimerge_stn');
    pop_oi=oimerge_stn; clear oimerge_stn
    
    % calculate mean pop
    pop_mean=nan*zeros(nstn, 4);
    pop_mean(:,1)=nanmean(pop_stn,2);
    pop_mean(:,2)=nanmean(pop_reg,2);
    pop_mean(:,3)=nanmean(pop_bma,2);
    pop_mean(:,4)=nanmean(pop_oi,2);
    
    pop_mean_month=nan*zeros(12, nstn, 4);
    for i=1:12
        ind=mm==i;
        pop_mean_month(i,:,1)=nanmean(pop_stn(:,ind),2);
        pop_mean_month(i,:,2)=nanmean(pop_reg(:,ind),2);
        pop_mean_month(i,:,3)=nanmean(pop_bma(:,ind),2);
        pop_mean_month(i,:,4)=nanmean(pop_oi(:,ind),2);
    end
    % calculate Brier score
    bs=nan*zeros(nstn, 3);
    for i=1:nstn
        if ~isnan(pop_stn(i,1))
            bs(i,1)=nanmean((pop_stn(i,:)-pop_reg(i,:)).^2);
            bs(i,2)=nanmean((pop_stn(i,:)-pop_bma(i,:)).^2);
            bs(i,3)=nanmean((pop_stn(i,:)-pop_oi(i,:)).^2);
        end
    end
    
    bscond=nan*zeros(nstn, 3);
    for i=1:nstn
        if mod(i,100)==0
            fprintf('%d\n',i);
        end
        if ~isnan(pop_stn(i,1))
            dd=[pop_stn(i,:)',pop_reg(i,:)'];
            dd(dd(:,1)<0.001&dd(:,2)<0.001,:)=[];
            bscond(i,1)=nanmean((dd(:,1)-dd(:,2)).^2);
            dd=[pop_stn(i,:)',pop_bma(i,:)'];
            dd(dd(:,1)<0.001&dd(:,2)<0.001,:)=[];
            bscond(i,2)=nanmean((dd(:,1)-dd(:,2)).^2);
            dd=[pop_stn(i,:)',pop_oi(i,:)'];
            dd(dd(:,1)<0.001&dd(:,2)<0.001,:)=[];
            bscond(i,3)=nanmean((dd(:,1)-dd(:,2)).^2);
        end
    end
    
    bs_month=nan*zeros(12, nstn, 3);
    for m=1:12
        indm=mm==m;
        for i=1:nstn
            if ~isnan(pop_stn(i,1))
                bs_month(m,i,1)=nanmean((pop_stn(i,indm)-pop_reg(i,indm)).^2);
                bs_month(m,i,2)=nanmean((pop_stn(i,indm)-pop_bma(i,indm)).^2);
                bs_month(m,i,3)=nanmean((pop_stn(i,indm)-pop_oi(i,indm)).^2);
            end
        end
    end
    
    bscond_month=nan*zeros(12, nstn, 3);
    for m=1:12
        fprintf('%d\n',m);
        indm=mm==m;
        pop_stn2=pop_stn(:,indm);
        pop_reg2=pop_reg(:,indm);
        pop_bma2=pop_bma(:,indm);
        pop_oi2=pop_oi(:,indm);
        for i=1:nstn
            if ~isnan(pop_stn(i,1))
                dd=[pop_stn2(i,:)',pop_reg2(i,:)'];
                dd(dd(:,1)<0.001&dd(:,2)<0.001,:)=[];
                bscond_month(m,i,1)=nanmean((dd(:,1)-dd(:,2)).^2);
                dd=[pop_stn2(i,:)',pop_bma2(i,:)'];
                dd(dd(:,1)<0.001&dd(:,2)<0.001,:)=[];
                bscond_month(m,i,2)=nanmean((dd(:,1)-dd(:,2)).^2);
                dd=[pop_stn2(i,:)',pop_oi2(i,:)'];
                dd(dd(:,1)<0.001&dd(:,2)<0.001,:)=[];
                bscond_month(m,i,3)=nanmean((dd(:,1)-dd(:,2)).^2);
            end
        end
    end
    
    % calculate gridded map
    cellsize=0.5;
    nrows=floor(80/cellsize);
    ncols=floor(130/cellsize);
    latg=(85-cellsize/2):-cellsize:(5+cellsize/2);
    long=(-180+cellsize/2):cellsize:(-50-cellsize/2);
    row=floor((85-lle(:,1))/cellsize)+1;
    col=floor((lle(:,2)+180)/cellsize)+1;
    indrc=sub2ind([nrows,ncols],row,col);
    indrcu=unique(indrc);
    
    bs_grid=nan*zeros(nrows,ncols,3);
    for i=1:3
        m1=nan*zeros(nrows,ncols);
        for g=1:length(indrcu)
            m1(indrcu(g))=nanmedian(bs(indrc==indrcu(g),i));
        end
        bs_grid(:,:,i)=m1;
    end
    
    bscond_grid=nan*zeros(nrows,ncols,3);
    for i=1:3
        m1=nan*zeros(nrows,ncols);
        for g=1:length(indrcu)
            m1(indrcu(g))=nanmedian(bscond(indrc==indrcu(g),i));
        end
        bscond_grid(:,:,i)=m1;
    end
    
    pop_mean_grid=nan*zeros(nrows,ncols,4);
    for i=1:4
        m1=nan*zeros(nrows,ncols);
        for g=1:length(indrcu)
            m1(indrcu(g))=nanmedian(pop_mean(indrc==indrcu(g),i));
        end
        pop_mean_grid(:,:,i)=m1;
    end
    save(datafile,'bs_grid','bs','bs_month','bscond_grid','bscond','bscond_month',...
        'pop_mean_month','pop_mean','pop_mean_grid','latg','long','lle');
end


zz=zeros(12,4);
for i=1:12
    for j=1:4
        temp=pop_mean_month(i,:,j);
        zz(i,j)=nanmean(temp(:));
    end
end

x=1:12;
bscond_month2=permute(bscond_month,[1,3,2]);
h = boxplot2(bscond_month2,x);
set(h.out, 'marker', 'none');
ylim([0,0.3])