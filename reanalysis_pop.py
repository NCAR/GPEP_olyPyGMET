import numpy as np
import regression as reg
from scipy import io
from auxiliary_merge import m_DateList
import os, sys

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


# read from inputs
time1 = int(sys.argv[1])
time2 = int(sys.argv[2])
print(time1,time2)

prefix = ['ERA5_', 'MERRA2_', 'JRA55_']

# ### Local Mac settings
# # input files/paths
# gmet_stnfile = '/Users/localuser/Research/EMDNA/basicinfo/stnlist_whole.txt'
# gmet_stndatafile = '/Users/localuser/Research/EMDNA/stndata_whole.npz'
# file_mask = './DEM/NA_DEM_010deg_trim.mat'
# near_file_GMET = '/Users/localuser/Research/EMDNA/regression/weight_nearstn.npz' # near station of stations/grids
# file_readownstn = ['/Users/localuser/Research/EMDNA/downscale/ERA5_downto_stn_nearest.npz', # downscaled to stn points
#                    '/Users/localuser/Research/EMDNA/downscale/MERRA2_downto_stn_nearest.npz',
#                    '/Users/localuser/Research/EMDNA/downscale/JRA55_downto_stn_nearest.npz']
#
# # output files/paths (can also be used as inputs once generated)
# near_path = '/Users/localuser/Research/EMDNA/correction'  # path to save near station for each grid/cell
# path_ecdf = '/Users/localuser/Research/EMDNA/merge/ECDF'
# path_pop = '/Users/localuser/Research/EMDNA/pop'
# ### Local Mac settings


### Plato settings
gmet_stnfile = '/datastore/GLOBALWATER/CommonData/EMDNA/StnGridInfo/stnlist_whole.txt'
gmet_stndatafile = '/datastore/GLOBALWATER/CommonData/EMDNA/stndata_whole.npz'
file_mask = '/datastore/GLOBALWATER/CommonData/EMDNA/DEM/NA_DEM_010deg_trim.mat'
near_file_GMET = '/datastore/GLOBALWATER/CommonData/EMDNA/PyGMETout/weight.npz'
file_readownstn = ['/datastore/GLOBALWATER/CommonData/EMDNA/ERA5_day_ds/ERA5_downto_stn_GWR.npz', # downscaled to stn points
                   '/datastore/GLOBALWATER/CommonData/EMDNA/MERRA2_day_ds/MERRA2_downto_stn_GWR.npz',
                   '/datastore/GLOBALWATER/CommonData/EMDNA/JRA55_day_ds/JRA55_downto_stn_GWR.npz']
near_path = '/home/gut428/ReanalysisCorrMerge'  # path to save near station for each grid/cell
path_ecdf = '/datastore/GLOBALWATER/CommonData/EMDNA/ReanalysisCorrMerge/ECDF'
path_pop = '/home/gut428/ReanalysisCorrMerge/pop'
file_pop1 = '/home/gut428/ReanalysisCorrMerge/reanalysis_pop1.npz'
### Plato settings

near_stnfile = near_path + '/near_stn_prcp.npz'
near_gridfile = near_path + '/near_grid_prcp.npz'
file_pop1 = path_pop + '/reanalysis_pop1.npz'

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
stndata = datatemp['prcp_stn']
stnlle = datatemp['stn_lle']
nstn, ntimes = np.shape(stndata)
del datatemp

# load near station information
datatemp = np.load(near_file_GMET)
near_loc_stn = datatemp['near_stn_prcpLoc']
near_weight_stn = datatemp['near_stn_prcpWeight']
near_dist_stn = datatemp['near_stn_prcpDist']
# near_loc_grid = datatemp['near_grid_prcpLoc']
# near_weight_grid = datatemp['near_grid_prcpWeight']
# near_dist_grid = datatemp['near_grid_prcpDist']
# near_loc = np.flipud(near_loc_grid)
# near_weight = np.flipud(near_weight_grid)
# near_dist = np.flipud(near_dist_grid)

# probability bins for QM
binprob = 500
ecdf_prob = np.arange(0, 1 + 1 / binprob, 1 / binprob)

########################################################################################################################

# load downscaled reanalysis at station points
print('load downscaled reanalysis data at station points')
readata_stn = np.nan * np.zeros([reanum, nstn, ntimes], dtype=np.float32)
for rr in range(reanum):
    dr = np.load(file_readownstn[rr])
    temp = dr['prcp_readown']
    readata_stn[rr, :, :] = temp
    del dr, temp
