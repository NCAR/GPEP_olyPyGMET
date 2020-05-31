import numpy as np

def OImerge(tar_err_b, near_err_b, near_err_o, flag_o=0):
    # tar/near: target and nearby stations/grids
    # o/b: observation/background
    # err: error (o-t or b-t where t is truth)
    # flag_o: whether observation error is independent (1: independent, other values: not)
    # row: models, col: time steps
    # calculate weight (W) using: W(Cb + Co)=Cb0
    if np.ndim(near_err_b)==1:
        near_err_b=near_err_b[np.newaxis,:]
    nstn, ntimes = np.shape(near_err_b)
    # covariance matrix of errors
    Cb = np.cov(near_err_b)
    Co = np.cov(near_err_o)

    if flag_o != 1:
        Co = np.eye(nstn) * Co # independence assumption

    Cb0 = np.zeros(nstn)
    for i in range(nstn):
        Cb0[i] = cov1d(tar_err_b, near_err_b[i,:])

    try:
        cbot = np.linalg.inv(Cb+Co)
        W = np.dot(Cb0, cbot)
    except:
        # singular matrix
        W = np.nan * np.ones(nstn)
    return W

def cov1d(a, b):
    if len(a) != len(b):
        return
    a_mean = np.mean(a)
    b_mean = np.mean(b)

    sum = 0

    for i in range(0, len(a)):
        sum += ((a[i] - a_mean) * (b[i] - b_mean))

    return sum/(len(a)-1)