
capture erase "JCR_DSV_Table2.xml"
capture erase "JCR_DSV_Table2.txt"

*local depvar avgcondtype

local depvarlist avgcondtype scope
foreach depvar in `depvarlist' {

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
  outreg2 [fixed] using "JCR_DSV_Table2", ctitle("xtreg fe `depvar'_0") addstat(Wooldridge, `wpv', F-test FE, `fpv', Breusch-Pagan, `hetpv') tstat excel append
  quietly xtgls `depvar'_0 `fixvar' dumcnt* , panels(hetero) force nmk
  outreg2 `fixvar' using "JCR_DSV_Table2", ctitle("xtgls fe het `depvar'_0") tstat excel append

  * Base model with only "nrquarterssmpl" included - restricted sample
  local fixvar `unvar' nrquarterssmpl
  quietly xtreg `depvar'_0 `fixvar' if fullsample==1, fe
  quietly estimates store fixed
  quietly xtserial `depvar'_0 `fixvar' dumcnt*  if fullsample==1
  quietly local wpv = r(p)
  quietly regress `depvar'_0 `fixvar' dumcnt*  if fullsample==1
  quietly testparm dumcnt*
  quietly local fpv = r(p)  
  quietly estat hettest
  quietly local hetpv = r(p)
  outreg2 [fixed] using "JCR_DSV_Table2", ctitle("xtreg fe `depvar'_0") addstat(Wooldridge, `wpv', F-test FE, `fpv', Breusch-Pagan, `hetpv') tstat excel append
  quietly xtgls `depvar'_0 `fixvar' dumcnt*  if fullsample==1, panels(hetero) force nmk
  outreg2 `fixvar' using "JCR_DSV_Table2", ctitle("xtgls fe het `depvar'_0") tstat excel append

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
  outreg2 [fixed] using "JCR_DSV_Table2", ctitle("xtreg fe `depvar'_0") addstat(Wooldridge, `wpv', F-test FE, `fpv', Breusch-Pagan, `hetpv') tstat excel append
  quietly xtgls `depvar'_0 `fixvar' dumcnt* , panels(hetero) force nmk
  outreg2 `fixvar' using "JCR_DSV_Table2", ctitle("xtgls fe het `depvar'_0") tstat excel append

  * Truncated model 
  if "`depvar'"=="scope" {
   local fixvar `unvar' nrquarterssmpl ResXDebt
   }
  if "`depvar'"=="avgcondtype" {
   local fixvar `unvar' nrquarterssmpl legelec_l imf_noconc_gdp
   }
  quietly xtreg `depvar'_0 `fixvar' , fe
  quietly estimates store fixed
  quietly xtserial `depvar'_0 `fixvar' dumcnt*
  quietly local wpv = r(p)
  quietly regress `depvar'_0 `fixvar' dumcnt*
  quietly testparm dumcnt*
  quietly local fpv = r(p)  
  quietly estat hettest
  quietly local hetpv = r(p)
  outreg2 [fixed] using "JCR_DSV_Table2", ctitle("xtreg fe `depvar'_0") addstat(Wooldridge, `wpv', F-test FE, `fpv', Breusch-Pagan, `hetpv') tstat excel append
  quietly xtgls `depvar'_0 `fixvar' dumcnt* , panels(hetero) force nmk
  outreg2 `fixvar' using "JCR_DSV_Table2", ctitle("xtgls fe het `depvar'_0") tstat excel append

  * Truncated model - restricted sample
  quietly xtreg `depvar'_0 `fixvar' if fullsample==1, fe
  quietly estimates store fixed
  quietly xtserial `depvar'_0 `fixvar' dumcnt* if fullsample==1
  quietly local wpv = r(p)
  quietly regress `depvar'_0 `fixvar' dumcnt* if fullsample==1
  quietly testparm dumcnt*
  quietly local fpv = r(p)  
  quietly estat hettest
  quietly local hetpv = r(p)
  outreg2 [fixed] using "JCR_DSV_Table2", ctitle("xtreg fe `depvar'_0") addstat(Wooldridge, `wpv', F-test FE, `fpv', Breusch-Pagan, `hetpv') tstat excel append
  quietly xtgls `depvar'_0 `fixvar' dumcnt* if fullsample==1, panels(hetero) force nmk
  outreg2 `fixvar' using "JCR_DSV_Table2", ctitle("xtgls fe het `depvar'_0") tstat excel append
 }
