# correct the bias in reanalysis products and merge different reanalysis products

# import numpy as np
# import auxiliary as au
# from matplotlib import pyplot as plt
from scipy import io
import os
# import sys
# import h5py
# import time
# import random
# import datetime
from bma_merge import bma
from auxiliary_merge import *


def empirical_cdf(data, probtar):
    # data: vector of data
    data2 = data[~np.isnan(data)]
    if len(data2) > 0:
        ds = np.sort(data2)
        probreal = np.arange(len(data2)) / (len(data2) + 1)
        ecdf_out = np.interp(probtar, probreal, ds)
    else:
        ecdf_out = np.nan * np.zeros(len(probtar))
    return ecdf_out


def cdf_correction(cdf_ref, value_ref, cdf_raw, value_raw, value_tar):
    prob_tar = np.interp(value_tar, value_raw, cdf_raw)
    value_out = np.interp(prob_tar, cdf_ref, value_ref)
    return value_out


def calculate_anomaly(datatar, dataref, hwsize, amode, upbound=5, lowbound=0.2):
    # datatar, dataref: 2D [nstn, ntime]
    # amode: anomaly mode ('ratio' or 'diff')
    # hwsize: define time window (2*hwsize+1) used to calculate ratio (as ratio for a specific day is too variable)
    # upbound/lowbound: upper and lower limitation of ratio/difference
    if np.ndim(datatar) == 1:  # only one time step
        datatar = datatar[:, np.newaxis]
        dataref = dataref[:, np.newaxis]

    nstn, ntime = np.shape(datatar)
    if ntime < hwsize * 2 + 1:
        print('The window size is larger than time steps when calculating ratio between tar and ref datasets')
        print('Please set a smaller hwsize')
        sys.exit()

    anom = np.ones([nstn, ntime])

    for i in range(ntime):
        if i < hwsize:
            windex = np.arange(hwsize * 2 + 1)
        elif i >= ntime - hwsize:
            windex = np.arange(ntime - hwsize * 2 - 1, ntime)
        else:
            windex = np.arange(i - hwsize, i + hwsize + 1)
        dtari = np.nanmean(datatar[:, windex], axis=1)
        drefi = np.nanmean(dataref[:, windex], axis=1)

        if amode == 'ratio':
            temp = drefi / dtari
            temp[(dtari == 0) & (drefi == 0)] = 1
            anom[:, i] = temp
        elif amode == 'diff':
            anom[:, i] = drefi - dtari
        else:
            sys.exit('Unknow amode. Please use either ratio or diff')

    anom[anom > upbound] = upbound
    anom[anom < lowbound] = lowbound
    return anom


def findnearstn(stnlat, stnlon, tarlat, tarlon, nearnum, noself):
    # only use lat/lon to find near stations without considering distance in km
    # stnlat/stnlon: 1D
    # tarlat/tarlon: 1D or 2D
    # noself: 1--stnlat and tarlat have overlapped stations, which should be excluded from stnlat

    stnll = np.zeros([len(stnlat), 2])
    stnll[:, 0] = stnlat
    stnll[:, 1] = stnlon

    if len(np.shape(tarlat)) == 1:
        num = len(tarlat)
        nearstn_loc = -1 * np.ones([num, nearnum], dtype=int)
        nearstn_dist = -1 * np.ones([num, nearnum], dtype=float)
        for i in range(num):
            if np.mod(i, 100) == 0:
                print('station', i, nstn)
            if np.isnan(tarlat[i]) or np.isnan(tarlon[i]):
                continue
            tari = np.array([tarlat[i], tarlon[i]])
            dist = au.distance(tari, stnll)
            dist[np.isnan(dist)] = 1000000000
            if noself == 1:
                dist[dist == 0] = np.inf  # may not be perfect, but work for SCDNA
            indi = np.argsort(dist)
            nearstn_loc[i, :] = indi[0:nearnum]
            nearstn_dist[i, :] = dist[nearstn_loc[i, :]]
    elif len(np.shape(tarlat)) == 2:
        nrows, ncols = np.shape(tarlat)
        nearstn_loc = -1 * np.ones([nrows, ncols, nearnum], dtype=int)
        nearstn_dist = -1 * np.ones([nrows, ncols, nearnum], dtype=float)
        for r in range(nrows):
            print('rows', r, nrows)
            for c in range(ncols):
                if np.isnan(tarlat[r, c]) or np.isnan(tarlon[r, c]):
                    continue
                tari = np.array([tarlat[r, c], tarlon[r, c]])
                dist = au.distance(tari, stnll)
                dist[np.isnan(dist)] = 1000000000
                indi = np.argsort(dist)
                nearstn_loc[r, c, :] = indi[0:nearnum]
                nearstn_dist[r, c, :] = dist[nearstn_loc[r, c, :]]
    else:
        print('The dimensions of tarlat or tarlon are larger than 2')
        sys.exit()

    return nearstn_loc, nearstn_dist


