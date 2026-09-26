
log using JCR_DSV_Table1.log , replace name(Table1)

* Produce table showing levels of IMF conditionality for countries serving on the UN Security Council (election year included)
sort year country
list country year avgcondtype_all scope_all if unsc3==1 , separator(0)
sort idcnt nrcntprogram

log close Table1
