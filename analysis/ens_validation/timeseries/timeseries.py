import numpy as np
import netCDF4 as nc
from scipy import io
import time

path = '/home/gut428/scratch/GMET/EMDNA_out/Estimate_spearman'
year = [2018, 2018]
month = [1, 12]
ens = [1, 100]
vars = ['pcp', 't_mean', 't_range']

data = np.nan * np.zeros([365, 100, 3], dtype=np.float32)
flag = 0
for y in range(year[0], year[1]+1):
    for m in range(month[0], month[1]+1):
        for e in range(ens[0], ens[1]+1):
            # time1 = time.time()
            print('year/month/ens', y, m, e)
            file = '{}/{}/EMDNA_{}.{:03d}.nc4'.format(path,y,y*100+m,e)
            ncfid = nc.Dataset(file)
            for v in range(len(vars)):
                di = ncfid.variables[vars[v]][:].data
                di[di<-100] = np.nan
                ndays = np.shape(di)[0]
                for d in range(ndays):
                    data[flag+d,e-1,v] = np.nanmean(di[d, :, :])
            ncfid.close()
            # time2 = time.time()
            # print(time2-time1)
        flag = flag + ndays

io.savemat('ens_mean_daily.mat',{'data':data})