def error_correction_stn(corrmode, stndata_i2_near, nearstn_weighti2, readata_stn_i2, readata_i2_near, ecdf_prob):
    # corrmode: QM, Mul_Climo, Mul_Daily, Add_Climo, Add_Climo
    nearstn_numi2, ntimes = np.shape(stndata_i2_near)
    corrdata_out = np.zeros(ntimes)
    if corrmode == 'QM':
        cdf_rea = empirical_cdf(readata_stn_i2, ecdf_prob)
        for j in range(nearstn_numi2):
            cdf_ref = empirical_cdf(stndata_i2_near[j, :], ecdf_prob)
            qmdata_rj = cdf_correction(ecdf_prob, cdf_ref, ecdf_prob, cdf_rea, readata_stn_i2)
            corrdata_out = corrdata_out + qmdata_rj * nearstn_weighti2[j]
        corrdata_out = corrdata_out / np.sum(nearstn_weighti2)
    elif corrmode[0:3] == 'Mul' or corrmode[0:3] == 'Add':
        # multplicative correction or additive correction
        if corrmode[4:] == 'Daily':
            dtar = readata_i2_near
            dref = stndata_i2_near
        elif corrmode[4:] == 'Climo':
            dtar = np.nanmean(readata_i2_near, axis=1)
            dtar = dtar[:, np.newaxis]
            dref = np.nanmean(stndata_i2_near, axis=1)
            dref = dref[:, np.newaxis]
        else:
            sys.exit('Unknown corrmode')
        if corrmode[0:3] == 'Mul':
            corrfactor_i2_near = calculate_anomaly(dtar, dref, 0, 'ratio', 10, 0)  # 10 is default max limit
        else:
            corrfactor_i2_near = calculate_anomaly(dtar, dref, 0, 'diff', 9999, -9999)
        weight_use = np.tile(nearstn_weighti2, (np.shape(corrfactor_i2_near)[1], 1)).T
        weight_use[np.isnan(corrfactor_i2_near)] = np.nan
        corrfactor_i2 = np.nansum(corrfactor_i2_near * weight_use, axis=0) / np.nansum(weight_use)
        if corrmode[0:3] == 'Mul':
            corrdata_out = readata_stn_i2 * corrfactor_i2
        else:
            corrdata_out = readata_stn_i2 + corrfactor_i2
    else:
        sys.exit('Unknown corrmode')

    return corrdata_out


def error_correction(dataori, anomaly, mode='ratio'):
    # default: time is the last dimension
    if mode == 'ratio':
        datacorr = dataori * anomaly
    elif mode == 'diff':
        datacorr = dataori + anomaly
    else:
        sys.exit('Wrong error correction mode')
    return datacorr


def calweight(obs, rea, mode, preprocess=True):
    ntimes, reanum = np.shape(rea)
    if preprocess:
        # delete the nan values
        ind_nan = np.isnan(obs + np.sum(rea, axis=1))
        obs = obs[~ind_nan]
        rea = rea[~ind_nan, :]

    if len(obs) > 2:
        if mode == 'BMA':
            weight, sigma, sigma_s = bma(rea, obs)
        else:
            met = np.zeros(reanum)
            if mode == 'RMSE':
                for i in range(reanum):
                    met[i] = np.sqrt(np.sum(np.square(obs - rea[:, i])) / len(obs))  # RMSE
                weight = 1 / (met ** 2)
            elif mode == 'CC':
                for i in range(reanum):
                    met[i] = np.corrcoef(obs, rea[:, i])[0][1]
                weight = (met ** 2)
    else:
        weight = np.ones(reanum) / reanum
    if np.any(np.isnan(weight)):
        weight = np.ones(reanum) / reanum
    return weight


def weightmerge(data, weight):
    if np.ndim(data) == 2:
        weight2 = weight.copy()
        weight2[np.isnan(data)] = np.nan
        dataout = np.nansum(data * weight2, axis=1) / np.nansum(weight2, axis=1)
    elif np.ndim(data) == 3:
        weight2 = weight.copy()
        weight2[np.isnan(data)] = np.nan
        dataout = np.nansum(data * weight2, axis=2) / np.nansum(weight2, axis=2)
        dataout[np.isnan(data[:, :, 0])] = np.nan
    return dataout


