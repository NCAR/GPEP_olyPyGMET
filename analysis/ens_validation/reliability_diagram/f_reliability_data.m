function reliability_data=f_reliability_data(prob_ens,prob_stn,bin,rnr_use)
reliability_data=cell(length(rnr_use),1);
for i=1:length(rnr_use)
    pstni=prob_stn{rnr_use(i)};
    pensi=prob_ens{rnr_use(i)};
    probi=nan*zeros(length(bin)-1,2);
    for j=1:length(bin)-1
        ind=pensi>=bin(j)&pensi<bin(j+1);
        temp=pstni(ind);
        probi(j,1)=nanmean(temp);
        temp=pensi(ind);
        probi(j,2)=nanmean(temp);
    end
    reliability_data{i}=probi;
end
end