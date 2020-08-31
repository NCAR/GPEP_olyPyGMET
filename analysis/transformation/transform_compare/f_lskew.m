function lskew=f_lskew(lmom)
if length(lmom)<3
    error('not enough l-moments');
else
    lskew=lmom(3)/lmom(2);
end
end