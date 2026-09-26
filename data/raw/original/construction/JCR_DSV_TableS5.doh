
log using JCR_DSV_TableS5.log , replace name(TableS5)

* Produce Table with descriptive statistics 

local exovar avgcondtype_0 scope_0 unsc3 nrquarterssmpl legelec_l XDebtGNI DebtServGNI ResXDebt ExtBalGDP GFCFGDP USaidGDP imf_conc_gdp imf_noconc_gdp 

tabstat `exovar' if avgcondtype_0<. , statistics(count mean median min max sd skewness kurtosis) columns(statistics) 

log close TableS5
