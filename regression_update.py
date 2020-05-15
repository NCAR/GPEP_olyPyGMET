import numpy as np
import auxiliary as au
import sys
import netCDF4 as nc
from fromNR import *


def least_squares(x, y, tx):
    # In fortran version, ludcmp and lubksb are used to calcualte matrix inversion
    # call ludcmp(a, indx, d)
    # call lubksb(a, indx, b)

    # In Python version, numpy is used to calculate matrix inversion
    c = np.matmul(tx, y)
    a = np.matmul(tx, x)

    n = np.shape(a)[0]
    b = np.zeros(n)

    deta = np.linalg.det(a)  # Compute the determinant of an array
    if deta == 0:
        # print('Singular matrix')
        b[:] = 0
    else:
        ainv = np.linalg.inv(a)
        b = np.matmul(ainv, c)

    return b


def logistic_regression(x, tx, yp):
    # nstn: station number
    # nvars: station attributes (1, lat/lon/...), 1 is for regression
    nstn, nvars = np.shape(x)

    b = np.zeros(nvars)  # regression coefficients (beta)
    p = np.zeros(nstn)  # estimated pop (probability of precipitation)
    f = 0  # flag: continue or stop loops
    it = 0  # iteration times

    while f != 1:
        # check for divergence
        xb = -np.matmul(x, b)
        if np.any(xb > 50):
            f = 1
        else:
            p = 1 / (1 + np.exp(xb))

        # check for divergence
        if np.any(p > 0.9999):
            # logistic regression diverging
            f = 1
        else:
            v = np.zeros([nstn, nstn])  # diagonal variance matrix
            for i in range(nstn):
                v[i, i] = p[i] * (1 - p[i])
            xv = np.matmul(v, x)
            yn = yp - p  # difference between station occurrence (0/1) and estimated pop: Bnew -Bold in Martyn and Slater 2006
            bn = least_squares(xv, yn, tx)

            # check: converging
            if np.any(np.abs(bn) > 1e-4):
                f = 0
            else:
                f = 1

            # check: iteration times
            if it > 20:
                f = 1
            else:
                f = 0

            b = b + bn  # update coefficients

        it = it + 1

    return b


def weightedmean(data, weight):
    # inverse distance weighting interpolation
    dataout = np.nansum(data * weight) / np.nansum(weight)
    return dataout


def station_error(prcp_stn, stninfo, near_stn_prcpLoc, near_stn_prcpWeight, nearstn_min):
    nstn, ntimes = np.shape(prcp_stn)
    pcp_err_stn = -999 * np.ones([nstn, ntimes], dtype=np.float32)

    for t in range(ntimes):
        print('Current time:', t, 'Total times:', ntimes)
        # assign vectors of station alues for prcp_stn, temp, for current time step
        # transform prcp_stn to approximate normal distribution
        y_prcp = prcp_stn[:, t]

        for gg in range(nstn):
            if prcp_stn[gg, t] > -1:
                # reduced matrices for precip
                nstn_prcp = int(np.sum(near_stn_prcpLoc[gg, :] > -1))
                if nstn_prcp >= nearstn_min:
                    w_pcp_red = np.zeros([nstn_prcp, nstn_prcp])
                    for i in range(nstn_prcp):
                        w_pcp_red[i, i] = near_stn_prcpWeight[gg, i]  # eye matrix: stn weight in one-one line
                    w_pcp_1d = near_stn_prcpWeight[gg, 0:nstn_prcp]  # stn weight
                    w_pcp_1d_loc = near_stn_prcpLoc[gg, 0:nstn_prcp]  # stn ID number/location
                    y_prcp_red = y_prcp[w_pcp_1d_loc]  # transformed prcp_stn
                    x_red = stninfo[w_pcp_1d_loc, :]  # station lat/lon/ele/slope_ns/slope_we

                    yp_red = np.zeros(nstn_prcp)  # pop: 0/1
                    yp_red[prcp_stn[w_pcp_1d_loc, t] > 0] = 1
                    ndata = np.sum(yp_red == 1)  # number of prcp_stn>0
                else:
                    # there are not enough nearby stations
                    x_red = 0  # not really necessary. just to stop warming from Pycharm
                    w_pcp_red = 0  # not really necessary. just to stop warming from Pycharm
                    yp_red = 0  # not really necessary. just to stop warming from Pycharm
                    y_prcp_red = 0  # not really necessary. just to stop warming from Pycharm
                    ndata = 0

                # prcp processing
                if ndata == 0:
                    # nearby stations do not have positive prcp data
                    pcp_err_stn[gg, t] = 0
                else:
                    # tmp needs to be matmul(TX, X) where TX = TWX_red and X = X_red
                    mat_test = np.matmul(np.transpose(x_red), w_pcp_red)
                    tmp = np.matmul(mat_test, x_red)
                    vv = np.max(np.abs(tmp), axis=1)

                    # decide if slope is to be used in regression
                    if stninfo[gg, 1] < 74:
                        if np.any(vv == 0) or abs(stninfo[gg, 4]) < 3.6 or abs(stninfo[gg, 5]) < 3.6:
                            slope_flag_pcp = 0
                            x_red_use = x_red[:, 0:4]  # do not use slope in regression
                            stninfo_use = stninfo[gg, 0:4]
                        else:
                            slope_flag_pcp = 1
                            x_red_use = x_red
                            stninfo_use = stninfo[gg, :]
                    else:
                        x_red_use = x_red[:, 0:3]
                        stninfo_use = stninfo[gg, 0:3]

                    tx_red = np.transpose(x_red_use)
                    twx_red = np.matmul(tx_red, w_pcp_red)

                    # calculate pcp
                    b = least_squares(x_red_use, y_prcp_red, twx_red)
                    pcpgg = np.dot(stninfo_use, b)
                    pcpgg = regressioncheck(pcpgg, y_prcp_red, w_pcp_1d, 'pcp')
                    pcp_err_stn[gg, t] = pcpgg - y_prcp[gg]

    return pcp_err_stn