def correction_merge_stn(stndata, ecdf_prob, readata_stn, nearstn_loc, nearstn_dist, var, corrmode, weightmode):
    # corrmode = 'QM'  # QM, Mul_Climo, Mul_Daily, Add_Climo, Add_Climo
    # use 2-layer cross-validation to estimate the weight and independent data of merge/correction data
    reanum, nstn, ntimes = np.shape(readata_stn)

    # initialization
    reacorr_stn = np.nan * np.zeros([reanum, nstn, ntimes], dtype=np.float32)  # corrected reanalysis data
    reamerge_weight_stn = np.nan * np.zeros([nstn, reanum], dtype=np.float32)  # weight used to obtain reamerge_stn
    reamerge_stn = np.nan * np.zeros([nstn, ntimes], dtype=np.float32)  # merged reanalysis at station points

    for i1 in range(nstn):  # layer-1
        if np.mod(i1, 1000) == 0:
            print(i1)
        if np.isnan(stndata[i1, 0]):
            continue
        nearstn_loci1 = nearstn_loc[i1, :]
        nearstn_disti1 = nearstn_dist[i1, :]
        induse = nearstn_loci1 > -1
        nearstn_loci1 = nearstn_loci1[induse]
        nearstn_disti1 = nearstn_disti1[induse]
        nearstn_numi1 = len(nearstn_loci1)
        if nearstn_numi1 == 0:
            sys.exit('No near station for the target station (layer-1)')

        # start layer-2
        reamerge_weight_i2 = np.zeros([nearstn_numi1, reanum])
        for i2 in range(nearstn_numi1):  # layer-2
            nearstn_loci2 = nearstn_loc[nearstn_loci1[i2], :]
            nearstn_disti2 = nearstn_dist[nearstn_loci1[i2], :]
            induse = (nearstn_loci2 > -1) & (nearstn_loci2 != i1)  # i1 should be independent
            nearstn_loci2 = nearstn_loci2[induse]
            nearstn_disti2 = nearstn_disti2[induse]
            maxd = np.max([np.max(nearstn_disti2) + 1, 100])
            nearstn_weighti2 = au.distanceweight(nearstn_disti2, maxd, 3)
            nearstn_weighti2 = nearstn_weighti2 / np.sum(nearstn_weighti2)

            nearstn_numi2 = len(nearstn_loci2)
            if nearstn_numi2 == 0:
                sys.exit('No near station for the target station (layer-1)')

            # data at i2 station
            stndata_i2 = stndata[nearstn_loci1[i2], :]
            stndata_i2_near = stndata[nearstn_loci2, :]
            readata_stn_i2 = readata_stn[:, nearstn_loci1[i2], :]
            readata_i2_near = readata_stn[:, nearstn_loci2, :]

            # error correction for each reanalysis dataset using different modes
            corrdata_i2 = np.zeros([ntimes, reanum])
            for r in range(reanum):
                corrdata_i2[:, r] = error_correction_stn(corrmode, stndata_i2_near, nearstn_weighti2,
                                                         readata_stn_i2[r, :], readata_i2_near[r, :, :], ecdf_prob)

            # calculate merging weight for i2
            if weightmode == 'BMA' and var == 'prcp':
                # exclude zero precipitation and carry out box-cox transformation
                datatemp = np.zeros([ntimes, reanum + 1])
                datatemp[:, 0] = stndata_i2
                datatemp[:, 1:] = corrdata_i2
                ind0 = np.sum(datatemp >= 0.01, axis=1) == (reanum + 1)  # positive hit events
                dobs = box_cox_transform(stndata_i2[ind0])
                drea = box_cox_transform(corrdata_i2[ind0, :])
            else:
                dobs = stndata_i2
                drea = corrdata_i2
            reamerge_weight_i2[i2, :] = calweight(dobs, drea, weightmode)
        # end layer-2

        stndata_i1 = stndata[i1, :]
        stndata_i1_near = stndata[nearstn_loci1, :]
        readata_stn_i1 = readata_stn[:, i1, :]
        readata_i1_near = readata_stn[:, nearstn_loci1, :]
        maxd = np.max([np.max(nearstn_disti1) + 1, 100])
        nearstn_weighti1 = au.distanceweight(nearstn_disti1, maxd, 3)
        nearstn_weighti1 = nearstn_weighti1 / np.sum(nearstn_weighti1)

        # get corrected data at i1
        corrdata_i1 = np.zeros([ntimes, reanum])
        for r in range(reanum):
            corrdata_i1[:, r] = error_correction_stn(corrmode, stndata_i1_near, nearstn_weighti1,
                                                     readata_stn_i1[r, :], readata_i1_near[r, :, :], ecdf_prob)
        reacorr_stn[:, i1, :] = corrdata_i1.T

        # get merging weight at i1 and merge reanalysis
        # note: this weight is just for independent merging so we can estimate the error of merged reanalysis
        # the real weight will be estimated using just one-layer cross-validation
        weight_use = np.tile(nearstn_weighti1, (reanum, 1)).T
        weight_i1 = np.sum(weight_use * reamerge_weight_i2, axis=0)
        weight_i1 = weight_i1 / np.sum(weight_i1)

        weight_use = np.tile(weight_i1, (ntimes, 1))
        weight_use[np.isnan(corrdata_i1)] = np.nan
        # if weightmode == 'BMA' and var == 'prcp':
        #     # the merging after box-cox transformation underestimates precipitation in southeast US
        #     # and the rationality of box-cox should be revisited
        #     reamerge_stni1 = np.nansum(weight_use * box_cox_transform(corrdata_i1), axis=1) / np.nansum(weight_use, axis=1)
        #     reamerge_stni1 = box_cox_recover(reamerge_stni1)
        # else:
        #     reamerge_stni1 = np.nansum(weight_use * corrdata_i1, axis=1) / np.nansum(weight_use, axis=1)
        reamerge_stni1 = np.nansum(weight_use * corrdata_i1, axis=1) / np.nansum(weight_use, axis=1)
        reamerge_stn[i1, :] = reamerge_stni1

        # get the final merging weight
        if weightmode == 'BMA' and var == 'prcp':
            # exclude zero precipitation and carry out box-cox transformation
            datatemp = np.zeros([ntimes, reanum + 1])
            datatemp[:, 0] = stndata_i1
            datatemp[:, 1:] = corrdata_i1
            ind0 = np.sum(datatemp >= 0.01, axis=1) == (reanum + 1)  # positive hit events
            dobs = box_cox_transform(stndata_i1[ind0])
            drea = box_cox_transform(corrdata_i1[ind0, :])
        else:
            dobs = stndata_i1
            drea = corrdata_i1
        reamerge_weight_stn[i1, :] = calweight(dobs, drea, weightmode)

    # note: reamerge_weight_stn is the final merging weight, and reacorr_stn is the final corrected data
    # but reamerge_stn is just independent merging estimates which is calculated from 2-layer cross validation
    return reamerge_stn, reamerge_weight_stn, reacorr_stn


