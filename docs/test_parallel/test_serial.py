import dask

import numpy as np
import pandas as pd
import xarray as xr
from tqdm.contrib import itertools
import sys, os, math, time

sys.path.insert(0, '../src')
from regression import *


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

    nstn, ntime = np.shape(stn_data)
    nrow, ncol, nearmax = np.shape(tar_nearIndex)
    estimates = np.nan * np.zeros([nrow, ncol, ntime], dtype=np.float32)

    for r, c in itertools.product(range(nrow), range(ncol)):

        # prepare xdata and sample weight for training and weights of neighboring stations
        sample_nearIndex = tar_nearIndex[r, c, :]
        index_valid = sample_nearIndex >= 0

        if np.sum(index_valid) > 0:
            sample_nearIndex = sample_nearIndex[index_valid]

            sample_weight = tar_nearWeight[r, c, :][index_valid]
            sample_weight = sample_weight / np.sum(sample_weight)

            xdata_near0 = stn_predictor[sample_nearIndex, :]
            xdata_g0 = tar_predictor[r, c, :]

            # interpolation for every time step
            for d in range(ntime):

                ydata_near = np.squeeze(stn_data[sample_nearIndex, d])
                if len(np.unique(ydata_near)) == 1:  # e.g., for prcp, all zero
                    ydata_tar = ydata_near[0]
                else:

                    # add dynamic predictors if flag is true and predictors are good
                    xdata_near = xdata_near0
                    xdata_g = xdata_g0
                    if dynamic_predictors['flag'] == True:
                        xdata_near_add = dynamic_predictors['stn_predictor_dynamic'][:, d, sample_nearIndex].T
                        xdata_g_add = dynamic_predictors['tar_predictor_dynamic'][:, d, r, c]
                        if np.all(~np.isnan(xdata_near_add)) and np.all(~np.isnan(xdata_g_add)):
                            xdata_near_try = np.hstack((xdata_near, xdata_near_add))
                            xdata_g_try = np.hstack((xdata_g, xdata_g_add))
                            # check if dynamic predictors are good for regression
                            if check_predictor_matrix_behavior(xdata_near_try, sample_weight) == True:
                                xdata_near = xdata_near_try
                                xdata_g = xdata_g_try
                            else:
                                xdata_near_try = np.hstack((xdata_near, xdata_near_add[:, ~dynamic_predictors['predictor_checkflag']]))
                                xdata_g_try = np.hstack((xdata_g, xdata_g_add[~dynamic_predictors['predictor_checkflag']]))
                                if check_predictor_matrix_behavior(xdata_near_try, sample_weight) == True:
                                    xdata_near = xdata_near_try
                                    xdata_g = xdata_g_try

                    # regression
                    if method == 'linear':
                        ydata_tar = weight_linear_regression(xdata_near, sample_weight, ydata_near, xdata_g)
                    elif method == 'logistic':
                        ydata_tar = weight_logistic_regression(xdata_near, sample_weight, ydata_near, xdata_g)
                    else:
                        sys.exit(f'Unknonwn regression method: {method}')
                estimates[r, c, d] = ydata_tar
                
    t2 = time.time()
    print('serial time:', t2-t1)
