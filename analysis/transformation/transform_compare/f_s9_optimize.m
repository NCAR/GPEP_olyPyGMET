function [x,fval]=f_s9_optimize(p)

fun=@(x) (cal_ls( (p+1).^x +log(p) ) )^2 + (cal_lk( (p+1).^x +log(p) ) - 0.1226)^2;
[x,fval] = fminsearch(fun,0.02);

end

function lskew=cal_ls(p)
lmom = f_lmom(p,4);
lskew=f_lskew(lmom);
end

function lkurtosis=cal_lk(p)
lmom = f_lmom(p,4);
lkurtosis=lmom(4)/lmom(2);
end