def correction_rea(stndata, ecdf_prob, readata_stn, nearstn_loc, nearstn_dist, corrmode):
    # compare the performance of daily-scale multiplicative correction and QM
    reanum, nstn, ntimes = np.shape(readata_stn)
    nprob = len(ecdf_prob)

    # initialization
    reacorr = np.nan * np.zeros([reanum, nstn, ntimes], dtype=np.float32)  # corrected reanalysis data

    for i1 in range(nstn):  # layer-1
        # if np.mod(i1, 1000) == 0:
        #     print(i1)
        if np.isnan(stndata[i1, 0]):
            continue

        nearstn_loci1 = nearstn_loc[i1, :]
        nearstn_disti1 = nearstn_dist[i1, :]
        induse = nearstn_loci1 > -1
        nearstn_loci1 = nearstn_loci1[induse]
        nearstn_disti1 = nearstn_disti1[induse]
        nearstn_numi1 = len(nearstn_loci1)
        if nearstn_numi1 == 0:
            sys.exit('No near station for the target station (layer-1)')

        stndata_i1_near = stndata[nearstn_loci1, :]
        readata_stn_i1 = readata_stn[:, i1, :]
        readata_i1_near = readata_stn[:, nearstn_loci1, :]
        maxd = np.max([np.max(nearstn_disti1) + 1, 100])
        nearstn_weighti1 = au.distanceweight(nearstn_disti1, maxd, 3)
        nearstn_weighti1 = nearstn_weighti1 / np.sum(nearstn_weighti1)

        # get corrected data at i1
        corrdata_i1 = np.zeros([ntimes, reanum])
        for r in range(reanum):
            corrdata_i1[:, r] = error_correction_stn(corrmode, stndata_i1_near, nearstn_weighti1,
                                                     readata_stn_i1[r, :], readata_i1_near[r, :, :], ecdf_prob)
        reacorr[:, i1, :] = corrdata_i1.T

    return reacorr


########################################################################################################################
# time periods and methods
# var = 'prcp'  # ['prcp', 'tmean', 'trange']: this should be input from sbtach script
# weightmode for merging: (CC, RMSE, BMA): Weight = CC**2, or Weight = 1/RMSE**2, or Weight = BMA
# corrmode: QM, Mul_Climo, Mul_Daily, Add_Climo, Add_Climo
# year range for merging. note weight is calculated using all data not limited by year

# read from inputs
var = sys.argv[1]
weightmode = sys.argv[2]
corrmode = sys.argv[3]
y1 = int(sys.argv[4])
y2 = int(sys.argv[5])
year = [y1, y2]

# embeded
# var = 'prcp'
# weightmode = 'BMA'
# corrmode = 'QM'
# y1 = 2017
# y2 = 2018
# year = [y1, y2]

print('var is ', var)
print('weightmode is ', weightmode)
print('years are ', y1, y2)

########################################################################################################################

# basic settings
nearnum = 10  # the number of nearby stations used to extrapolate points to grids (for correction and merging)
prefix = ['ERA5_', 'MERRA2_', 'JRA55_']

# ### Local Mac settings
# # input files/paths
# gmet_stnfile = '/Users/localuser/Research/EMDNA/basicinfo/stnlist_whole.txt'
# gmet_stndatafile = '/Users/localuser/Research/EMDNA/stndata_whole.npz'
# file_mask = './DEM/NA_DEM_010deg_trim.mat'
# path_readowngrid = ['/Users/localuser/Research/EMDNA/downscale/ERA5',  # downscaled gridded data
#                     '/Users/localuser/Research/EMDNA/downscale/MERRA2',
#                     '/Users/localuser/Research/EMDNA/downscale/JRA55']
# file_readownstn = ['/Users/localuser/Research/EMDNA/downscale/ERA5_downto_stn_nearest.npz', # downscaled to stn points
#                    '/Users/localuser/Research/EMDNA/downscale/MERRA2_downto_stn_nearest.npz',
#                    '/Users/localuser/Research/EMDNA/downscale/JRA55_downto_stn_nearest.npz']
# # file_readownstn = ['/Users/localuser/Research/EMDNA/downscale/JRA55_downto_stn_nearest.npz']
#
# # output files/paths (can also be used as inputs once generated)
# near_path = '/Users/localuser/Research/EMDNA/correction'  # path to save near station for each grid/cell
# path_reacorr = '/Users/localuser/Research/EMDNA/correction' # path to save corrected reanalysis data at station points
# path_merge = '/Users/localuser/Research/EMDNA/merge'
# path_ecdf = '/Users/localuser/Research/EMDNA/merge/ECDF'
# ### Local Mac settings


### Plato settings
# input files/paths
gmet_stnfile = '/datastore/GLOBALWATER/CommonData/EMDNA_new/StnGridInfo/stnlist_whole.txt'
gmet_stndatafile = '/datastore/GLOBALWATER/CommonData/EMDNA_new/stndata_aftercheck.npz'
file_mask = '/datastore/GLOBALWATER/CommonData/EMDNA_new/DEM/NA_DEM_010deg_trim.mat'
path_readowngrid = ['/datastore/GLOBALWATER/CommonData/EMDNA_new/ERA5_day_ds',  # downscaled gridded data
                    '/datastore/GLOBALWATER/CommonData/EMDNA_new/MERRA2_day_ds',
                    '/datastore/GLOBALWATER/CommonData/EMDNA_new/JRA55_day_ds']