readata_stn[readata_stn < 0] = 0

########################################################################################################################

# method-1: estimate pop using a univariate regression between station occurrence (0-1) and reanalysis precipitation
file_popt = path_pop + '/reapop_stn_' + str(time1) + '-' + str(time2) + '.npz'
if not os.path.isfile(file_popt):
    reapop_stn = np.zeros([reanum, nstn, ntimes], dtype=np.float32)
    for rr in range(reanum):
        for gg in range(nstn):
            if np.mod(gg,100)==0:
                print(gg,nstn)

            if np.isnan(stndata[gg, 0]):
                continue
            nearloc = near_loc_stn[gg, :]
            neardist = near_dist_stn[gg, :]
            nearweight = near_weight_stn[gg, :]
            neardist = neardist[nearloc > -1]
            nearweight = nearweight[nearloc > -1]
            nearloc = nearloc[nearloc > -1]

            nstn_prcp = len(nearloc)
            w_pcp_red = np.zeros([nstn_prcp, nstn_prcp])
            for i in range(nstn_prcp):
                w_pcp_red[i, i] = nearweight[i]  # eye matrix: stn weight in one-one lien

            x_red = np.ones([nstn_prcp, 2])

            # for tt in range(ntimes):
            for tt in range(time1-1, time2):
                prea_tar = readata_stn[rr, gg, tt]
                if stndata[gg, tt]>0:
                    pstn_tar = 1
                else:
                    pstn_tar = 0
                prea_near = readata_stn[rr, nearloc, tt]
                pstn_near = stndata[nearloc, tt]
                pstn_near[pstn_near > 0] = 1

                # logistic regression
                if np.all(pstn_near == 1):
                    reapop_stn[rr, gg, tt] = 1
                elif np.all(pstn_near == 0) or np.all(prea_near == 0):
                    reapop_stn[rr, gg, tt] = 0
                else:
                    x_red[:, 1] = prea_near
                    tx_red = np.transpose(x_red)
                    twx_red = np.matmul(tx_red, w_pcp_red)
                    b = reg.logistic_regression(x_red, twx_red, pstn_near)
                    zb = - np.dot(np.array([1,prea_tar]), b)
                    reapop_stn[rr, gg, tt] = 1 / (1 + np.exp(zb))
    np.savez_compressed(file_popt, reapop_stn=reapop_stn)

########################################################################################################################

# this method is quick in speed, but slightly worse than method-1

# # method-2: estimate pop during the proess of QM correction
# date_list, date_number = m_DateList(1979, 2018, 'ByYear')
# rea_pop2 = np.zeros([reanum, nstn, ntimes], dtype=np.float32)
# for rr in range(reanum):
#     for gg in range(nstn):
#         if np.mod(gg,100)==0:
#             print(gg)
#         if np.isnan(stndata[gg, 0]):
#             continue
#         nearloc = near_loc_stn[gg, :]
#         neardist = near_dist_stn[gg, :]
#         nearweight = near_weight_stn[gg, :]
#         neardist = neardist[nearloc > -1]
#         nearweight = nearweight[nearloc > -1]
#         nearweight = nearweight / np.sum(nearweight)
#         nearloc = nearloc[nearloc > -1]
#         nstn_prcp = len(nearloc)
#
#         for mm in range(12):
#             indm = date_number['mm'] == (mm+1)
#             prea_tar = readata_stn[rr, gg, indm]
#             pstn_near = stndata[nearloc,:][:, indm]
#             ecdf_reatar = empirical_cdf(prea_tar, ecdf_prob)
#             popmm_near = np.zeros([nstn_prcp, np.sum(indm)])
#             popmm = np.zeros(np.sum(indm))
#             for i in range(nstn_prcp):
#                 # a simple Qunatile mapping by sorting
#                 ecdf_neari = empirical_cdf(pstn_near[i,:], ecdf_prob)
#                 pqm = cdf_correction(ecdf_prob, ecdf_neari, ecdf_prob, ecdf_reatar, pstn_near[i,:])
#                 pqm[pqm > 0] = 1
#                 popmm_near[i, :] = pqm
#                 popmm = popmm + pqm * nearweight[i]
#             rea_pop2[rr, gg, indm] = popmm

########################################################################################################################

# method-3: estimate pop using the threshold-based method


