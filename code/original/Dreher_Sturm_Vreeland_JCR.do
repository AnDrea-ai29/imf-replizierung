clear
capture log close
set more off

***********************IMPORTANT***************************************************
* Change local DIR to the directory where you store the raw data
local DIR = "\a\unsc\conditionality\Production\" 
cd "`DIR'" 
***********************************************************************************

log using "Dreher_Sturm_Vreeland_JCR.log", replace

set linesize 255

use "Dreher_Sturm_Vreeland_JCR.dta", clear

* Find out how often a country is under an IMF program (i.e. how many programs) in our sample
quietly tabulate idcnt, gen(dumcnt)

local maxavgarrtype = 2
local maxavgcondtype = 3
local maxscope = `maxavgcondtype'
local maxscopearr = `maxavgarrtype'
local maxavgareaclass = 20

local unvar unsc3
local fullvar legelec_l XDebtGNI DebtServGNI ResXDebt ExtBalGDP GFCFGDP USaidGDP imf_conc_gdp imf_noconc_gdp 

*Produce tables in the main text
include JCR_DSV_Table1.doh
include JCR_DSV_Table2.doh
include JCR_DSV_Table3.doh
include JCR_DSV_Table4.doh
include JCR_DSV_Table5.doh

*Produce tables in the supplement
include JCR_DSV_TableS1.doh
include JCR_DSV_TableS2.doh
include JCR_DSV_TableS3.doh
include JCR_DSV_TableS4.doh
include JCR_DSV_TableS5.doh

log close
