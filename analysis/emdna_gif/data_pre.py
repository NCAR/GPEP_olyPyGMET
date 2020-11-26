import numpy as np
import netCDF4 as nc
from scipy import io

path = '/home/gut428/projects/rpp-kshook/gut428/EMDNA_v1/Estimate/2016'

dout = np.zeros([1300,800,100])
for e in range(100):
    file = '{}/EMDNA_2016.{:03}.nc4'.format(path,e+1)
    data =
