function [met,metname]=f_metric_cal(dref,dtar,index2flag)
metname={'CC','RMSE','ME','BIAS','MAE','ABIAS','POD','FOH','FAR','CSI','HSS','KGE','r','gamma','beta'};

ind=isnan(dref) | isnan(dtar);
dref(ind)=[];
dtar(ind)=[];
if length(dref)<5
    met=nan*ones(1,15);
    return;
end

temp1=Index_cal1(dref,dtar);
if index2flag==1
    temp2=Index_cal2(dref,dtar,0.5);
else
    temp2=nan*zeros(1,5);
end
KGEgroup=f_KEG(dref,dtar);
met=[temp1,temp2,KGEgroup];
end

function INDEX = Index_cal1(Rain_G,Rain_S)
%Rain_G: Gauge Precipitation
%Rain_S: Satellite Precipitation

% ����Mask�Ϸֲ���CC��RMSE��ME��BIAS
% [Rain_G,Rain_S]=Data_screening(Rain_G,Rain_S);  %ɸѡԭʼ����
if length(Rain_G)>2
    CC0=corrcoef(Rain_G,Rain_S);
    INDEX(1)=CC0(2);  %CC
    INDEX(2)=sqrt(sum((Rain_G-Rain_S).^2)/length(Rain_S)); %RMSE
    INDEX(3)=sum(Rain_S-Rain_G)/length(Rain_S);  %ME
    INDEX(4)=sum(Rain_S-Rain_G)/sum(Rain_G);     %BIAS
    INDEX(5)=sum(abs(Rain_S-Rain_G))/length(Rain_S);  %MAE
    INDEX(6)=sum(abs(Rain_S-Rain_G))/sum(Rain_G);  %ABIAS
else
    INDEX=nan*zeros(1,6);
end
end


function INDEX = Index_cal2(Rain_G,Rain_S,R_NR)
%Rain_G: Gauge Precipitation
%Rain_S: Satellite Precipitation
%R_NR: Rain or No Rain
% ����Mask�Ϸֲ���POD(Probability of Detection),FOH(frequency of hit)
% FAR(False Alarm Ratio),CSI(Critical Success Index,HSS(Heidke��s skill
% score),Ebert et al. [2007]
% [Rain_G,Rain_S]=Data_screening(Rain_G,Rain_S);  %ɸѡԭʼ����
if length(Rain_G)>2
    n11=sum((Rain_G>=R_NR&Rain_S>=R_NR));
    n10=sum((Rain_G<R_NR&Rain_S>=R_NR));
    n01=sum((Rain_G>=R_NR&Rain_S<R_NR));
    n00=sum((Rain_G<R_NR&Rain_S<R_NR));
    
    INDEX(1)=n11/(n11+n01);  %POD,perfect value 1
    INDEX(2)=n11/(n11+n10);  %FOH,perfect value 1
    INDEX(3)=1-INDEX(2);     %FAR,perfect value 0
    INDEX(4)=n11/(n11+n01+n10);     %CSI,perfect value 1
    INDEX(5)=2*(n11*n00-n10*n01)/((n11+n01)*(n01+n00)+(n11+n10)*(n10+n00));  %HSS
else
    INDEX=nan*zeros(1,5);
end
end

function KGEgroup=f_KEG(Obs,Pre)
pre_mean = nanmean(Pre);
obs_mean = nanmean(Obs);
r = nansum((Pre - pre_mean) .* (Obs - obs_mean)) / sqrt(nansum((Pre - pre_mean).^2).*nansum((Obs - obs_mean).^2));
gamma = (std(Pre)/pre_mean) / (std(Obs) / obs_mean);
beta = nanmean(Pre)/nanmean(Obs);
KGE = 1 - sqrt((r - 1)^2 + (gamma - 1)^2 + (beta - 1)^2);
KGEgroup = [KGE,r,gamma,beta];
end