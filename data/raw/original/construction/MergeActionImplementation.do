* Action.txt and Implementation.txt are - by using Excel and a Text Editor - converted to Action03.txt and Implementation03.txt
* Many changes are made by hand. Hence, the file ...03.txt contains the latest "raw" data which stem from the original mona file.

insheet using "Action03.txt" , tab clear names
summarize
sort unique
quietly compress
save "Action03.dta" , replace all 
clear all

insheet using "Implementation03.txt" , tab clear names
summarize
sort unique
quietly compress
save "Implementation03.dta" , replace all 

merge unique using "Action03.dta" 
*        _merge==1    obs. from master data                            
*        _merge==2    obs. from only one using dataset                 
*        _merge==3    obs. from at least two datasets, master or using 
tabulate _merge 

generate id = idact
replace id = idimp if id>=.
list unique if idact<. & idimp<. & idact!=idimp
generate nr = nract
replace nr = nrimp if nr==""
list unique if nract!="" & nrimp!="" & nract!=nrimp

drop if implementation=="" & action==""
drop if implementation=="?" & action==""

sort id unique
list unique id nr action if _merge==1
list unique id nr implementation if _merge==2
outsheet unique id nr action implementation _merge using "t.txt" if (_merge==1 & implementation!="") | (_merge==2 & action!="") , nolabel replace quote names

outsheet unique id nr action implementation using "ActionImplementation.txt" , nolabel replace quote names
keep unique id nr action implementation
summarize
save "ActionImplementation.dta" , replace all
clear all

insheet using "Data Structural 1993-2001.txt" , tab clear names
summarize
list id if action=="" & implementation==""
drop action implementation

sort id
merge id using "ActionImplementation.dta"
*        _merge==1    obs. from master data                            
*        _merge==2    obs. from only one using dataset                 
*        _merge==3    obs. from at least two datasets, master or using 
tabulate _merge 
*Note all these observations do contain neither information on Action nor on Implementation (checked above):
list unique id nr if _merge==1
drop _merge

save "Data Structural 1993-2001.dta" , replace all

