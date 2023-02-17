import dask

import numpy as np
import pandas as pd
import xarray as xr
from tqdm.contrib import itertools
import sys, os, math, time

sys.path.insert(0, '../src')
from regression import *


def para_regression_GLB(r, c):

    nstn, ntime = np.shape(stn_data_GLB)
    nrow, ncol, nearmax = np.shape(tar_nearIndex_GLB)

    # prepare xdata and sample weight for training and weights of neighboring stations
    sample_nearIndex = tar_nearIndex_GLB[r, c, :]
    index_valid = sample_nearIndex >= 0

    ydata_tar = np.nan * np.zeros(ntime)

    if np.sum(index_valid) > 0:
        sample_nearIndex = sample_nearIndex[index_valid]

        sample_weight = tar_nearWeight_GLB[r, c, :][index_valid]
        sample_weight = sample_weight / np.sum(sample_weight)

        xdata_near0 = stn_predictor_GLB[sample_nearIndex, :]
        xdata_g0 = tar_predictor_GLB[r, c, :]

        # interpolation for every time step
        for d in range(ntime):

            ydata_near = np.squeeze(stn_data_GLB[sample_nearIndex, d])
            if len(np.unique(ydata_near)) == 1:  # e.g., for prcp, all zero
                ydata_tar[d] = ydata_near[0]
            else:

                # add dynamic predictors if flag is true and predictors are good
                xdata_near = xdata_near0
                xdata_g = xdata_g0
                if dynamic_predictors_GLB['flag'] == True:
                    xdata_near_add = dynamic_predictors_GLB['stn_predictor_dynamic'][:, d, sample_nearIndex].T
                    xdata_g_add = dynamic_predictors_GLB['tar_predictor_dynamic'][:, d, r, c]
                    if np.all(~np.isnan(xdata_near_add)) and np.all(~np.isnan(xdata_g_add)):
                        xdata_near_try = np.hstack((xdata_near, xdata_near_add))
                        xdata_g_try = np.hstack((xdata_g, xdata_g_add))
                        # check if dynamic predictors are good for regression
                        if check_predictor_matrix_behavior(xdata_near_try, sample_weight) == True:
                            xdata_near = xdata_near_try
                            xdata_g = xdata_g_try
                        else:
                            xdata_near_try = np.hstack(
                                (xdata_near, xdata_near_add[:, ~dynamic_predictors_GLB['predictor_checkflag']]))
                            xdata_g_try = np.hstack((xdata_g, xdata_g_add[~dynamic_predictors_GLB['predictor_checkflag']]))
                            if check_predictor_matrix_behavior(xdata_near_try, sample_weight) == True:
                                xdata_near = xdata_near_try
                                xdata_g = xdata_g_try

                # regression
                if method_GLB == 'linear':
                    ydata_tar[d] = weight_linear_regression(xdata_near, sample_weight, ydata_near, xdata_g)
                elif method_GLB == 'logistic':
                    ydata_tar[d] = weight_logistic_regression(xdata_near, sample_weight, ydata_near, xdata_g)
                else:
                    sys.exit(f'Unknonwn regression method_GLB: {method_GLB}')

    return ydata_tar


import multiprocessing
from multiprocessing import Pool

if __name__ == '__main__':
    
    # load data
    data0 = np.load('data_for_parallel_test.npz', allow_pickle=True)
    stn_data=data0['stn_data']
    stn_predictor=data0['stn_predictor']
    tar_nearIndex=data0['tar_nearIndex']
    tar_nearWeight=data0['tar_nearWeight']
    tar_predictor=data0['tar_predictor']
    method=data0['method']
    dynamic_predictors=data0['dynamic_predictors'].item()
    
    t1 = time.time()

    # define some global variables
    global stn_data_GLB, stn_predictor_GLB, tar_nearIndex_GLB, tar_nearWeight_GLB, tar_predictor_GLB, method_GLB, dynamic_predictors_GLB
    stn_data_GLB, stn_predictor_GLB, tar_nearIndex_GLB, tar_nearWeight_GLB, tar_predictor_GLB, method_GLB, dynamic_predictors_GLB = stn_data, stn_predictor, tar_nearIndex, tar_nearWeight, tar_predictor, method, dynamic_predictors

    nstn, ntime = np.shape(stn_data)
    nrow, ncol, nearmax = np.shape(tar_nearIndex)

    items = [(r, c) for r, c in itertools.product(range(nrow), range(ncol))]
    with Pool(processes=3) as pool:
        result = pool.starmap(para_regression_GLB, items)

    estimates3 = np.nan * np.zeros([nrow, ncol, ntime], dtype=np.float32)
    for i in range(len(items)):
        indi = items[i]
        estimates3[indi[0], indi[1], :] = result[i]
        
    t2 = time.time()
    print('para time:', t2-t1)
