% clc;clear;close all
% load('/Users/localuser/Research/EMDNA/stndata_aftercheck.mat','prcp_stn','stninfo')
nstn=size(prcp_stn,1);
c1=0.1:0.1:15;
c2=0.1:0.01:2;
stv=[1,0.6]; % start point of c1, c2
range={[0.1,0.1],[15,2]}; % lower/upper of c1, c2
for i=1000:1000
    pi=prcp_stn(i,:);
    pi=pi(pi>=0.1);
    
    if length(pi)>1000
        p_mean=mean(pi);
        p_std=std(pi);
        cs=skewness(pi);
        cv=p_std/p_mean;
        
        ofi=nan*zeros(length(c1),length(c2));
        
        OF = @(x) ((2*gamma((x(1)+1)/x(2))^3 - ...
            3*gamma(x(1)/x(2))*gamma((x(1)+2)/x(2))*gamma((x(1)+1)/x(2)) + ...
            gamma(x(1)/x(2))^2*gamma((x(1)+3)/x(2))) / ...
            (gamma(x(1)/x(2))*gamma((x(1)+2)/x(2)) - gamma((x(1)+1)/x(2))^2)^1.5 - ...
            cs)^2 + ...
            ((gamma(x(1)/x(2))*gamma((x(1)+2)/x(2))/gamma((x(1)+1)/x(2))^2-1)^0.5-cv)^2;
        
        for i1=1:length(c1)
            for i2=1:length(c2)
                ofi(i1,i2)=OF([c1(i1),c2(i2)]);
            end
        end
        
        [c1o,c2o,betao]=gg_parameter(pi,stv,range);
    end
end

close
% hold on
% imagesc(c1,c2,ofi,'alphadata',ofi>-1);
[C2,C1] = meshgrid(c2,c1);
contour(C1,C2,ofi,0:0.5:30);
% set(gca,'xtick',1:30:150,'xticklabel',0.1:3:15);
% set(gca,'ytick',1:30:190,'yticklabel',0.1:0.3:2);
% plot(c1o,c2o,'*w','markersize',10);
% hold off
caxis([0,10]);
% set(gca,'ColorScale','log');
colormap('jet')
colorbar
xlabel('c1');
ylabel('c2');

