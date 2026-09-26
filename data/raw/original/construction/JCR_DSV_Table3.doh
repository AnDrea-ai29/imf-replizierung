
capture erase "JCR_DSV_Table3.xml"
capture erase "JCR_DSV_Table3.txt"

*local depvar avgcondtype

local depvarlist avgcondtype scope
foreach depvar in `depvarlist' {

 forvalues iter = 1/`max`depvar'' {
  * Base model with only "nrquarterssmpl" included
  local fixvar `unvar' nrquarterssmpl
  quietly xtgls `depvar'_`iter' `fixvar' dumcnt* , panels(hetero) force nmk
  outreg2 `fixvar' using "JCR_DSV_Table3", ctitle("xtgls fe het `depvar'_`iter'") tstat excel append

  * Base model with only "nrquarterssmpl" included - restricted sample
  quietly xtgls `depvar'_`iter' `fixvar' dumcnt* if fullsample==1, panels(hetero) force nmk
  outreg2 `fixvar' using "JCR_DSV_Table3", ctitle("xtgls fe het `depvar'_`iter'") tstat excel append

  * Full model 
  local fixvar `unvar' nrquarterssmpl `fullvar'
  quietly xtgls `depvar'_`iter' `fixvar' dumcnt* , panels(hetero) force nmk
  outreg2 `fixvar' using "JCR_DSV_Table3", ctitle("xtgls fe het `depvar'_`iter'") tstat excel append

  * Truncated model 
  if "`depvar'"=="scope" {
   local fixvar `unvar' nrquarterssmpl ResXDebt
   }
  if "`depvar'"=="avgcondtype" {
   local fixvar `unvar' nrquarterssmpl legelec_l imf_noconc_gdp
   }
  quietly xtgls `depvar'_`iter' `fixvar' dumcnt* , panels(hetero) force nmk
  outreg2 `fixvar' using "JCR_DSV_Table3", ctitle("xtgls fe het `depvar'_`iter'") tstat excel append

  * Truncated model - restricted sample
  quietly xtgls `depvar'_`iter' `fixvar' dumcnt* if fullsample==1, panels(hetero) force nmk
  outreg2 `fixvar' using "JCR_DSV_Table3", ctitle("xtgls fe het `depvar'_`iter'") tstat excel append
  }
 }
