# extract ensemble data and station data to support validation
import numpy as np
import netCDF4 as nc
from scipy import io
import datetime
import os

# basic information
path_ens = '/home/gut428/scratch/GMET/EMDNA_out'
file_stn = '/home/gut428/scratch/GMET/StnValidation.nc4'
outpath = '/home/gut428/scratch/GMET/ens_evaluation'

varall1=['prcp','tmean','trange'] # stnfile var
varall2=['pcp','t_mean','t_range'] # ensfile var
year=[1979, 2018]
leastnum=[200, 200, 200]
ensorder=[1, 100]
lontar = np.arange(-180 + 0.05, -50, 0.1)
lattar = np.arange(85 - 0.05, 5, -0.1)

# information of target date
date_start = datetime.date(year[0], 1, 1)
date_end = datetime.date(year[1], 12, 31)
daynum = (date_end - date_start).days + 1
date_ymd = np.zeros(daynum, dtype=int)
dated = date_start
for d in range(daynum):
    if d > 0:
        dated = dated + datetime.timedelta(days=1)
    date_ymd[d] = int(dated.strftime("%Y%m%d"))

# extract station data
for y in range(year[0], year[1] + 1):
    for v in range(len(varall1)):
        outfile_stn = outpath + '/stn_' + varall1[v] + '_' + str(y) +'.mat'
        outfile_ens = outpath + '/ens_' + varall1[v] + '_' + str(y) +'.mat'
        if os.path.isfile(outfile_ens):
            continue

        if os.path.isfile(outfile_stn):
            d=io.loadmat(outfile_stn)
            data_stn=d['data_stn']
            LLE=d['LLE']
            date=d['date']
            del d
        else:
            d = nc.Dataset(file_stn)
            LLE = d['LLE'][:].data.T
            date = d['date'][:].data
            data_stn = d[varall1[v]][:].data.T
            yyyy = (date / 10000).astype(int)
            induse = (yyyy >= y) & (yyyy <= y)
            data_stn = data_stn[induse, :]
            date = date[induse]

            numv = np.sum(data_stn>-100, axis=0)
            induse = numv>=leastnum[v]
            data_stn = data_stn[:, induse]
            LLE = LLE[induse, :]

            d.close()
            data_stn[data_stn<-100] = np.nan
            io.savemat(outfile_stn,{'data_stn':data_stn, 'LLE':LLE, 'date':date}, do_compression=True)
            # np.savez_compressed(outfile_stn,data_stn=data_stn, LLE=LLE, date=date)

        # extract ensemble data
        dnum, gnum = np.shape(data_stn)
        yyyymm = (date/100).astype(int)
        data_ens = np.nan * np.zeros([dnum, gnum, ensorder[1]-ensorder[0]+1], dtype=np.float32)
        initflag = 0
        for e in range(ensorder[0]-1, ensorder[1]):
            print('year/var/ens', y, v+1, e + 1)
            for m in range(12):
                indym = yyyymm == (y*100+m+1)
                file_ens = '{}/{}/ens_{}.{:03d}.nc'.format(path_ens,y,y*100+m+1,e+1)

                d = nc.Dataset(file_ens)
                data_ense = d[varall2[v]][:].data

                # calculate the location of stations
                if initflag == 0:
                    lat = d['latitude'][:].data
                    lat = lat[:, 0]
                    lon = d['longitude'][:].data
                    lon = lon[0,:]
                    rowstn = np.zeros(gnum,dtype=int)
                    colstn = np.zeros(gnum, dtype=int)
                    for g in range(gnum):
                        diff = LLE[g, 0] - lat
                        rowstn[g] = np.nanargmin(abs(diff))
                        diff = LLE[g, 1] - lon
                        colstn[g] = np.nanargmin(abs(diff))
                    initflag = 1

                d.close()
                # extract data for every day
                for g in range(gnum):
                    data_ens[indym, g, e-ensorder[0]] = data_ense[:, rowstn[g], colstn[g]]
                # save file
        io.savemat(outfile_ens, {'data_ens': data_ens, 'year':year}, do_compression=True)
        # np.savez_compressed(outfile_ens,data_ens=data_ens, year=year)