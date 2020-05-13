import numpy as np
import calendar
import auxiliary as au

# compare the error estimation at station points before/after transformation

year = 1979
path = '/Users/localuser/GMET/error_compare'
nstn=27275
pcp_stn = np.nan * np.zeros([nstn,365])
pcp_regt = np.nan * np.zeros([nstn,365])
pcp_regn = np.nan * np.zeros([nstn,365])

flag=0
for m in range(5):
    date_cal_start = year*10000 + (m + 1)*100 + 1
    date_cal_end = year*10000 + (m + 1)*100 + calendar.monthrange(year, m+1)[1]
    print('Date',date_cal_start,date_cal_end)


    datestr = str(date_cal_start) + '-' + str(date_cal_end)

    FileWeight = '/datastore/GLOBALWATER/CommonData/EMDNA/PyGMETout/weight.npz'
    # load station data
    file = path + '/stndata_' + datestr + '.npz'
    datatemp = np.load(file)
    pstn = datatemp['prcp_stn_daily']
    del datatemp

    file = path + '/error_' + datestr + '.npz'
    datatemp = np.load(file)
    pcp_err = datatemp['pcp_err_stn']
    pregt = au.retransform(au.transform(pstn,4,'box-cox') + pcp_err, 4,'box-cox')
    del datatemp

    file = path + '/error_notrans_' + datestr + '.npz'
    datatemp = np.load(file)
    pcp_err = datatemp['pcp_err_stn']
    pregn = pstn + pcp_err
    del datatemp

    nday=np.shape(pstn)[1]
    pcp_stn[:,flag:flag+nday] = pstn
    pcp_regt[:, flag:flag + nday] = pregt
    pcp_regn[:, flag:flag + nday] = pregn

    flag=flag+nday


errt=np.zeros([nstn,4])
errn=np.zeros([nstn,4])
for i in range(nstn):
    obs = pcp_stn[i, :]

    pre=pcp_regt[i,:]
    errt[i,:]=au.metric(obs, pre)

    pre=pcp_regn[i,:]
    errn[i,:]=au.metric(obs, pre)

print(np.nanmedian(errt,axis=0),np.nanmean(errt,axis=0))
print(np.nanmedian(errn,axis=0),np.nanmean(errn,axis=0))