clc;clear;close all
addpath('/Users/localuser/Github/tools/export_fig');

datafile='stn_regression_data.mat';

if exist(datafile,'file')
    load(datafile)
else
    file1='/Users/localuser/Research/EMDNA/stndata_aftercheck.mat';
    file2='/Users/localuser/Research/EMDNA/regression_stn.mat';
    
    load(file1);
    load(file2);
    
    nstn=size(prcp,1);
    rmse=nan*zeros(nstn,3);
    for i=1:nstn
        if mod(i,1000)==0
            fprintf('%d\n',i);
        end
        rmse(i,1)=(nanmean((prcp(i,:)-prcp_stn(i,:)).^2))^0.5/nanmean(prcp_stn(i,:));
        rmse(i,2)=(nanmean((tmean(i,:)-tmean_stn(i,:)).^2))^0.5;
        rmse(i,3)=(nanmean((trange(i,:)-trange_stn(i,:)).^2))^0.5;
    end
    
    nstn=size(prcp,1);
    cc=nan*zeros(nstn,3);
    for i=1:nstn
        if mod(i,1000)==0
            fprintf('%d\n',i);
        end
        temp=corrcoef(prcp(i,:),prcp_stn(i,:));
        cc(i,1)=temp(2);
        temp=corrcoef(tmean(i,:),tmean_stn(i,:));
        cc(i,2)=temp(2);
        temp=corrcoef(trange(i,:),trange_stn(i,:));
        cc(i,3)=temp(2);
    end
end

% curves
latbin=5:1:85;
data=nan*zeros(length(latbin)-1,3);
lat=zeros(length(latbin)-1,1);
for j=1:length(latbin)-1
    ind=stninfo(:,2)>=latbin(j) & stninfo(:,2)<latbin(j+1);
    lat(j)=(latbin(j)+latbin(j+1))/2;
    dij=rmse(ind,:);
    if size(dij,1)>20
        data(j,:)=nanmedian(dij,1);
    end
end

fsize=7;
figure('color','w','unit','centimeters','position',[15,20,10,4]);

yyaxis right
hold on
plot(lat, data(:,2),'-b','linewidth',1)
plot(lat, data(:,3),'-.b','linewidth',1)
hold off
ylim([1,4]);
ylabel('RMSE');

yyaxis left
plot(lat, data(:,1),'-k','linewidth',1)
ylim([1,5]);
ylabel('NRMSE');

ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'b';

xlim([10,75])
xlabel('Latitude');
set(gca,'fontsize',fsize);

legend({'P','T_{mean}','T_{range}'},'Location','north','NumColumns',3,'Box','off')

export_fig stn_regression_metric.png -transparent -m20