file_readownstn = ['/datastore/GLOBALWATER/CommonData/EMDNA_new/ERA5_day_ds/ERA5_downto_stn_GWR.npz',
                   # downscaled to stn points
                   '/datastore/GLOBALWATER/CommonData/EMDNA_new/MERRA2_day_ds/MERRA2_downto_stn_GWR.npz',
                   '/datastore/GLOBALWATER/CommonData/EMDNA_new/JRA55_day_ds/JRA55_downto_stn_GWR.npz']
file_nearstn = '/datastore/GLOBALWATER/CommonData/EMDNA_new/stn_reg_aftercheck/nearstn_catalog.npz'

# output files/paths (can also be used as inputs once generated)
near_path = '/home/gut428/ReanalysisCorrMerge'  # path to save near station for each grid/cell
path_reacorr = '/home/gut428/ReanalysisCorrMerge/Reanalysis_corr'  # path to save corrected reanalysis data at station points
path_merge = '/home/gut428/ReanalysisCorrMerge/Reanalysis_merge'
path_ecdf = '/datastore/GLOBALWATER/CommonData/EMDNA_new/ReanalysisCorrMerge/ECDF'
### Plato settings


file_corrmerge_stn = path_merge + '/mergecorr_stn_' + var + '_GWRQM_' + weightmode + '.npz'  # file of indepedent corrected/merging data and merging weights

########################################################################################################################

# basic processing
print('start basic processing')

lontar = np.arange(-180 + 0.05, -50, 0.1)
lattar = np.arange(85 - 0.05, 5, -0.1)

# mask
mask = io.loadmat(file_mask)
mask = mask['DEM']
mask[~np.isnan(mask)] = 1  # 1: valid pixels

# meshed lat/lon of the target region
reanum = len(file_readownstn)
nrows, ncols = np.shape(mask)
lontarm, lattarm = np.meshgrid(lontar, lattar)
lontarm[np.isnan(mask)] = np.nan
lattarm[np.isnan(mask)] = np.nan

# date list
date_list, date_number = m_DateList(1979, 2018, 'ByYear')

# load observations for all stations
datatemp = np.load(gmet_stndatafile)
stndata = datatemp[var + '_stn']
stnlle = datatemp['stn_lle']
nstn, ntimes = np.shape(stndata)
del datatemp

# probability bins for QM
binprob = 500
ecdf_prob = np.arange(0, 1 + 1 / binprob, 1 / binprob)

########################################################################################################################

# find near stations
# find near stations for all stations
if not os.path.isfile(file_nearstn):
    print(file_nearstn, 'does not exist')
    sys.exit()
datatemp = np.load(file_nearstn)
if var == 'prcp':
    nearstn_loc = datatemp['near_stn_prcpLoc'][:, 0:nearnum]
    nearstn_dist = datatemp['near_stn_prcpDist'][:, 0:nearnum]
    neargrid_loc = datatemp['near_grid_prcpLoc'][:, :, 0:nearnum]
    neargrid_dist = datatemp['near_grid_prcpDist'][:, :, 0:nearnum]
else:
    nearstn_loc = datatemp['near_stn_tempLoc'][:, 0:nearnum]
    nearstn_dist = datatemp['near_stn_tempDist'][:, 0:nearnum]
    neargrid_loc = datatemp['near_grid_tempLoc'][:, :, 0:nearnum]
    neargrid_dist = datatemp['near_grid_tempDist'][:, :, 0:nearnum]

# this is because of the inverse latitude rule
neargrid_loc = np.flipud(neargrid_loc)
neargrid_dist = np.flipud(neargrid_dist)

########################################################################################################################

# load downscaled reanalysis at station points
print('load downscaled reanalysis data at station points')
readata_stn = np.nan * np.zeros([reanum, nstn, ntimes], dtype=np.float32)
for rr in range(reanum):
    dr = np.load(file_readownstn[rr])
    temp = dr[var + '_readown']
    readata_stn[rr, :, :] = temp
    del dr, temp
if var == 'prcp':
    readata_stn[readata_stn < 0] = 0

########################################################################################################################

# correction reanalysis at station points
# this step is to support comparison between different methods. In practice, this step is not very necessary.

# filecorrstn = path_reacorr + '/corrstn_nearest_' + var + '_' + corrmode + '.npz'
# if not os.path.isfile(filecorrstn):
#     reacorr_stn = np.nan * np.zeros([reanum, nstn, ntimes], dtype=np.float32)
#     for m in range(12):
#         print('month', m + 1)
#         indm = date_number['mm'] == (m + 1)
#         corrm = correction_rea(stndata[:, indm], ecdf_prob, readata_stn[:, :, indm],
#                                nearstn_loc, nearstn_dist, corrmode)
#         reacorr_stn[:, :, indm] = corrm
#         np.savez_compressed(filecorrstn, reacorr_stn=reacorr_stn)

########################################################################################################################

# get merged and corrected reanalysis data at all station points using two-layer cross-validation

if os.path.isfile(file_corrmerge_stn):
    print('load independent merged/corrected data at station points')
    datatemp = np.load(file_corrmerge_stn)
    reamerge_stn = datatemp['reamerge_stn']
    reamerge_weight_stn = datatemp['reamerge_weight_stn']
    reacorr_stn = datatemp['reacorr_stn']
    del datatemp
