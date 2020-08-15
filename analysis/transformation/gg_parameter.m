function [c1,c2,beta]=gg_parameter(p,stv,range)
% stv: start point
% range: parameter constraint
p_mean=mean(p);
p_std=std(p);
cs=skewness(p);
cv=p_std/p_mean;

OF = @(x) ((2*gamma((x(1)+1)/x(2))^3 - ...
    3*gamma(x(1)/x(2))*gamma((x(1)+2)/x(2))*gamma((x(1)+1)/x(2)) + ...
    gamma(x(1)/x(2))^2*gamma((x(1)+3)/x(2))) / ...
    (gamma(x(1)/x(2))*gamma((x(1)+2)/x(2)) - gamma((x(1)+1)/x(2))^2)^1.5 - ...
    cs)^2 + ...
    ((gamma(x(1)/x(2))*gamma((x(1)+2)/x(2))/gamma((x(1)+1)/x(2))^2-1)^0.5-cv)^2;

x=fminsearchbnd(OF,stv,range{1},range{2});
c1=x(1);
c2=x(2);
beta=p_mean*gamma(c1/c2)/gamma((1+c1)/c2);
end