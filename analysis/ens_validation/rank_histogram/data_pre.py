import numpy as np
import netCDF4 as nc
from scipy import io
import os

Outpath='.'
gridfile = '/home/gut428/scratch/GMET/StnGridInfo/gridinfo_whole.nc'
Inpath='/home/gut428/scratch/GMET/ens_evaluation'

year=[1979, 2000]
vars=['prcp','tmean','trange']
leastnum=[200,200,200] # the least number of gauge samples so that the gauge will be included in evaluation
varnum=len(vars)
EnsNum=[1, 100]
ensnum=EnsNum[1]-EnsNum[0]+1

# read grid information
d = nc.Dataset(gridfile)
lat = d['latitude'][:].data
lat = lat[:,0]
lon = d['longitude'][:].data
lon=lon[0,:]
elev = d['elev'][:].data


for v in range(varnum):
    outfile = Outpath + '/rank_' + vars[v] + '_1979-2000.mat'
    if os.path.isfile(outfile):
        continue
    rank = []
    for y in range(year[0], year[1]+1):
        print('var/year',v, y)
        file1 = '{}/stn_{}_{}.mat'.format(Inpath,vars[v],y)
        file2 = '{}/ens_{}_{}.mat'.format(Inpath, vars[v], y)
        d1 = io.loadmat(file1)
        data_stn = d1['data_stn']
        LLE = d1['LLE']
        num = np.sum(data_stn > -100, axis=1)
        data_stn[num<leastnum[v],:] = np.nan


        d2 = io.loadmat(file2)
        data_ens = d2['data_ens']

        # for mean temperature, we should match their elevation
        dnum, gnum = np.shape(data_stn)
        if vars[v] == 'tmean':
            gridelev = np.zeros(gnum)
            for g in range(gnum):
                diff = LLE[g, 0] - lat
                rowstn = np.nanargmin(abs(diff))
                diff = LLE[g, 1] - lon
                colstn = np.nanargmin(abs(diff))
                gridelev[g] = elev[rowstn, colstn]
            add = (LLE[:,2] - gridelev)/1000*(-6.5)
            for d in range(dnum):
                data_stn[d,:] = data_stn[d,:] + add

        # calculate rank
        rankyv = np.nan * np.zeros([dnum, gnum])
        for d in range(dnum):
            for g in range(gnum):
                dstn_dg = data_stn[d, g]
                if dstn_dg > -100:
                    if dstn_dg < 0.1 and vars[v] == 'prcp':
                        rankyv[d, g] = np.nan
                    else:
                        dens_dg = data_ens[d, g, :]
                        rankyv[d, g] = np.sum(dens_dg<dstn_dg)

        rank = np.hstack((rank, rankyv.flatten()))

    io.savemat(outfile,{'rank':rank},do_compression=True)