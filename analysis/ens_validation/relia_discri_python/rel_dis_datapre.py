import numpy as np
from scipy import io
import os

inpath = '/home/gut428/scratch/GMET/ens_evaluation'
outpath = '.'
year=[1979, 2018]
thresh=[0,1,10,25,50]
nrnr = len(thresh)

# suffixall = ['-scale1', '-scale1.5', '-scale2', '-scale2.5','-scale1-pop1','-scale1-pop2','-scale1-pop3']
suffixall = ['']
for suffix in suffixall:
    prob_stn_all = np.nan * np.zeros([nrnr, 1])
    prob_ens_all = np.nan * np.zeros([nrnr, 1])
    for y in range(year[0], year[1] + 1):
        outfile = outpath + '/prcp_probability_' + str(y) + suffix + '.mat'
        if os.path.isfile(outfile):
            d = io.loadmat(outfile)
            prob_stn = d['prob_stn']
            prob_ens = d['prob_ens']
        else:
            file_stn = inpath + '/stn_prcp_' + str(y) + suffix + '.mat'
            file_ens = inpath + '/ens_prcp_' + str(y) + suffix + '.mat'
            d = io.loadmat(file_stn)
            data_stn = d['data_stn']
            LLE = d['data_stn']
            d = io.loadmat(file_ens)
            data_ens = d['data_ens']

            # calculate probability
            dnum, gnum, enum = np.shape(data_ens)
            prob_stn = np.nan * np.zeros([dnum, gnum, nrnr], dtype=np.float32)
            for n in range(nrnr):
                temp = np.nan * np.zeros([dnum, gnum], dtype=np.float32)
                temp[data_stn <= thresh[n]] = 0
                temp[data_stn > thresh[n]] = 1
                prob_stn[:, :, n] = temp

            prob_ens = np.nan * np.zeros([dnum, gnum, nrnr], dtype=np.float32)
            for d in range(dnum):
                for g in range(gnum):
                    ddg = data_ens[d, g, :]
                    for n in range(nrnr):
                        if not np.isnan(prob_stn[d, g, n]):
                            temp = np.nan * np.zeros(enum, dtype=np.float32)
                            temp[ddg <= thresh[n]] = 0
                            temp[ddg > thresh[n]] = 1
                            prob_ens[d, g, n] = np.nanmean(temp)
            io.savemat(outfile, {'prob_stn': prob_stn, 'prob_ens': prob_ens, 'LLE': LLE}, do_compression=True)
        # attach to _all
        dnum, gnum, nrnr = np.shape(prob_stn)
        temp1 = np.nan * np.zeros([nrnr, dnum*gnum], dtype=np.float32)
        temp2 = np.nan * np.zeros([nrnr, dnum*gnum], dtype=np.float32)
        for n in range(nrnr):
            temp1[n, :] = prob_stn[:,:,n].flatten()
            temp2[n, :] = prob_ens[:,:,n].flatten()

        ind = (np.sum(np.isnan(temp1), axis=0) == nrnr) & (np.sum(np.isnan(temp2), axis=0) == nrnr)
        prob_stn_all = np.hstack((prob_stn_all, temp1[:, ~ind]))
        prob_ens_all = np.hstack((prob_ens_all, temp2[:, ~ind]))

    outfile = outpath + '/reliab_discri_data_' + str(year[0]) + '-' + str(year[1]) + suffix + '.mat'
    prob_stn_all = prob_stn_all[:, 1:]
    prob_ens_all = prob_ens_all[:, 1:]
    bin = np.arange(0, 1.1, 0.1)
    bin2 = np.arange(0.05, 1.05, 0.1)
    binnum = len(bin) - 1

    # prepare reliability diagram data
    reliab_data = np.nan * np.zeros([binnum, 2, nrnr]) # stn / ens
    for i in range(binnum):
        for n in range(nrnr):
            indi = (prob_ens_all[n, :] >= bin[i]) & (prob_ens_all[n, :] <= bin[i+1])
            reliab_data[i, 0, n] = np.nanmean(prob_stn_all[n, indi])
            reliab_data[i, 1, n] = np.nanmean(prob_ens_all[n, indi])

    # prepare discrimination diagram data
    discri_data = np.nan * np.zeros([binnum, 2, nrnr]) # event / no event
    for n in range(nrnr):
        ind_event = prob_stn_all[n, :] == 1
        ind_noevent = prob_stn_all[n, :] == 0
        num_event = np.sum(ind_event)
        num_noevent = np.sum(ind_noevent)
        pensn_event = prob_ens_all[n, ind_event]
        pensn_noevent = prob_ens_all[n, ind_noevent]
        for i in range(binnum):
            ind = (pensn_event >= bin[i]) & (pensn_event <= bin[i+1])
            discri_data[i, 0, n] = np.sum(ind) / num_event
            ind = (pensn_noevent >= bin[i]) & (pensn_noevent <= bin[i + 1])
            discri_data[i, 1, n] = np.sum(ind) / num_noevent

    io.savemat(outfile,{'discri_data':discri_data, 'reliab_data':reliab_data, 'bin':bin2,
                        'year':year, 'thresh':thresh},do_compression=True)

