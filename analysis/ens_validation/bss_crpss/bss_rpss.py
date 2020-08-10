# calculate Brier skill score (BSS) for precipitation
# ranked probability skill score (RPSS) for temperature

import numpy as np
import netCDF4 as nc
from scipy import io
import os, datetime


def bs(fcst, obs, thrsh):
    # Brier score for a simple pair
    # fcst: vector of ensemble forecast
    # obs: a value of observation
    # thrsh: event/no event threshold
    ind = fcst > thrsh
    fcst[ind] = 1
    fcst[~ind] = 0
    if obs > thrsh:
        obs = 1
    elif obs <= thrsh:
        obs = 0
    else:
        obs = np.nan
    bs = (np.nanmean(fcst) - obs) ** 2
    return bs

def bs_clim(prob_clim, obs, thrsh):
    if obs > thrsh:
        obs = 1
    elif obs <= thrsh:
        obs = 0
    else:
        obs = np.nan
    bs_clim = (prob_clim - obs) ** 2
    return bs_clim


def rps(fcst, obs):
    # ranked probability score
    snum = len(fcst)
    rps = np.nan
    if not np.isnan(obs):
        dd = np.nanmax(fcst) - np.nanmin(fcst)
        if dd > 0:
            bsize = dd / 20
            bins = np.arange(np.nanmin(fcst), np.nanmax(fcst)+bsize/2, bsize)
            rps = 0
            for i in range(len(bins)):
                probf = np.sum( fcst <= bins[i] ) / snum
                if obs > bins[i]:
                    probo = 1
                else:
                    probo = 0
                rps = rps + ((probf - probo) ** 2) * bsize
    return rps

def rps_clim(obs):
    snum = len(obs)
    rps_clim = np.nan * np.zeros(snum)
    bins = np.arange(np.nanmin(obs), np.nanmax(obs) + 0.05, 0.1)
    for s in range(snum):
        if not np.isnan(obs[s]):
            rps = 0
            for i in range(len(bins)):
                probf = np.sum( (obs < bins[i] + 0.05)) / snum
                if obs[s] > bins[i]:
                    probo = 1
                else:
                    probo = 0
                rps = rps + ((probf - probo) ** 2) * 0.1
    return rps_clim

Outpath='.'
gridfile = '/home/gut428/scratch/GMET/StnGridInfo/gridinfo_whole.nc'
Inpath='/home/gut428/scratch/GMET/ens_evaluation'

year=[1979, 2018]
vars=['prcp','tmean','trange']
leastnum=[200,200,200] # the least number of gauge samples so that the gauge will be included in evaluation
varnum=len(vars)
EnsNum=[1, 100]
ensnum=EnsNum[1]-EnsNum[0]+1
threshold = np.arange(0, 26, 5)
tnum = len(threshold)

# read grid information
d = nc.Dataset(gridfile)
lat = d['latitude'][:].data
lat = lat[:,0]
lon = d['longitude'][:].data
lon=lon[0,:]
elev = d['elev'][:].data

suffixall = ['']
for suffix in suffixall:
    for v in range(varnum):
        for y in range(year[0], year[1]+1):
            outfile = '{}/bss_rpss_{}_{}{}.mat'.format(Outpath, vars[v], y, suffix)
            if os.path.isfile(outfile):
                continue
            print('var/year',v, y)
            file1 = '{}/stn_{}_{}{}.mat'.format(Inpath,vars[v],y,suffix)
            file2 = '{}/ens_{}_{}{}.mat'.format(Inpath, vars[v], y,suffix)
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
            month = (np.mod(date_ymd,10000)/100).astype(int)

            # calculate bss for precipitation
            if vars[v] == 'prcp':
                bss_out = np.nan * np.zeros([gnum, tnum])
                bs_out = np.nan * np.zeros([gnum, tnum])
                bs_clim_out = np.nan * np.zeros([gnum, tnum])
                for t in range(tnum):
                    print('bss t',t)
                    for g in range(gnum):
                        bsg = np.nan * np.zeros(dnum)
                        bsg_clim = np.nan * np.zeros(dnum)
                        prob_clim = np.sum(data_stn[:, g] > threshold[t]) / np.sum(data_stn[:, g] >= 0)
                        if prob_clim != 0:
                            for d in range(dnum):
                                bsg[d] = bs(data_ens[d, g, :].copy(), data_stn[d, g].copy(), threshold[t])
                                bsg_clim[d] = bs_clim(prob_clim, data_stn[d, g].copy(), threshold[t])
                            bsg_clim[np.isnan(bsg)] = np.nan
                            bs_out[g, t] = np.nanmean(bsg)
                            bs_clim_out[g, t] = np.nanmean(bsg_clim)
                            bss_out[g, t] = 1 - bs_out[g, t] / bs_clim_out[g, t]
                io.savemat(outfile, {'bss': bss_out,'bs':bs_out,'bs_clim':bs_clim_out,'LLE':LLE}, do_compression=True)

            # calculate rpss for temperature
            if vars[v] == 'tmean' or vars[v] == 'trange':
                rpss_out = np.nan * np.zeros(gnum)
                rps_out = np.nan * np.zeros(gnum)
                rps_clim_out = np.nan * np.zeros(gnum)

                obs_clim = np.nan * np.zeros([12,gnum])
                for m in range(12):
                    indm = month == m+1
                    obs_clim[m, :] = np.nanmean(data_stn[indm, :], axis=0)

                for g in range(gnum):
                    rpsg = np.zeros(dnum)
                    rpsg_clim = np.zeros(dnum)
                    # obs_clim = np.nanmean(data_stn[:, g])
                    for d in range(dnum):
                        rpsg[d] = rps(data_ens[d, g, :].copy(), data_stn[d, g].copy())
                        # if d < 15:
                        #     obs_clim = np.nanmean(data_stn[0:31, g])
                        # elif d > dnum - 15:
                        #     obs_clim = np.nanmean(data_stn[-31:, g])
                        # else:
                        #     obs_clim = np.nanmean(data_stn[d-15:d+15, g])
                        rpsg_clim[d] = (obs_clim[month[d]-1, g]-data_stn[d, g]) ** 2
                    rps_out[g] = np.nanmean(rpsg)
                    rps_clim_out[g] = np.nanmean(rpsg_clim)
                    rpss_out[g] = 1 - rps_out[g] / rps_clim_out[g]
                io.savemat(outfile, {'rpss': rpss_out,'rps':rps_out,'rps_clim':rps_clim_out,'LLE':LLE}, do_compression=True)
