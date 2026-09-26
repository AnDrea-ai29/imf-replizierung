
capture erase "JCR_DSV_TableS4.xml"
capture erase "JCR_DSV_TableS4.txt"

local depvar scopearr

 forvalues iter = 1/`max`depvar'' {
  * Base model with only "nrquarterssmpl" included
  local fixvar `unvar' nrquarterssmpl
  capture xtgls `depvar'_`iter' `fixvar' dumcnt* , panels(hetero) force nmk
  capture outreg2 `fixvar' using "JCR_DSV_TableS4", ctitle("xtgls fe het `depvar'_`iter'") tstat excel append

  * Base model with only "nrquarterssmpl" included - restricted sample
  local fixvar `unvar' nrquarterssmpl
  capture xtgls `depvar'_`iter' `fixvar' dumcnt* if fullsample==1 , panels(hetero) force nmk
  capture outreg2 `fixvar' using "JCR_DSV_TableS4", ctitle("xtgls fe het `depvar'_`iter'") tstat excel append

  * Full model 
  local fixvar `unvar' nrquarterssmpl `fullvar'
  capture xtgls `depvar'_`iter' `fixvar' dumcnt* , panels(hetero) force nmk
  capture outreg2 `fixvar' using "JCR_DSV_TableS4", ctitle("xtgls fe het `depvar'_`iter'") tstat excel append
  }
