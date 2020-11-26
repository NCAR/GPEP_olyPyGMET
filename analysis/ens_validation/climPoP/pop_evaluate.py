# compare the Probability of Precipitation (PoP) of EMDNA and stations
import numpy as np
from scipy import io
import os,datetime


Inpath='/home/gut428/scratch/GMET/ens_evaluation_spearman'
Outpath='.'
year=[1979, 2018]
leastnum=200

EnsNum=[1, 100]
ensnum=EnsNum[1]-EnsNum[0]+1
thrs = [0, 0.1, 1, 5, 10, 15, 20, 25]

for y in range(year[0], year[1] + 1):
    outfile = '{}/pop_{}_{}.mat'.format(Outpath, 'prcp', y)
    # if os.path.isfile(outfile):
    #     continue
    print('year', y)
    file1 = '{}/stn_{}_{}.mat'.format(Inpath, 'prcp', y)
    file2 = '{}/ens_{}_{}.mat'.format(Inpath, 'prcp', y)
    d1 = io.loadmat(file1)
    data_stn = d1['data_stn']
    LLE = d1['LLE']
    num = np.sum(data_stn > -100, axis=0)
    data_stn[:, num < leastnum] = np.nan
    d2 = io.loadmat(file2)
    data_ens = d2['data_ens']
    indno = np.isnan(data_stn)
    for i in range(np.shape(data_ens)[2]):
        temp = data_ens[:,:,i]
        temp[indno] = np.nan
        data_ens[:, :, i] = temp
    # calculate date
    date_start = datetime.date(y, 1, 1)
    date_end = datetime.date(y, 12, 31)
    daynum = (date_end - date_start).days + 1
    date_ymd = np.zeros(daynum, dtype=int)
    dated = date_start
    for d in range(daynum):
        if d > 0:
            dated = dated + datetime.timedelta(days=1)
        date_ymd[d] = int(dated.strftime("%Y%m%d"))
    month = (np.mod(date_ymd, 10000) / 100).astype(int)
    # calculate PoP for precipitation
    dnum, gnum = np.shape(data_stn)
    pop_stn = np.nan * np.zeros([gnum, len(thrs)])
    pop_ens = np.nan * np.zeros([gnum, len(thrs)])
    for g in range(gnum):
        for t in range(len(thrs)):
            dg = data_stn[:, g]
            if np.sum(~np.isnan(dg))>0:
                pop_stn[g, t] = np.sum(dg>thrs[t])/np.sum(dg>=0)
            dg = data_ens[:, g, :]
            if ~np.isnan(pop_stn[g, t]):
                pop_ens[g, t] = np.sum(dg>thrs[t])/np.sum(dg>=0)
    io.savemat(outfile, {'pop_stn': pop_stn, 'pop_ens': pop_ens, 'LLE': LLE}, do_compression=True)
