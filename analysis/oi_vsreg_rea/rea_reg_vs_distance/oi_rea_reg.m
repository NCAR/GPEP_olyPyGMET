% study the improvement of OI against station density
clc;clear;close all

% calculate distance
datafile='../gain_vs_distance/stn_dist.mat';
load(datafile);
indlat=lle(:,1)<30;

% grid distance
datafile='data_oiregrea.mat';
if exist(datafile,'file')
    load(datafile);
else
    % distbin=[0:5:95,100:10:190,200:50:450,500:200:2000];
    % distbin=0:5:2000;
    distbin=10.^(1:0.1:3.2);
    distbin=floor(distbin);
    distbin=unique(distbin);
    distbin(1)=1;
    numbin=length(distbin)-1;
    % station, only consider the 20th closest station
    metbin_rea=cell(3,1);
    metbin_rea(:)={nan*zeros(numbin,16)};
    metbin_oi=metbin_rea;
    metbin_reg=metbin_rea;
    metnum=cell(3,1);
    metnum(:)={nan*zeros(numbin,16)};
    metdist=nan*zeros(numbin,1);
    
    load('../oi_gain/mean_value.mat','mean_stn');
    load('../oi_gain/oi_evaluation.mat','met_prcp_oi','met_tmean_oi','met_trange_oi')
    load('../oi_gain/reg_evaluation.mat','met_prcp_reg','met_tmean_reg','met_trange_reg')
    metall=cell(3,3);
    met_prcp_oi(:,2)=met_prcp_oi(:,2)./mean_stn(:,1);
    met_trange_oi(:,2)=met_trange_oi(:,2)./mean_stn(:,3);
    metall{1,1}=met_prcp_oi; metall{2,1}=met_tmean_oi; metall{3,1}=met_trange_oi;
    
    met_prcp_reg(:,2)=met_prcp_reg(:,2)./mean_stn(:,1);
    met_trange_reg(:,2)=met_trange_reg(:,2)./mean_stn(:,3);
    metall{1,2}=met_prcp_reg; metall{2,2}=met_tmean_reg; metall{3,2}=met_trange_reg;
    
    load('../../rea_corrmerge/prcp_evaluation.mat','met_merge')
    met_merge(:,2)=met_merge(:,2)./mean_stn(:,1);
    metall{1,3}=met_merge; 
    load('../../rea_corrmerge/tmean_evaluation.mat','met_merge')
    metall{2,3}=met_merge; 
    load('../../rea_corrmerge/trange_evaluation.mat','met_merge')
    met_merge(:,2)=met_merge(:,2)./mean_stn(:,3);
    metall{3,3}=met_merge; 
    for v=1:3
        metv=[metall{v,1},metall{v,2},metall{v,3}]; % oi reg rea
        for i=1:16
            data=[metv(:,[i,i+16,i+32]),dist{v}(:,3)];
            data(indlat,:)=nan;
            data(isnan(data(:,1))|isnan(data(:,2))|isnan(data(:,3))|isnan(data(:,4)),:)=[];
            for j=1:numbin
                indj=data(:,4)>=distbin(j)&data(:,4)<distbin(j+1);
                metbin_oi{v}(j,i)=nanmedian(data(indj,1));
                metbin_reg{v}(j,i)=nanmedian(data(indj,2));
                metbin_rea{v}(j,i)=nanmedian(data(indj,3));
                metnum{v}(j,i)=sum(indj);
                metdist(j)=(distbin(j)+distbin(j+1))/2;
            end
        end
        
    end
    save(datafile,'distbin','metnum','metbin_rea','metbin_oi','metbin_reg','metdist');
end