def regression(prcp_stn, pcp_err_stn, stninfo, gridinfo,
               mask, near_grid_prcpLoc, near_grid_prcpWeight,
               nearstn_min, nearstn_max):
    nstn, ntimes = np.shape(prcp_stn)
    nrows, ncols, nvars = np.shape(gridinfo)

    # 6.2 initialization
    tmp_weight_arr = np.eye(nearstn_max)
    y_max = -3 * np.ones([nrows, ncols, ntimes], dtype=np.float32)
    pcp = -3 * np.ones([nrows, ncols, ntimes], dtype=np.float32)
    pcp_err = np.zeros([nrows, ncols, ntimes], dtype=np.float32)

    # start regression ...
    # loop through time steps
    for t in range(ntimes):
        print('Regression time step: ', t + 1, '---Total time steps: ', ntimes)
        # assign vectors of station alues for prcp_stn, temp, for current time step
        # transform prcp_stn to approximate normal distribution
        y_prcp = prcp_stn[:, t]

        # loop through grids (row, col)
        # for rr in range(nrows):
        #     for cc in range(ncols):
        for rr in range(nrows):
            for cc in range(ncols):
                if mask[rr, cc] != 1:
                    # the grid is outside mask extent
                    continue
                ########################################################################################################

                # 6.3 Precipitation estimation (pop and pcp)
                nstn_prcp = int(np.sum(near_grid_prcpLoc[rr, cc, :] > -1))
                if nstn_prcp < nearstn_min:
                    print('Precipitation regression: current time step, row, and col are', t, rr, cc)
                    sys.exit('Cannot find enough input stations for this grid cell')
                else:
                    # 6.3.1 reduced matrices for precipitation
                    w_pcp_red = np.zeros([nstn_prcp, nstn_prcp])
                    for i in range(nstn_prcp):
                        w_pcp_red[i, i] = near_grid_prcpWeight[rr, cc, i]  # eye matrix: stn weight in one-one lien
                    w_pcp_1d = near_grid_prcpWeight[rr, cc, 0:nstn_prcp]  # stn weight
                    w_pcp_1d_loc = near_grid_prcpLoc[rr, cc, 0:nstn_prcp]  # stn ID number/location
                    y_prcp_red = y_prcp[w_pcp_1d_loc]  # transformed prcp_stn
                    x_red = stninfo[w_pcp_1d_loc, :]  # station lat/lon/ele/slope_ns/slope_we

                    yp_red = np.zeros(nstn_prcp)  # pop: 0/1
                    yp_red[prcp_stn[w_pcp_1d_loc, t] > 0] = 1
                    ndata = np.sum(yp_red == 1)  # number of prcp_stn>0
                    nodata = np.sum(yp_red == 0)
                    y_max[rr, cc, t] = max(y_prcp_red)

                    # 6.3.2 estimate pop, pcp, pcp_err
                    # note: pcp_err is based on results from 6.1 and independent with gridded pop and pcp regression
                    if ndata == 0:
                        # nearby stations do not have positive prcp data (i.e., zero or missing)
                        pcp[rr, cc, t] = y_prcp_red[0]  # corresponding to zero precipitation
                        pcp_err[rr, cc, t] = 0
                    else:
                        # decide if slope is to be used in regression
                        # tmp needs to be matmul(TX, X) where TX = TWX_red and X = X_red
                        mat_test = np.matmul(np.transpose(x_red), w_pcp_red)
                        tmp = np.matmul(mat_test, x_red)
                        vv = np.max(np.abs(tmp), axis=1)
                        if gridinfo[rr, cc, 1] < 74:
                            if np.any(vv == 0) or np.abs(gridinfo[rr, cc, 4]) < 3.6 or np.abs(
                                    gridinfo[rr, cc, 5]) < 3.6:
                                x_red_use = x_red[:, 0:4]  # do not use slope in regression
                                gridinfo_use = gridinfo[rr, cc, 0:4]
                            else:
                                x_red_use = x_red
                                gridinfo_use = gridinfo[rr, cc, :]
                        else:
                            x_red_use = x_red[:, 0:3]  # do not use elevation in northern Canada
                            gridinfo_use = gridinfo[rr, cc, 0:3]

                        tx_red = np.transpose(x_red_use)
                        twx_red = np.matmul(tx_red, w_pcp_red)


                        # calculate pcp
                        b = least_squares(x_red_use, y_prcp_red, twx_red)
                        pcpreg = np.dot(gridinfo_use, b)
                        pcpreg = regressioncheck(pcpreg, y_prcp_red, w_pcp_1d, 'pcp')
                        pcp[rr, cc, t] = pcpreg

                        # 6.4.3 estimate pcp error
                        err0 = pcp_err_stn[w_pcp_1d_loc, t]
                        pcp_err[rr, cc, t] = (np.sum((err0 ** 2) * w_pcp_1d) / np.sum(w_pcp_1d)) ** 0.5

    return pcp, pcp_err, y_max


