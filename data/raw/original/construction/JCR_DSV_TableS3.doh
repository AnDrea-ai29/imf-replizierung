
capture erase "JCR_DSV_TableS3.xml"
capture erase "JCR_DSV_TableS3.txt"

local depvar scope

 forvalues iter = 1/`max`depvar'' {
  * Base model with only "nrquarterssmpl" included
  local fixvar `unvar' nrquarterssmpl
  quietly xtgls `depvar'_`iter' `fixvar' dumcnt* , i(idcnt) t(nrcntprogram) corr(ar1) force nmk
  outreg2 `fixvar' using "JCR_DSV_TableS3", ctitle("xtgls fe het `depvar'_`iter'") tstat excel append

  * Base model with only "nrquarterssmpl" included - restricted sample
  local fixvar `unvar' nrquarterssmpl
  quietly xtgls `depvar'_`iter' `fixvar' dumcnt* if fullsample==1, i(idcnt) t(nrcntprogram) corr(ar1) force nmk
  outreg2 `fixvar' using "JCR_DSV_TableS3", ctitle("xtgls fe het `depvar'_`iter'") tstat excel append

  * Full model 
  local fixvar `unvar' nrquarterssmpl `fullvar'
  quietly xtgls `depvar'_`iter' `fixvar' dumcnt* , i(idcnt) t(nrcntprogram) corr(ar1) force nmk
  outreg2 `fixvar' using "JCR_DSV_TableS3", ctitle("xtgls fe het `depvar'_`iter'") tstat excel append

  * Truncated model 
  local fixvar `unvar' nrquarterssmpl ResXDebt
  quietly xtgls `depvar'_`iter' `fixvar' dumcnt* , i(idcnt) t(nrcntprogram) corr(ar1) force nmk
  outreg2 `fixvar' using "JCR_DSV_TableS3", ctitle("xtgls fe het `depvar'_`iter'") tstat excel append

  * Truncated model - restricted sample
  local fixvar `unvar' nrquarterssmpl ResXDebt
  quietly xtgls `depvar'_`iter' `fixvar' dumcnt* if fullsample==1, i(idcnt) t(nrcntprogram) corr(ar1) force nmk
  outreg2 `fixvar' using "JCR_DSV_TableS3", ctitle("xtgls fe het `depvar'_`iter'") tstat excel append
  }
 