else:
    print('calculate independent merged/corrected data at station points')
    reamerge_stn = np.nan * np.zeros([nstn, ntimes], dtype=np.float32)
    reamerge_weight_stn = np.nan * np.zeros([12, nstn, reanum], dtype=np.float32)
    reacorr_stn = np.nan * np.zeros([reanum, nstn, ntimes], dtype=np.float32)
    # for each month
    for m in range(12):
        print('month', m + 1)
        indm = date_number['mm'] == (m + 1)
        reamerge_stnm, reamerge_weight_stnm, reacorr_stnm = \
            correction_merge_stn(stndata[:, indm], ecdf_prob, readata_stn[:, :, indm], nearstn_loc, nearstn_dist,
                                 var, corrmode, weightmode)
        reamerge_stn[:, indm] = reamerge_stnm
        reacorr_stn[:, :, indm] = reacorr_stnm
        reamerge_weight_stn[m, :, :] = reamerge_weight_stnm

    # the variables are independent with their concurrent stations. thus, station data can be used to evaluate them
    np.savez_compressed(file_corrmerge_stn, reamerge_stn=reamerge_stn, reamerge_weight_stn=reamerge_weight_stn,
                        reacorr_stn=reacorr_stn, date_list=date_list)

########################################################################################################################

# if QM is used, we have to derive the CDF curve for all grids before correction
print('Calculate ecdf of station and reanalysis if files are not generated')
for m in range(12):
    indm = date_number['mm'] == (m + 1)

    # calculate the ecdf of station data
    file_ecdf = path_ecdf + '/ecdf_stn_' + var + '_month_' + str(m + 1) + '.npz'
    if not os.path.isfile(file_ecdf):
        print('month', m + 1, 'estimate ecdf of stations')
        ecdf_stn = np.nan * np.zeros([nstn, binprob + 1], dtype=np.float32)
        for i in range(nstn):
            if not np.isnan(stndata[i, 0]):
                ecdf_stn[i, :] = empirical_cdf(stndata[i, indm], ecdf_prob)
        np.savez_compressed(file_ecdf, ecdf=ecdf_stn, prob=ecdf_prob, stnlle=stnlle)
        del ecdf_stn

    # calculate the ecdf of reanalysis data
    for rr in range(reanum):
        file_ecdf = path_ecdf + '/ecdf_' + prefix[rr] + var + '_month_' + str(m + 1) + '.npz'
        if os.path.isfile(file_ecdf):
            continue
        print('month', m + 1, 'estimate ecdf of reanalysis', rr + 1, '/', reanum)
        # read raw gridded reanalysis data
        datam_rea = np.nan * np.zeros([nrows, ncols, np.sum(indm)], dtype=np.float32)
        flag = 0
        for y in range(1979, 2019):
            mmy = date_number['mm'].copy()
            mmy = mmy[date_number['yyyy'] == y]
            indmmy = mmy == (m + 1)
            mmdays = np.sum(indmmy)
            if not (prefix[rr] == 'MERRA2_' and y == 1979):
                filer = path_readowngrid[rr] + '/' + prefix[rr] + 'ds_' + var + '_' + str(y * 100 + m + 1) + '.npz'
                d = np.load(filer)
                datam_rea[:, :, flag:flag + mmdays] = d['data']
                del d
            flag = flag + mmdays

        # calculate ecdf
        ecdf_rea = np.nan * np.zeros([nrows, ncols, binprob + 1], dtype=np.float32)
        for i in range(nrows):
            for j in range(ncols):
                if not np.isnan(mask[i, j]):
                    ecdf_rea[i, j, :] = empirical_cdf(datam_rea[i, j, :], ecdf_prob)

        np.savez_compressed(file_ecdf, ecdf=ecdf_rea, prob=ecdf_prob)
        del ecdf_rea

########################################################################################################################

# interpolate merging weights to grids
filebma_merge_weight = path_merge + '/mergeweight_' + var + '_' + weightmode + '.npz'
if os.path.isfile(filebma_merge_weight):
    print('Load merging weight')
    datatemp = np.load(filebma_merge_weight)
    reamerge_weight_grid = datatemp['reamerge_weight_grid']
    del datatemp
else:
    print('Interpolate merging weight')
    reamerge_weight_grid = np.nan * np.zeros([12, reanum, nrows, ncols], dtype=np.float32)
    for m in range(12):
        for rr in range(reanum):
            reamerge_weight_grid[m, rr, :, :] = extrapolation(reamerge_weight_stn[m, :, rr], neargrid_loc,
                                                              neargrid_dist)
    np.savez_compressed(filebma_merge_weight, reamerge_weight_grid=reamerge_weight_grid, reaname=prefix,
                        latitude=lattar, longitude=lontar)

########################################################################################################################

# start final correction and merging
# QM-based correction
# BMA-based merging

