# convert files from .npz to .mat to facilitate analysis using matlab
import numpy as np
from scipy import io
import os

# station observation
infile = '/Users/localuser/Research/EMDNA/LScorrfactor_tmean.npz'
outfile = '/Users/localuser/Research/EMDNA/LScorrfactor_tmean.mat'
if not os.path.isfile(outfile):
    d = np.load(infile)
    prcp_stn = d['prcp_stn']
    tmean_stn = d['tmean_stn']
    trange_stn = d['trange_stn']
    date_ymd = d['date_ymd']
    stnID = d['stnID']
    stninfo = d['stninfo']
    del d

    io.savemat(outfile, {'prcp_stn': prcp_stn, 'tmean_stn': tmean_stn, 'trange_stn': trange_stn,
                         'date_ymd': date_ymd, 'stnID': stnID, 'stninfo': stninfo}, do_compression=True)
    del prcp_stn, tmean_stn, trange_stn, date_ymd, stnID, stninfo

# reanalysis downscaled data
infile = ['/Users/localuser/Research/EMDNA/ERA5_downto_stn_GWR.npz',
          '/Users/localuser/Research/EMDNA/ERA5_downto_stn_nearest.npz',
          '/Users/localuser/Research/EMDNA/MERRA2_downto_stn_GWR.npz',
          '/Users/localuser/Research/EMDNA/MERRA2_downto_stn_nearest.npz',
          '/Users/localuser/Research/EMDNA/JRA55_downto_stn_GWR.npz',
          '/Users/localuser/Research/EMDNA/JRA55_downto_stn_nearest.npz']
outfile = ['/Users/localuser/Research/EMDNA/ERA5_downto_stn_GWR.mat',
          '/Users/localuser/Research/EMDNA/ERA5_downto_stn_nearest.mat',
          '/Users/localuser/Research/EMDNA/MERRA2_downto_stn_GWR.mat',
          '/Users/localuser/Research/EMDNA/MERRA2_downto_stn_nearest.mat',
          '/Users/localuser/Research/EMDNA/JRA55_downto_stn_GWR.mat',
          '/Users/localuser/Research/EMDNA/JRA55_downto_stn_nearest.mat']
for i in range(6):
    print(i)
    if os.path.isfile(outfile[i]):
        continue
    d = np.load(infile[i])
    prcp_readown = d['prcp_readown']
    tmean_readown = d['tmean_readown']
    trange_readown = d['trange_readown']
    latitude = d['latitude']
    longitude = d['longitude']
    stn_ID = d['stn_ID']
    stn_lle = d['stn_lle']
    stn_row = d['stn_row']
    stn_col = d['stn_col']
    io.savemat(outfile[i], {'prcp_readown':prcp_readown, 'tmean_readown':tmean_readown, 'trange_readown':trange_readown,
                         'latitude':latitude, 'longitude':longitude, 'stn_ID':stn_ID,
                         'stn_lle':stn_lle, 'stn_row':stn_row, 'stn_col':stn_col}, do_compression=True)
    del d, prcp_readown, tmean_readown, trange_readown, longitude, latitude, stn_ID, stn_lle, stn_row, stn_col

# LS correction factor
infile = ['/Users/localuser/Research/EMDNA/LScorrfactor_prcp.npz',
          '/Users/localuser/Research/EMDNA/LScorrfactor_tmean.npz',
          '/Users/localuser/Research/EMDNA/LScorrfactor_trange.npz']
outfile = ['/Users/localuser/Research/EMDNA/LScorrfactor_prcp.mat',
          '/Users/localuser/Research/EMDNA/LScorrfactor_tmean.mat',
          '/Users/localuser/Research/EMDNA/LScorrfactor_trange.mat']
for i in range(3):
    print(i)
    if os.path.isfile(outfile[i]):
        continue
    d = np.load(infile[i])
    corrfactor = d['corrfactor']
    latitude = d['latitude']
    longitude = d['longitude']
    io.savemat(outfile[i], {'corrfactor':corrfactor, 'latitude':latitude, 'longitude':longitude}, do_compression=True)
    del d, corrfactor, longitude, latitude

# BMA merging weight
infile = ['/Users/localuser/Research/EMDNA/mergeweight_prcp_BMA.npz',
          '/Users/localuser/Research/EMDNA/mergeweight_tmean_BMA.npz',
          '/Users/localuser/Research/EMDNA/mergeweight_trange_BMA.npz']
outfile = ['/Users/localuser/Research/EMDNA/mergeweight_prcp_BMA.mat',
          '/Users/localuser/Research/EMDNA/mergeweight_tmean_BMA.mat',
          '/Users/localuser/Research/EMDNA/mergeweight_trange_BMA.mat']
for i in range(3):
    print(i)
    if os.path.isfile(outfile[i]):
        continue
    d = np.load(infile[i])
    reamerge_weight_grid = d['reamerge_weight_grid']
    latitude = d['latitude']
    longitude = d['longitude']
    io.savemat(outfile[i], {'reamerge_weight_grid':reamerge_weight_grid, 'latitude':latitude, 'longitude':longitude}, do_compression=True)
    del d, reamerge_weight_grid, longitude, latitude

