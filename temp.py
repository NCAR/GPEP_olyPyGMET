import xarray
import glob
import os

path = '/home/gut428/scratch/GMET/EMDNA_out/Estimate'
path= '.'
year = [1979, 1979]

for y in range(year[0], year[1]+1):
    for e in range(1, 2):
        print('processing year/ens: ', y, e)
        # merge 12 months
        outfile = '{}/{}/EMDNA_{}.{:03d}.nc4'.format(path,y,y,e)
        if not os.path.isfile(outfile):
            filee = '{}/*{:03d}.nc4'.format(path,e)
            ds = xarray.merge([xarray.open_dataset(f) for f in glob.glob(filee)])
            comp = dict(zlib=True, complevel=9)
            encoding = {var: comp for var in ds.data_vars}
            ds.to_netcdf(outfile, encoding=encoding)