import numpy as np
import sys


# probability of precipitation

def threshold_for_occurrence(dref, dtar, mode=1, upperbound=2):
    # dref is station prcp and >0 means positive precipitation
    # mode 1: objective is that dref and dtar have the same number of precipitation events
    # mode 2: objective is to get max CSI of dtar

    indnan = (np.isnan(dref)) | (np.isnan(dtar))
    if np.sum(indnan) > 0:
        dref = dref[~indnan]
        dtar = dtar[~indnan]

    if len(dtar) < 1:
        threshold = np.nan
    else:
        num1 = np.sum(dref > 0)
        if num1 == 0:
            threshold = np.max(dtar) + 0.1
        else:
            if mode == 1:
                indnan = (dtar == 0) | (np.isnan(dtar))
                dtar = dtar[~indnan]
                if len(dtar) <= num1:
                    threshold = 0
                else:
                    dtars = np.flip(np.sort(dtar))
                    threshold = (dtars[num1] + dtars[num1 - 1]) / 2
            elif mode == 2:
                step = 0.05
                num = int(upperbound / step) + 1
                csi = np.zeros(num)
                for i in range(num):
                    threi = i * step
                    n11 = np.sum((dref > 0) & (dtar > threi))
                    n10 = np.sum((dref <= 0) & (dtar > threi))
                    n01 = np.sum((dref > 0) & (dtar <= threi))
                    csii = n11 / (n11 + n01 + n10)
                    csi[i] = csii
                indi = np.nanargmax(csi)
                threshold = indi * step
            else:
                sys.exit('Unknown mode for threshold estimation')

    if threshold > upperbound:
        threshold = upperbound

    return threshold


def cal_csi(Obs, Pre, Tre=0):
    # Tre: rain/no rain threshold
    # POD(Probability of Detection),FOH(frequency of hit)
    # FAR(False Alarm Ratio), CSI(Critical Success Index)
    # HSS(Heidke skillscore),Ebert et al. [2007]
    if len(Obs) > 1:
        n11 = np.sum((Obs > Tre) & (Pre > Tre))
        n10 = np.sum((Obs <= Tre) & (Pre > Tre))
        n01 = np.sum((Obs > Tre) & (Pre <= Tre))
        # n00 = np.sum((Obs <= Tre) & (Pre <= Tre))
    # try:
    #     POD = n11 / (n11 + n01)
    # except:
    #     POD = np.nan
    # try:
    #     FOH = n11 / (n11 + n10)
    #     FAR = n10 / (n11 + n10)
    # except:
    #     FOH = np.nan
    #     FAR = np.nan
    try:
        CSI = n11 / (n11 + n01 + n10)
    except:
        CSI = np.nan
    # try:
    #     HSS = 2 * (n11 * n00 - n10 * n01) / ((n11 + n01) *
    #                                          (n01 + n00) + (n11 + n10) * (n10 + n00))
    # except:
    #     HSS = np.nan
    #
    # contingency_group = {'POD': POD, 'FOH': FOH, 'FAR': FAR,
    #                      'CSI': CSI, 'HSS': HSS}
    return CSI



# main
filestn = '/Users/localuser/Downloads/stndata_whole.npz'
filerea = '/Users/localuser/Research/Test/mergecorr_prcp_RMSE.npz'
outfile = '/Users/localuser/Research/Test/reanalysis_pop_stn.npz'
maxthreshold = 2

d1 = np.load(filestn)
d2 = np.load(filerea)

stndata = d1['prcp_stn']
readata = d2['reacorr_stn']
stn_lle = d1['stn_lle']

reanum, nstn, ntimes = np.shape(readata)
# 1. get threshold for precipitation occurrence
# rea_threshold1 = np.nan * np.zeros([nstn, reanum])
rea_threshold = np.nan * np.zeros([nstn, reanum])
# rea_csi1 = np.nan * np.zeros([nstn, reanum])
rea_csi = np.nan * np.zeros([nstn, reanum])
for r in range(reanum):
    for i in range(nstn):
        if np.mod(i,1000)==0:
            print('r i',r,i)
        if not np.isnan(stndata[i, 0]):
            dobs = stndata[i, :]
            drea = readata[r, i, :].copy()
            # rea_threshold1[i, r] = threshold_for_occurrence(dobs, drea, mode=1, upperbound=maxthreshold)
            rea_threshold[i, r] = threshold_for_occurrence(dobs, drea, mode=2, upperbound=maxthreshold)

            # drea1 = drea.copy()
            # drea1[drea1 <rea_threshold1[i, r]] = 0
            # rea_csi1[i, r] = cal_csi(dobs, drea1)
            drea[drea <rea_threshold[i, r]] = 0
            rea_csi[i, r] = cal_csi(dobs, drea)

# 2. estimate pop by merging reanalysis at station points
pop_reamerge = np.nan * np.zeros([nstn, ntimes], dtype=np.float32)
for i in range(nstn):
    if np.mod(i, 1000) == 0:
        print('i', i)
    if not np.isnan(stndata[i, 0]):
        csii = rea_csi[i, :]
        weighti = csii ** 2  # weight formulation
        weighti = np.tile(weighti, (ntimes, 1)).T
        popi = np.zeros([reanum, ntimes])
        for r in range(reanum):
            pr = readata[r, i, :].copy()
            pr[pr <= rea_threshold[i, r]] = 0
            pr[pr > rea_threshold[i, r]] = 1
            popi[r, :] = pr
        weighti[np.isnan(popi)] = 0  # MERRA2 does not have data for 1979
        popi2 = np.nansum(weighti * popi, axis=0) / np.sum(weighti, axis=0)
        pop_reamerge[i, :] = popi2

np.savez_compressed(outfile,pop_reamerge=pop_reamerge,rea_threshold=rea_threshold,rea_csi=rea_csi,stn_lle=stn_lle)


# 3. evaluate the occurrence and pop
