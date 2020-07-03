function discrimination_data=f_discrimination_data(prob_ens,prob_stn,bin,rnr_use)
discrimination_data=cell(length(rnr_use),1);
for i=1:length(rnr_use)
    pstni=prob_stn{rnr_use(i)};
    pensi=prob_ens{rnr_use(i)};
    probi=nan*zeros(length(bin)-1,2);
    indprob=cell(2,2);
    indprob{1,1}=pstni==0;
    indprob{1,2}=sum(indprob{1,1}(:));
    indprob{2,1}=pstni==1;
    indprob{2,2}=sum(indprob{2,1}(:));
    for ii=1:2
        pensii=pensi(indprob{ii,1});
        for j=1:length(bin)-1
            ind=pensii>=bin(j)&pensii<bin(j+1);
            probi(j,ii)=sum(ind(:))/indprob{ii,2};
        end
    end
    discrimination_data{i}=probi;
end
end