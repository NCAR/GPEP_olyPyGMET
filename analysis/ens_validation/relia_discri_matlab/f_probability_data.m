function [prob_ens,prob_stn]=f_probability_data(File_prob,Infile_gauge,Infile_ensemble,RNR_threshold)
if exist(File_prob,'file')
   load(File_prob,'prob_ens','prob_stn')
   return;
end

rnrn=length(RNR_threshold);
% 1. read gauge data
load(Infile_gauge,'data_stn');
% 2. rain/no rain of gauge data
prob_stn=cell(rnrn,1);
for i=1:rnrn
    indi=data_stn>RNR_threshold(i);
    temp=data_stn;
    temp(indi)=1;
    temp(~indi)=0;
    prob_stn{i}=temp;
end

gnum=size(data_stn,2);
daynum=size(data_stn,1);
% 3. read ensemble data and rain/no rian probability
prob_ens=cell(rnrn,1);
prob_ens(:)={nan*zeros(size(data_stn))};
load(Infile_ensemble,'data_ens');
% calculate probability of precipitation of ensembles
for rr=1:rnrn
    for gg=1:gnum
        datagg=nan*zeros(daynum,100);
        for ens=1:100
            datagg(:,ens)=data_ens{ens}(:,gg);   
        end
        indgg=datagg>RNR_threshold(rr);
        datagg(indgg)=1;
        datagg(~indgg)=0;
        probm=nanmean(datagg,2);
        prob_ens{rr}(:,gg)=probm;
    end
end
save(File_prob,'prob_ens','prob_stn','RNR_threshold');
end