# process for each month
for m in range(11, 12):
    print('Correction and Merge: month', m + 1)

    # load ecdf of stations and reanalysis for this month
    print('load ecdf data')
    file_ecdf = path_ecdf + '/ecdf_stn_' + var + '_month_' + str(m + 1) + '.npz'
    datatemp = np.load(file_ecdf)
    ecdf_stn = datatemp['ecdf']
    del datatemp
    ecdf_rea = np.nan * np.zeros([reanum, nrows, ncols, binprob + 1], dtype=np.float32)
    for rr in range(reanum):
        file_ecdf = path_ecdf + '/ecdf_' + prefix[rr] + var + '_month_' + str(m + 1) + '.npz'
        datatemp = np.load(file_ecdf)
        ecdf_rea[rr, :, :, :] = datatemp['ecdf']
        del datatemp

    # correction and merging for each year
    for y in range(year[0], year[1] + 1):
        print('Year', y)
        filebma_merge = path_merge + '/bmamerge_' + var + '_' + str(y * 100 + m + 1) + '.npz'
        filecorr = path_reacorr + '/reacorrdata_' + var + '_' + str(y * 100 + m + 1) + '.npz'
        if os.path.isfile(filebma_merge) and os.path.isfile(filecorr):
            print('file exists ... continue')
            continue

        # date processing
        mmy = date_number['mm'].copy()
        mmy = mmy[date_number['yyyy'] == y]
        indmmy = mmy == (m + 1)
        indmmy2 = (date_number['yyyy'] == y) & (date_number['mm'] == m + 1)
        mmdays = np.sum(indmmy)

        # read raw gridded reanalysis data
        readata_raw = np.nan * np.zeros([reanum, nrows, ncols, mmdays], dtype=np.float32)
        for rr in range(reanum):
            if not (prefix[rr] == 'MERRA2_' and y == 1979):
                filer = path_readowngrid[rr] + '/' + prefix[rr] + 'ds_' + var + '_' + str(y * 100 + m + 1) + '.npz'
                d = np.load(filer)
                readata_raw[rr, :, :, :] = d['data']
                del d

        ################################################################################################################
        print('Reanalysis correction')
        # start QM-based error correction
        if os.path.isfile(filecorr):
            datatemp = np.load(filecorr)
            corr_data = datatemp['corr_data']
            corr_error = datatemp['corr_error']
            del datatemp
        else:
            # initialization
            corr_data = np.nan * np.zeros([reanum, nrows, ncols, mmdays], dtype=np.float32)
            corr_error = np.nan * np.zeros([reanum, nrows, ncols, mmdays], dtype=np.float32)

            # (1) estimate the error of corrected data by interpolating stations
            for rr in range(reanum):
                corr_error[rr, :, :, :] = extrapolation(reacorr_stn[rr, :, indmmy2].T - stndata[:, indmmy2],
                                                        neargrid_loc, neargrid_dist)

            # (2) estimate the value of corrected data
            # error correction
            for rr in range(reanum):
                if (prefix[rr] == 'MERRA2_' and y == 1979):
                    continue
                for r in range(nrows):
                    for c in range(ncols):
                        if np.isnan(mask[r, c]):
                            continue
                        nearloc_rc = neargrid_loc[r, c, :]
                        neardist_rc = neargrid_dist[r, c, :]
                        maxdist = np.max([np.max(neardist_rc) + 1, 100])
                        nearweight_rc = au.distanceweight(neardist_rc, maxdist, 4)
                        nearweight_rc = np.tile(nearweight_rc, [mmdays, 1]).T

                        reacorr_rc = np.zeros([nearnum, mmdays])
                        for i in range(nearnum):
                            reacorr_rc[i, :] = cdf_correction(ecdf_prob, ecdf_stn[nearloc_rc[i], :],
                                                              ecdf_prob, ecdf_rea[rr, r, c, :],
                                                              readata_raw[rr, r, c, :])
                        nearweight_rc[np.isnan(reacorr_rc)] = np.nan
                        corr_data[rr, r, c, :] = \
                            np.nansum(reacorr_rc * nearweight_rc, axis=0) / np.nansum(nearweight_rc, axis=0)

            np.savez_compressed(filecorr, corr_data=corr_data, corr_error=corr_error,
                                reaname=prefix, latitude=lattar, longitude=lontar)

            del corr_error, readata_raw
        ################################################################################################################
        print('Reanalysis merging')
        # start BMA-based merging
        if not os.path.isfile(filebma_merge):
            # initialization
            bma_data = np.nan * np.zeros([nrows, ncols, mmdays], dtype=np.float32)
            # bma_error = np.nan * np.zeros([nrows, ncols, mmdays], dtype=np.float32)

            # (1) estimate the error of corrected data by interpolating stations
            bma_error = extrapolation(reamerge_stn[:, indmmy2] - stndata[:, indmmy2], neargrid_loc, neargrid_dist)

            # (2) estimate the value of merged data
            reamerge_weight_gridm = reamerge_weight_grid[m, :, :, :].copy()
            for i in range(mmdays):
                datai = corr_data[:, :, :, i]
                weighti = reamerge_weight_gridm.copy()
                weighti[np.isnan(datai)] = np.nan
                bma_data[:, :, i] = np.nansum(weighti * datai, axis=0) / np.nansum(weighti, axis=0)
            np.savez_compressed(filebma_merge, bma_data=bma_data, bma_error=bma_error,
                                reaname=prefix, latitude=lattar, longitude=lontar)

            del bma_error, bma_data
    del ecdf_rea, ecdf_stn
########################################################################################################################

# pcptrans = True
#
# # produce the mean square error of each grid from nearby stations in normal space
# # to support the production of final probabilistic estimation
# for y in range(year[0], year[1] + 1):
#     print('estimate mse: year',y)
#     # process for each month
#     for m in range(12):
#         print('Correction and Merge: month', m+1)
#         filemse = path_merge + '/mserror_' + var + '_' + str(y*100+m+1) + weightmode + '.npz'
#         if os.path.isfile(filemse):
#             print('file exists ... continue')
#             continue
#
#         indym = (date_number['yyyy'] == y) & (date_number['mm'] == m+1)
#         ym = date_number['mm'][date_number['yyyy'] == y]
#         indm = ym == m+1
#
#         mse_error = mse_error(stndata[:, indym], reacorr_stn[:, :, indym],
#                               reamerge_stn[:, indym], neargrid_loc, neargrid_dist, merge_choice[m,:,:], mask, var, pcptrans)
#
#         np.savez_compressed(filemse, mse_error=mse_error)


