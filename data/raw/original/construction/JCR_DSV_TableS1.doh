
log using JCR_DSV_TableS1.log , replace name(TableS1)

local listcondtype = "all pc pa sb" 

* Produce with descriptive statistics divided across the different arrangements
* Create necessary matrices
matrix Tab1 = J(4,`maxavgarrtype'+1,0)
matrix colnames Tab1 = "All" "EFF/SBA" "PRGF" 
matrix rownames Tab1 = "Nr of countries" "Nr of years" "Nr of programs" "Avg nr of quarters"
foreach ctype in `listcondtype' {
 matrix Tab_sum_`ctype' = J(1,`maxavgarrtype'+1,0)
 matrix rownames Tab_sum_`ctype' = "Sum `ctype'"
 matrix Tab_avg_`ctype' = J(1,`maxavgarrtype'+1,0)
 matrix rownames Tab_avg_`ctype' = "Avg `ctype'"
 matrix Tab_avgqrt_`ctype' = J(1,`maxavgarrtype'+1,0)
 matrix rownames Tab_avgqrt_`ctype' = "Avg per quarter `ctype'"
 matrix Tab_scope_`ctype' = J(1,`maxavgarrtype'+1,0)
 matrix rownames Tab_scope_`ctype' = "Scope `ctype'"
 }

* Fill in the matrices
forvalues atype = 0/`maxavgarrtype' {
 capture xtreg avgcondtype_all if nrarrtype_`atype'>0, fe
 quietly matrix Tab1[1,`atype'+1] = e(N_g)
 quietly xtset approvalyear idcnt 
 capture xtreg avgcondtype_all if nrarrtype_`atype'>0, fe 
 quietly matrix Tab1[2,`atype'+1] = e(N_g)
 quietly xtset idcnt nrcntprogram

 quietly summarize nrcntprogram if nrarrtype_`atype'>0
 quietly matrix Tab1[3,`atype'+1] = r(N)
 quietly summarize nrquarterssmpl if nrarrtype_`atype'>0
 quietly matrix Tab1[4,`atype'+1] = r(mean)
 foreach ctype in `listcondtype' {
  quietly egen temp = sum(nrcondtype_`ctype') if nrarrtype_`atype'>0
  quietly summarize temp if nrarrtype_`atype'>0
  quietly matrix Tab_sum_`ctype'[1,`atype'+1] = r(mean)
  quietly drop temp 
  quietly summarize avgcondtype_`ctype' if nrarrtype_`atype'>0
  quietly matrix Tab_avgqrt_`ctype'[1,`atype'+1] = r(mean)
  quietly summarize scope_`ctype' if nrarrtype_`atype'>0
  quietly matrix Tab_scope_`ctype'[1,`atype'+1] = r(mean)
  }
 }

* Stack the matrices
foreach ctype in `listcondtype' {
 matrix Tab1 = Tab1 \ Tab_sum_`ctype'
 }
foreach ctype in `listcondtype' {
 matrix Tab1 = Tab1 \ Tab_avgqrt_`ctype'
 }
foreach ctype in `listcondtype' {
 matrix Tab1 = Tab1 \ Tab_scope_`ctype'
 }

* Display the matrix
matrix list Tab1 , title("Table 1: Descriptive Statistics")

log close TableS1