def regressioncheck(datareg, datastn, weightstn, varname):
    # check whether the regression estimates are reasonable because in some cases, regression will lead to too large
    # or too small estimates due to various reasons, such as (1) the very large elevation of dem pixels compared with stations
    # (northern canadian islands), (2) the abnormal data of few stations, (3) method limitation, etc.
    # for such cases, we check the upper and lower bound of input and replace it with IDW estimates. We don't just truncate
    # the upper and lower bound because sometimes the regression estimates deviate too far.
    # we hope the regression should be conservative as we have probabilistic estimation later
    # for pcp: upper bound=max(pcp), lower bound=-3 (zero pcp in box-cox transformation)
    # for trange: upper bound=max(trange)+3, lower bound = min(trange)-3
    # for tmean: upper bound=max(tmean)+3, lower bound=min(tmean)+3 because 3 / 0.65 ~=4.6 km (lapse rate=0.65 degree/km)
    # while max_dem = 4.6 km in 0.1 degree in north america
    if varname == 'pcp':
        upb = np.max(datastn) * 1.5
        lwb = 0
    elif varname == 'tmean':
        upb = np.max(datastn) + 3
        lwb = np.min(datastn) - 3
    elif varname == 'trange':
        upb = np.max(datastn) + 3
        lwb = np.min(datastn) - 3
        if lwb < 0:
            lwb = 0
    else:
        sys.exit('Unknown variable name')

    if datareg > upb or datareg < lwb:
        datareg = weightedmean(datastn[0:10], weightstn[0:10])  # use the ten nearest stations

    return datareg

#
# def residualcorrection(dres, dreg, nearloc, nearweight):
#     # correct spatial interpolation estimates using the residuals estimated at station points
#     # a simple IDW method is used to interpolate residuals
#     if np.ndim(dres) == 1:
#         dres = dres[:, np.newaxis]
#         dreg = dreg[:, :, np.newaxis]
#     nrows, ncols, ntimes = np.shape(dreg)
#     dcorr = np.nan * np.zeros([nrows, ncols, ntimes], dtype=np.float32)
#     for r in range(nrows):
#         for c in range(ncols):
#             if nearloc[r, c, 0] > -1:
#                 locrc = nearloc[r, c, :]
#                 weightrc = nearweight[r, c, :]
#                 weightrc = weightrc[locrc > -1]
#                 locrc = locrc[locrc > -1]
#
#                 dresrc = dres[locrc, :]
#                 for t in range(ntimes):
#                     dcorr[r, c, t] = weightedmean(dresrc, weightrc) + dreg[r, c, t]
#     return dcorr


def error_after_residualcorrection(data_ori, data_reg, nearloc, nearweight):
    # data_ori: original observation
    # data_reg: regression estimates
    # data_res: regression residuals
    nstn, ntimes = np.shape(data_ori)
    res_after_corr = np.nan * np.zeros([nstn, ntimes])
    for i in range(nstn):
        if np.isnan(data_ori[i,0]):
            continue
        nearloci = nearloc[i,0:3]
        nearweighti = nearweight[i, 0:3]
        induse = nearloci>-1
        nearloci = nearloci[induse]
        nearweighti = nearweighti[induse]
        nearweighti = nearweighti / np.sum(nearweighti)
        nearweighti2 = np.tile(nearweighti,(ntimes,1)).T

        dtar_orii = data_ori[i,:]
        dtar_regi = data_reg[i,:]
        dtar_resi = dtar_regi - dtar_orii

        dnear_orii = data_ori[nearloci,:]
        dnear_regi = data_reg[nearloci, :]
        dnear_resi = dnear_regi - dnear_orii

        dtar_resi_corr = np.sum(dnear_resi * nearweighti2, axis=0)
        dtar_regi_corr = dtar_regi - dtar_resi_corr

        res_after_corri = dtar_regi_corr - dtar_orii
        res_after_corr[i, :] = res_after_corri

    return res_after_corr