########################################################################################################################

# probability of precipitation

# def threshold_for_occurrence(dref, dtar, mode=1, upperbound=2):
#     # dref is station prcp and >0 means positive precipitation
#     # mode 1: objective is that dref and dtar have the same number of precipitation events
#     # mode 2: objective is to get max CSI of dtar
#
#     indnan = (np.isnan(dref)) | (np.isnan(dtar))
#     if np.sum(indnan)>0:
#         dref = dref[~indnan]
#         dtar = dtar[~indnan]
#
#     if len(dtar) < 1:
#         threshold = np.nan
#     else:
#         num1 = np.sum(dref > 0)
#         if num1 == 0:
#             threshold = np.max(dtar) + 0.1
#         else:
#             if mode == 1:
#                 indnan = (dtar == 0) | (np.isnan(dtar))
#                 dtar = dtar[~indnan]
#                 if len(dtar)<=num1:
#                     threshold = 0
#                 else:
#                     dtars = np.flip(np.sort(dtar))
#                     threshold = (dtars[num1] + dtars[num1-1]) / 2
#             elif mode == 2:
#                 step = 0.05
#                 num = int(upperbound / step) + 1
#                 csi = np.zeros(num)
#                 for i in range(num):
#                     threi = i * step
#                     n11 = np.sum((dref > 0) & (dtar > threi))
#                     n10 = np.sum((dref <= 0) & (dtar > threi))
#                     n01 = np.sum((dref > 0) & (dtar <= threi))
#                     csii = n11 / (n11 + n01 + n10)
#                     csi[i] = csii
#                 indi = np.nanargmax(csi)
#                 threshold = indi * step
#             else:
#                 sys.exit('Unknown mode for threshold')
#
#     if threshold > upperbound:
#         threshold = upperbound
#
#     return threshold
#
#
# def cal_csi(Obs, Pre, Tre=0):
#     # Tre: rain/no rain threshold
#     # POD(Probability of Detection),FOH(frequency of hit)
#     # FAR(False Alarm Ratio), CSI(Critical Success Index)
#     # HSS(Heidke skillscore),Ebert et al. [2007]
#     if len(Obs) > 1:
#         n11 = np.sum((Obs > Tre) & (Pre > Tre))
#         n10 = np.sum((Obs <= Tre) & (Pre > Tre))
#         n01 = np.sum((Obs > Tre) & (Pre <= Tre))
#         # n00 = np.sum((Obs <= Tre) & (Pre <= Tre))
#     # try:
#     #     POD = n11 / (n11 + n01)
#     # except:
#     #     POD = np.nan
#     # try:
#     #     FOH = n11 / (n11 + n10)
#     #     FAR = n10 / (n11 + n10)
#     # except:
#     #     FOH = np.nan
#     #     FAR = np.nan
#     try:
#         CSI = n11 / (n11 + n01 + n10)
#     except:
#         CSI = np.nan
#     # try:
#     #     HSS = 2 * (n11 * n00 - n10 * n01) / ((n11 + n01) *
#     #                                          (n01 + n00) + (n11 + n10) * (n10 + n00))
#     # except:
#     #     HSS = np.nan
#     #
#     # contingency_group = {'POD': POD, 'FOH': FOH, 'FAR': FAR,
#     #                      'CSI': CSI, 'HSS': HSS}
#     return CSI
#
# def pop_estimate(stndata,readata):
#     reanum, nstn, ntimes = np.shape(readata)
#     # 1. get threshold for precipitation occurrence
#     rea_threshold = np.nan * np.zeros([nstn, reanum])
#     for r in range(reanum):
#         for i in range(nstn):
#             if not np.isnan(stndata[i, 0]):
#                 rea_threshold[i, r] = threshold_for_occurrence(stndata[i,:], readata[r, i, :], mode=2, upperbound = 2)
#     # 2. calculate CSI
#     rea_csi = np.nan * np.zeros([nstn, reanum])
#     for r in range(reanum):
#         for i in range(nstn):
#             if not np.isnan(stndata[i, 0]):
#                 dobs = stndata[i, :]
#                 drea = readata[r, i, :].copy()
#                 drea[drea < rea_threshold[i, r]] = 0
#                 rea_csi[i, r] = cal_csi(dobs, drea)
#
#     # 3. estimate pop by merging reanalysis at station points
#     pop_reamerge = np.nan * np.zeros([nstn, ntimes], dtype=np.float32)
#     for i in range(nstn):
#         if not np.isnan(stndata[i, 0]):
#             csii = rea_csi[i, :]
#             weighti = csii ** 2 # weight formulation
#             weighti = np.tile(weighti, (ntimes,1)).T
#             popi = np.zeros([reanum, ntimes], dtype=int)
#             for r in range(reanum):
#                 pr = readata[r, i, :].copy()
#                 pr[pr < rea_threshold[i, r]] = 0
#                 pr[pr >= rea_threshold[i, r]] = 0
#                 popi[r, :] = pr
#             weighti[np.isnan(popi)] = 0 # MERRA2 does not have data for 1979
#             popi2 = np.sum(weighti * popi, axis=0) / np.sum(weighti, axis=0)
#             pop_reamerge[i, :] = popi2
#
#     return rea_threshold, rea_csi, pop_reamerge
#
