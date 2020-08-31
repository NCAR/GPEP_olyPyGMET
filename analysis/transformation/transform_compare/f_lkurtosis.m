function lkurtosis=f_lkurtosis(lmom)
if length(lmom)<4
    error('not enough l-moments');
else
    lkurtosis=lmom(4)/lmom(2);
end
end