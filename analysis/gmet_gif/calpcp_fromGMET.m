clc;clear;close all
day=1;
pop=zeros(800,1300,11);
cs=zeros(800,1300,11);
rn=zeros(800,1300,11);

file1='/Users/localuser/GMET/test0622/reg_197901.nc';
p1=ncread(file1,'pop');
p1=flipud(permute(p1,[2,1,3]));

pop(:,:,1)=p1(:,:,day);
for i=1:10
    file2=['/Users/localuser/GMET/test0622/ens_197901.',num2str(i,'%.3d'),'.nc'];
    cprob=ncread(file2,'pcp_cprob');
    cprob(cprob<0)=nan;
    cprob=flipud(permute(cprob,[2,1,3]));
    % cumulative probability
    pop(:,:,i+1)=cprob(:,:,day);
    % conditional probability
    cs(:,:,i+1)=(cprob(:,:,day)-(1-pop(:,:,1)))./pop(:,:,1);
    % calculate rn
    rn(:,:,i+1) = sqrt (2) * erfinv (2*cs(:,:,i+1)-1);
end


file1='/Users/localuser/GMET/test0622/reg_197901.nc';
ymax=ncread(file1,'ymax');
pcp=ncread(file1,'pcp');
pcp_err=ncread(file1,'pcp_error');
pcp=flipud(permute(pcp,[2,1,3]));
ymax=flipud(permute(ymax,[2,1,3]));
pcp_err=flipud(permute(pcp_err,[2,1,3]));

pcp_fromrn=zeros(800,1300,11);
pcp_fromrn(:,:,1)=pcp(:,:,day);
for i=1:10
    temp=pcp_err(:,:,day)*rn(:,:,i+1)+pcp(:,:,1);
    
    pcp_fromrn(:,:,i+1)=temp;
end