# bma merge and correction
infile = ['/Users/localuser/Research/EMDNA/mergecorr_stn_prcp_GWRLS_BMA.npz',
          '/Users/localuser/Research/EMDNA/mergecorr_stn_tmean_GWRLS_BMA.npz',
          '/Users/localuser/Research/EMDNA/mergecorr_stn_trange_GWRLS_BMA.npz']
outfile = ['/Users/localuser/Research/EMDNA/mergecorr_stn_prcp_GWRLS_BMA.mat',
          '/Users/localuser/Research/EMDNA/mergecorr_stn_tmean_GWRLS_BMA.mat',
          '/Users/localuser/Research/EMDNA/mergecorr_stn_trange_GWRLS_BMA.mat']
for i in range(3):
    print(i)
    if os.path.isfile(outfile[i]):
        continue
    d = np.load(infile[i])
    reamerge_stn = d['reamerge_stn']
    reamerge_weight_stn = d['reamerge_weight_stn']
    reacorr_stn=d['reacorr_stn']
    date_ymd=d['date_ymd']
    prefix=d['prefix']
    stninfo=d['stninfo']
    io.savemat(outfile[i], {'reamerge_stn':reamerge_stn,
                            'reamerge_weight_stn':reamerge_weight_stn, 'date_ymd':date_ymd,
                            'reacorr_stn1': reacorr_stn[0],'reacorr_stn2': reacorr_stn[1],'reacorr_stn3': reacorr_stn[2],
                            'prefix':prefix,'stninfo':stninfo}, do_compression=True)
    del d, reamerge_stn, reamerge_weight_stn, reacorr_stn, date_ymd, prefix, stninfo

# bma merge pop
infile = '/Users/localuser/Research/EMDNA/merge_stn_pop_GWR_BMA.npz'
outfile = '/Users/localuser/Research/EMDNA/merge_stn_pop_GWR_BMA.mat'
if not os.path.isfile(outfile):
    d = np.load(infile)
    reamerge_weight_stn = d['reamerge_weight_stn']
    reamerge_stn = d['reamerge_stn']
    del d
    io.savemat(outfile, {'reamerge_weight_stn': reamerge_weight_stn, 'reamerge_stn': reamerge_stn}, do_compression=True)
    del reamerge_stn, reamerge_weight_stn


# OI merge
infile = ['/Users/localuser/Research/EMDNA/OImerge_stn_GWRBMA_pop.npz',
          '/Users/localuser/Research/EMDNA/OImerge_stn_GWRLSBMA_prcp.npz',
          '/Users/localuser/Research/EMDNA/OImerge_stn_GWRLSBMA_tmean.npz',
          '/Users/localuser/Research/EMDNA/OImerge_stn_GWRLSBMA_trange.npz']
outfile = ['/Users/localuser/Research/EMDNA/OImerge_stn_GWRBMA_pop.mat',
          '/Users/localuser/Research/EMDNA/OImerge_stn_GWRLSBMA_prcp.mat',
          '/Users/localuser/Research/EMDNA/OImerge_stn_GWRLSBMA_tmean.mat',
          '/Users/localuser/Research/EMDNA/OImerge_stn_GWRLSBMA_trange.mat']
for i in range(4):
    print(i)
    if os.path.isfile(outfile[i]):
        continue
    d = np.load(infile[i])
    oimerge_stn = d['oimerge_stn']
    stninfo = d['stninfo']
    date_ymd = d['date_ymd']
    stnID = d['stnID']
    io.savemat(outfile[i], {'oimerge_stn':oimerge_stn, 'stninfo':stninfo,'date_ymd':date_ymd,'stnID':stnID}, do_compression=True)
    del d, oimerge_stn, stninfo, date_ymd, stnID


# CHELSA_V12_NA_corratio.npz
infile = '/Users/localuser/Research/EMDNA/CHELSA_V12_NA_corratio.npz'
outfile = '/Users/localuser/Research/EMDNA/CHELSA_V12_NA_corratio.mat'
if not os.path.isfile(outfile):
    d = np.load(infile)
    corr_ratio = d['corr_ratio']
    io.savemat(outfile, {'corr_ratio': corr_ratio}, do_compression=True)

# CHELSA_V12_NA_corratio.npz
infile = '/Users/localuser/Research/EMDNA/regression_stn.npz'
outfile = '/Users/localuser/Research/EMDNA/regression_stn.mat'
if not os.path.isfile(outfile):
    d = np.load(infile)
    prcp = d['prcp']
    tmean = d['tmean']
    trange = d['trange']
    pop = d['pop']
    date_ymd = d['date_ymd']
    stnID = d['stnID']
    stninfo = d['stninfo']
    io.savemat(outfile, {'prcp': prcp, 'tmean': tmean, 'trange': trange, 'pop': pop,
                         'stninfo':stninfo,'date_ymd':date_ymd,'stnID':stnID}, do_compression=True)