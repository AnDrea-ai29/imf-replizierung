
capture erase "JCR_DSV_TableS2.xml"
capture erase "JCR_DSV_TableS2.txt"

local depvar scope

  * Base model with only "nrquarterssmpl" included
  local fixvar `unvar' nrquarterssmpl
  quietly xtreg `depvar'_0 `fixvar' , fe
  quietly estimates store fixed
  quietly xtserial `depvar'_0 `fixvar' dumcnt*
  quietly local wpv = r(p)
  quietly regress `depvar'_0 `fixvar' dumcnt*
  quietly testparm dumcnt*
  quietly local fpv = r(p)  
  quietly estat hettest
  quietly local hetpv = r(p)
  outreg2 [fixed] using "JCR_DSV_TableS2", ctitle("xtreg fe `depvar'_0") addstat(Wooldridge, `wpv', F-test FE, `fpv', Breusch-Pagan, `hetpv') tstat excel append
  capture xtgls `depvar'_0 `fixvar' dumcnt* , i(idcnt) t(nrcntprogram) corr(ar1) force nmk
  capture outreg2 `fixvar' using "JCR_DSV_TableS2", ctitle("xtgls fe ar1 `depvar''_0") tstat excel append
  capture xtpoisson `depvar'_0 `fixvar' , fe 
  capture outreg2 `fixvar' using "JCR_DSV_TableS2", ctitle("xtpoisson fe `depvar''_0") tstat excel append

  * Base model with only "nrquarterssmpl" included - restricted sample
  local fixvar `unvar' nrquarterssmpl
  quietly xtreg `depvar'_0 `fixvar' if fullsample==1, fe
  quietly estimates store fixed
  quietly xtserial `depvar'_0 `fixvar' dumcnt* if fullsample==1
  quietly local wpv = r(p)
  quietly regress `depvar'_0 `fixvar' dumcnt* if fullsample==1
  quietly testparm dumcnt*
  quietly local fpv = r(p)  
  quietly estat hettest
  quietly local hetpv = r(p)
  outreg2 [fixed] using "JCR_DSV_TableS2", ctitle("xtreg fe `depvar'_0") addstat(Wooldridge, `wpv', F-test FE, `fpv', Breusch-Pagan, `hetpv') tstat excel append
  capture xtgls `depvar'_0 `fixvar' dumcnt* if fullsample==1, i(idcnt) t(nrcntprogram) corr(ar1) force nmk
  capture outreg2 `fixvar' using "JCR_DSV_TableS2", ctitle("xtgls fe ar1 `depvar''_0") tstat excel append
  capture xtpoisson `depvar'_0 `fixvar' if fullsample==1, fe 
  capture outreg2 `fixvar' using "JCR_DSV_TableS2", ctitle("xtpoisson fe `depvar''_0") tstat excel append

  * Full model 
  local fixvar `unvar' nrquarterssmpl `fullvar'
  quietly xtreg `depvar'_0 `fixvar' , fe
  quietly estimates store fixed
  quietly xtserial `depvar'_0 `fixvar' dumcnt*
  quietly local wpv = r(p)
  quietly regress `depvar'_0 `fixvar' dumcnt*
  quietly testparm dumcnt*
  quietly local fpv = r(p)  
  quietly estat hettest
  quietly local hetpv = r(p)
  outreg2 [fixed] using "JCR_DSV_TableS2", ctitle("xtreg fe `depvar'_0") addstat(Wooldridge, `wpv', F-test FE, `fpv', Breusch-Pagan, `hetpv') tstat excel append
  capture xtgls `depvar'_0 `fixvar' dumcnt* , i(idcnt) t(nrcntprogram) corr(ar1) force nmk
  capture outreg2 `fixvar' using "JCR_DSV_TableS2", ctitle("xtgls fe ar1 `depvar''_0") tstat excel append
  capture xtpoisson `depvar'_0 `fixvar' , fe 
  capture outreg2 `fixvar' using "JCR_DSV_TableS2", ctitle("xtpoisson fe `depvar''_0") tstat excel append

  * Truncated model 
  local fixvar `unvar' nrquarterssmpl ResXDebt
  quietly xtreg `depvar'_0 `fixvar' , fe
  quietly estimates store fixed
  quietly xtserial `depvar'_0 `fixvar' dumcnt*
  quietly local wpv = r(p)
  quietly regress `depvar'_0 `fixvar' dumcnt*
  quietly testparm dumcnt*
  quietly local fpv = r(p)  
  quietly estat hettest
  quietly local hetpv = r(p)
  outreg2 [fixed] using "JCR_DSV_TableS2", ctitle("xtreg fe `depvar'_0") addstat(Wooldridge, `wpv', F-test FE, `fpv', Breusch-Pagan, `hetpv') tstat excel append
  capture xtgls `depvar'_0 `fixvar' dumcnt* , i(idcnt) t(nrcntprogram) corr(ar1) force nmk
  capture outreg2 `fixvar' using "JCR_DSV_TableS2", ctitle("xtgls fe ar1 `depvar''_0") tstat excel append
  capture xtpoisson `depvar'_0 `fixvar' , fe 
  capture outreg2 `fixvar' using "JCR_DSV_TableS2", ctitle("xtpoisson fe `depvar''_0") tstat excel append

  * Truncated model - restricted sample
  local fixvar `unvar' nrquarterssmpl ResXDebt
  quietly xtreg `depvar'_0 `fixvar' if fullsample==1, fe
  quietly estimates store fixed
  quietly xtserial `depvar'_0 `fixvar' dumcnt* if fullsample==1
  quietly local wpv = r(p)
  quietly regress `depvar'_0 `fixvar' dumcnt* if fullsample==1
  quietly testparm dumcnt*
  quietly local fpv = r(p)  
  quietly estat hettest
  quietly local hetpv = r(p)
  outreg2 [fixed] using "JCR_DSV_TableS2", ctitle("xtreg fe `depvar'_0") addstat(Wooldridge, `wpv', F-test FE, `fpv', Breusch-Pagan, `hetpv') tstat excel append
  capture xtgls `depvar'_0 `fixvar' dumcnt* if fullsample==1, i(idcnt) t(nrcntprogram) corr(ar1) force nmk
  capture outreg2 `fixvar' using "JCR_DSV_TableS2", ctitle("xtgls fe ar1 `depvar''_0") tstat excel append
  capture xtpoisson `depvar'_0 `fixvar' if fullsample==1, fe 
  capture outreg2 `fixvar' using "JCR_DSV_TableS2", ctitle("xtpoisson fe `depvar''_0") tstat excel append

