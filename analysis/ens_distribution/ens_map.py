# prepare the mean monthly distribution of precipitation and temperature based ens and oi
import numpy as np
import netCDF4 as nc
from scipy import io

year = 2018
month = 8
ens_num = [1, 25, 50, 75, 100]
outfile = 'oi_ens_mean_{}.mat'.format(year*100+month)

oi_path = '/home/gut428/scratch/GMET/GMET_OIinput'
ens_path = '/home/gut428/scratch/GMET/EMDNA_out'

# load oi data
vars = ['pcp','tmean','trange']
oi_file = '{}/reg_{}.nc'.format(oi_path,year*100+month)
oi_data = np.zeros([800, 1300, 3], dtype=np.float32)
d = nc.Dataset(oi_file)
for i in range(3):
    di = d[vars[i]][:].data
    if vars[i]=='pcp':
        di = (di/3+1)**3
    oi_data[:, :, i] = np.nanmean(di, axis=0)

# load ens data
vars = ['pcp','t_mean','t_range']
ens_path = '{}/{}'.format(ens_path, year)
en = len(ens_num)
ens_data = np.zeros([800, 1300, 3, en], dtype=np.float32)
for e in range(en):
    ens_file = '{}/ens_{}.{:03d}.nc'.format(ens_path, year*100+month,ens_num[e])
    d = nc.Dataset(ens_file)
    for i in range(3):
        di = d[vars[i]][:].data
        ens_data[:, :, i, e] = np.nanmean(di, axis=0)

io.savemat(outfile,{'ens_data':ens_data, 'oi_data':oi_data, 'year':year, 'month':month, 'ens_num':ens_num},
           do_compression='True')


# load Andrew data
year = 2016
month = 8
dse = [213, 213+31]
ens_num = [1, 25, 50, 75, 100]
outfile = 'andrew_ens_mean_{}.mat'.format(year*100+month)

path = '/datastore/GLOBALWATER/CommonData/EMDNA_new/Andrew_GMET'
vars = ['pcp','t_mean','t_range']
en = len(ens_num)
ens_data = np.zeros([224, 464, 3, en], dtype=np.float32)
for e in range(en):
    ens_file = '{}/conus_daily_eighth_{}0101_{}1231_{:03d}.nc4'.format(path, year, year,ens_num[e])
    d = nc.Dataset(ens_file)
    for i in range(3):
        di = d[vars[i]][:].data[dse[0]:dse[1],:,:]
        ens_data[:, :, i, e] = np.nanmean(di, axis=0)
io.savemat(outfile,{'ens_data':ens_data, 'year':year, 'month':month, 'ens_num':ens_num},
           do_compression='True')