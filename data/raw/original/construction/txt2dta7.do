*As compared to txt2dta3.do this version reduces the number of arrangement types further (from 6/3 to 2)
*As compared to txt2dta4.do this version creates two additional potential dependent variables by (not) dividing by nrquarters
set linesize 80
set mem 100m

* Read in the relevant country codes used in this analysis 
* The original source is "country_codes.xls"
insheet using "country_codes.csv" , comma clear names
generate name_from_country_codes = name
replace wdicode = "YUG" if name=="yugoslavia"
sort name
quietly compress
save "country_codes.dta" , replace all 
clear all

* Read in the data from the MONA database 
set mem 100m
insheet using "MONA/Data Structural 2001-2008.txt" , tab clear names
sort orgorder
save "MONA/Data Structural 2001-2008.dta" , replace all
clear all
insheet using "MONA/Data Performance 2001-2008.txt" , tab clear names
sort orgorder
save "MONA/Data Performance 2001-2008.dta" , replace all
clear all
insheet using "MONA/Data Performance 1993-2001.txt" , tab clear names
sort orgorder
save "MONA/Data Performance 1993-2001.dta" , replace all
clear all

*Note: this DTA file is created using "MergeActionImplementation.do" (using "Data Structural 1993-2001.txt")
use "MONA/Data Structural 1993-2001.dta"
sort orgorder
merge orgorder using "Data Structural 2001-2008.dta" 
*        _merge==1    obs. from master data                            
*        _merge==2    obs. from only one using dataset                 
*        _merge==3    obs. from at least two datasets, master or using 
tabulate _merge 
drop _merge
sort orgorder
merge orgorder using "MONA/Data Performance 2001-2008.dta" 
*        _merge==1    obs. from master data                            
*        _merge==2    obs. from only one using dataset                 
*        _merge==3    obs. from at least two datasets, master or using 
tabulate _merge 
drop _merge
sort orgorder
merge orgorder using "MONA/Data Performance 1993-2001.dta" 
*        _merge==1    obs. from master data                            
*        _merge==2    obs. from only one using dataset                 
*        _merge==3    obs. from at least two datasets, master or using 
tabulate _merge 
drop _merge

generate idS9301 = id

* Generate variables to identify the number of reviews
generate revtypenr = 0 if reviewtype=="OC"
replace revtypenr = 0 if reviewtype=="R0" 
replace revtypenr = 1 if reviewtype=="R1" 
replace revtypenr = 11 if reviewtype=="R11" 
replace revtypenr = 2 if reviewtype=="R2" 
replace revtypenr = 2.5 if reviewtype=="R2R3" 
replace revtypenr = 3 if reviewtype=="R3" 
replace revtypenr = 3.5 if reviewtype=="R3R4" 
replace revtypenr = 4 if reviewtype=="R4" 
replace revtypenr = 4.5 if reviewtype=="R4R5" 
replace revtypenr = 5 if reviewtype=="R5" 
replace revtypenr = 5.5 if reviewtype=="R5R6" 
replace revtypenr = 6 if reviewtype=="R6" 
replace revtypenr = 7 if reviewtype=="R7" 
replace revtypenr = 8 if reviewtype=="R8" 
replace revtypenr = 9 if reviewtype=="R9" 
generate revtype_r0 = 1 if revtypenr==0
generate revtype_r1 = 1 if revtypenr==1
generate revtype_r11 = 1 if revtypenr==11
generate revtype_r2 = 1 if revtypenr==2
generate revtype_r2r3 = 1 if revtypenr==2.5
generate revtype_r3 = 1 if revtypenr==3
generate revtype_r3r4 = 1 if revtypenr==3.5
generate revtype_r4 = 1 if revtypenr==4
generate revtype_r4r5 = 1 if revtypenr==4.5
generate revtype_r5 = 1 if revtypenr==5
generate revtype_r5r6 = 1 if revtypenr==5.5
generate revtype_r6 = 1 if revtypenr==6
generate revtype_r7 = 1 if revtypenr==7
generate revtype_r8 = 1 if revtypenr==8
generate revtype_r9 = 1 if revtypenr==9

tabulate revtypenr

generate arrprogram = arrnum
replace arrprogram = arrange if arrprogram>=.
replace countryname = country if countryname==""
replace arrtype = arrangement if arrtype==""
replace arrtype = arrangetype if arrtype==""
generate condtype = spc_pa_sb
replace condtype = keycode if condtype==""
replace approvaldate = boardapprovaldate if approvaldate==""

generate enddate = revisedenddate
replace enddate = initialenddate if enddate==""
replace enddate = durationto if enddate==""
replace enddate = actualenddate if enddate==""
generate areacode = econcode
replace areacode = dqpccode if areacode>=.
replace areacode = quantperfcode if areacode>=.
generate areadescription = econdescrpt
replace areadescription = description if areadescription==""
replace areadescription = dqpc if areadescription==""
generate areanote = descpt 
replace areanote = action if areanote==""
replace areanote = dqpcnote if areanote==""
replace revstatus = status if revstatus==""
*replace revstatus = implementation if revstatus==""

*Create dummies which state what type of conditions are meant
generate structcond = 0 if strucperf=="performance"
replace structcond = 1 if strucperf=="structural"
generate quantperf = 0 if strucperf=="structural"
replace quantperf = 1 if strucperf=="performance"

tabulate structcond
tabulate quantperf

*Correct typo in original data
local varlist "Conitnuous Cont Cont. Conti Conti. Contin Contin. Continu Continu. Continue Continuou continuous"
foreach iter of local varlist {
 replace testdate = "Continuous" if testdate=="`iter'"
 }
replace testdate = "Continuous" if testdate=="3 months after end of each quarter"

*Correct typo in original data
replace revstatus = "MOD" if revstatus=="MMOD"
replace revstatus = "MOD" if revstatus=="MMod"
replace revstatus = "MOD" if revstatus=="Mod"
*Criteria which are to be tested in the future and therefore unkown at this stage
replace revstatus = "NA" if revstatus=="AC" | revstatus=="PA" | revstatus=="PC" | revstatus=="SB" | revstatus=="n.a."

*Improve readability of particular variables
replace revstatus = "Met (M)"			if revstatus=="M"
replace revstatus = "Delayed (DL)"		if revstatus=="DL"
replace revstatus = "Not Met (NM)"		if revstatus=="NM"
replace revstatus = "Waived (W)"		if revstatus=="W"
replace revstatus = "Partly Met (PM)"		if revstatus=="PM"
replace revstatus = "Cancelled (CAN)"		if revstatus=="CAN"
replace revstatus = "Modified (MOD)"		if revstatus=="MOD"
replace revstatus = "Met With Delay (MD)"	if revstatus=="MD"
replace revstatus = "??? (NMOD)"		if revstatus=="NMod"
replace revstatus = "??? (WM)"			if revstatus=="WM"

tabulate revstatus, gen(revstatus_)
label variable revstatus_1	"??? (NMOD)"
label variable revstatus_2	"??? (WM)"
label variable revstatus_3	"Cancelled (CAN)"
label variable revstatus_4	"Delayed (DL)"
label variable revstatus_5	"Met (M)"
label variable revstatus_6	"Met With Delay (MD)"
label variable revstatus_7	"Modified (MOD)"
label variable revstatus_8	"NA"
label variable revstatus_9	"Not Met (NM)"
label variable revstatus_10	"Partly Met (PM)"
label variable revstatus_11	"Waived (W)"
generate revstatus_0 = revstatus_1 + revstatus_2 + revstatus_3 + revstatus_4 + revstatus_5 + revstatus_6 + revstatus_7 + revstatus_8 + revstatus_9 + revstatus_10 + revstatus_11
summarize revstatus_*


replace condtype = "Quantitative Performance Criteria" 		if strucperf=="performance"
replace condtype = "Structural Benchmark" 			if condtype=="1. Structural benchmark" | condtype=="SB"
replace condtype = "Structural Performance Criteria" 		if condtype=="2. Performance criterion" | condtype=="SPC"
replace condtype = "Prior Action" 				if condtype=="3. Condition for completing review" | condtype=="PA"
replace condtype = "Struct.Benchmark and Prior Action" 		if condtype=="4. Structural benchmark and condition for completing review"
*We think "SAC" is a typing error and should actually be "SPC":
replace condtype = "Structural Performance Criteria" 		if condtype=="SAC"
*We reduce the condition types to 3+1 (PA, PC, SB, SB+PA)
replace condtype = "Performance Criteria" 			if condtype=="Quantitative Performance Criteria" | condtype=="Structural Performance Criteria"

tabulate condtype , gen(condtype_)
label variable condtype_1  		"Condition type: Performance Criteria" 		
label variable condtype_2  		"Condition type: Prior Action" 			
label variable condtype_3  		"Condition type: Struct.Benchmark and Prior Action"	
label variable condtype_4  		"Condition type: Structural Benchmark" 		
generate condtype_0 = condtype_1 + condtype_2 + condtype_3 + condtype_4
*Remove joint type (Note that 0 ~= 1+2+3 !)
replace condtype_2 = condtype_2 + condtype_3
replace condtype_4 = condtype_4 + condtype_3
drop condtype_3
rename condtype_4 condtype_3
summarize condtype_*
local maxcondtype = 3


*NOTE: arrtype contains 7 different arrangement types, whereas nrarrtype (arrtype_) only contains 3 arrangement types!
tabulate arrtype , gen(arrtype_)
label variable arrtype_1		"Arrangement type: EFF"
label variable arrtype_2		"Arrangement type: ESAF"
label variable arrtype_3		"Arrangement type: PRGF"
label variable arrtype_4		"Arrangement type: PRGF-EFF"
label variable arrtype_5		"Arrangement type: PSI"
label variable arrtype_6		"Arrangement type: SAF"
label variable arrtype_7		"Arrangement type: SBA"
generate arrtype_0 = ((arrtype_1==1)+(arrtype_2==1)+(arrtype_3==1)+(arrtype_4==1)+(arrtype_5==1)+(arrtype_6==1)+(arrtype_7==1))>0
* Remove joint type (Note that 0 ~= 1+2+3+4+5+6 !)
* aggregate SAF, ESAF and PRGF into PRGF and drop PSI from the analysis 
replace arrtype_1 = ((arrtype_1==1)+(arrtype_4==1)+(arrtype_7==1))>0
replace arrtype_2 = ((arrtype_2==1)+(arrtype_3==1)+(arrtype_4==1)+(arrtype_6==1))>0
drop arrtype_3 arrtype_4 arrtype_5 arrtype_6 arrtype_7
label variable arrtype_1		"Arrangement type: EFF"
label variable arrtype_2		"Arrangement type: PRGF"

summarize arrtype_*

*Create stata dates and year variables out of the variables which contain date-information
generate approvaldatestata = date(approvaldate,"DMY")
generate approvalyear = year(approvaldatestata)
generate enddatestata = date(enddate,"DMY")
summarize approval* enddate*
*Note: MDY instead of DMY!
*Note that for testdate observations are lost as also other information is stored in that series!
generate testdatestata = date(testdate,"MDY")
summarize testdate*
tabulate testdate if testdatestata>=.

*Merge data with "country_codes"
generate name = countryname
*Adjust some country label to those as available in the "country_codes" file(s)
replace name = "ethiopia (new)" if countryname=="ethiopia"
replace name = "afghanistan" if countryname=="afghanistan,islamic republic of" 
replace name = "democratic republic of the congo" if countryname=="congo, democratic republic of" 
replace name = "congo" if countryname=="congo, republic of" 
replace name = "gambia" if countryname=="gambia, the" 
replace name = "kyrgyzstan" if countryname=="kyrgyz republic" 
replace name = "lao people's democratic republic" if countryname=="lao people's dem. rep." 
replace name = "macedonia" if countryname=="macedonia (fyr)" 
replace name = "republic of moldova" if countryname=="moldova" 
replace name = "slovakia" if countryname=="slovak republic" 
replace name = "united republic of tanzania" if countryname=="tanzania" 
replace name = "venezuela (bolivarian republic of)" if countryname=="venezuela" 
replace name = "viet nam" if countryname=="vietnam" 
sort name
merge name using "country_codes.dta" 
*        _merge==1    obs. from master data                            
*        _merge==2    obs. from only one using dataset                 
*        _merge==3    obs. from at least two datasets, master or using 
tabulate _merge 
tabulate countryname if _merge==1
*tabulate name if _merge==2
drop if _merge==2
drop name _merge

* Define which observations belong to which program
sort countryname approvaldate arrtype programtype condtype testdate areacode
generate countobs = _n
generate programnr = 1
generate programnew = !(countryname[_n]==countryname[_n-1] & approvaldate[_n]==approvaldate[_n-1])
replace programnr = programnr[_n-1]+programnew if countobs>1
summarize countobs programnew programnr
tabulate programnr

*Create quantitative categorical variables out of the categorical variables which are not numerical in nature
local varlist strucperf arrprogram countryname wdicode arrtype condtype approvaldate enddate areacode areadescription programtype revstatus testdate
* Too many values: orgorder areanote 
foreach iter of local varlist {
 quietly summarize `iter'
 if r(N)==0 {
  quietly encode `iter', generate(`iter'dum)
  }
 }

*Summarize the data needed to classify the conditions per program
summarize aclpcode programnr approvaldatestata enddatestata testdatestata revtypenr

keep idS9301 orgorder* countryname* wdicode aclpcode* programnr* condtype* strucperf* structcond* quantperf* arrprogram* arrtype* approval* enddate* testdate* areacode* areadescription* areanote* programtype* revtype* revstatus*
sort programnr condtype areadescription testdate
save "MONA/Data MONA.dta" , replace all
clear all


* Program to create an area classification index
* based on "dqpc", "econdescrpt", and "description"
* (which are all united in "areadescription")

* Read in file in which - by hand - the correct coding have been accomplished
* (done in "MONA/IMF conditions area classifications V03.xls")
insheet using "MONA/Desc2AreaClass.csv" , clear names
generate areadescrsmv = lower(areadescription)
replace areadescrsmv = itrim(areadescrsmv)
replace areadescrsmv = ltrim(areadescrsmv)
replace areadescrsmv = rtrim(areadescrsmv)
replace areadescrsmv = abbrev(areadescrsmv,32)
sort areadescrsmv
quietly compress
save "MONA/Desc2AreaClass.dta" , replace all 
clear all

* Merge data with existing data
use "MONA/Data MONA.dta"
generate areadescrsmv = lower(areadescription)
replace areadescrsmv = itrim(areadescrsmv)
replace areadescrsmv = ltrim(areadescrsmv)
replace areadescrsmv = rtrim(areadescrsmv)
replace areadescrsmv = abbrev(areadescrsmv,32)
sort areadescrsmv
merge areadescrsmv using "MONA/Desc2AreaClass.dta" 
*        _merge==1    obs. from master data                            
*        _merge==2    obs. from only one using dataset                 
*        _merge==3    obs. from at least two datasets, master or using 
tabulate _merge 
list areadescrsmv if _merge==2
tabulate areadescrsmv if _merge==1
drop _merge
sort orgorder

*replace areaclass = "Non Available" if areaclass==""
tabulate areaclass , gen(areaclass_)
label variable areaclass_1		"Area class: Arrears"
label variable areaclass_2		"Area class: BOP/ Reserves"
label variable areaclass_3		"Area class: Capital Account"
label variable areaclass_4		"Area class: Central Bank Reform"
label variable areaclass_5		"Area class: Credit to Government"
label variable areaclass_6		"Area class: Debt"
label variable areaclass_7		"Area class: Exchange system"
label variable areaclass_8		"Area class: Financial sector"
label variable areaclass_9		"Area class: Governance"
label variable areaclass_10		"Area class: Government Budget"
label variable areaclass_11		"Area class: Monetary Ceiling"
label variable areaclass_12		"Area class: Other"
label variable areaclass_13		"Area class: Pricing"
label variable areaclass_14		"Area class: Private Sector Reforms"
label variable areaclass_15		"Area class: Privatization"
label variable areaclass_16		"Area class: Public Sector"
label variable areaclass_17		"Area class: Social"
label variable areaclass_18		"Area class: Systemic"
label variable areaclass_19		"Area class: Trade"
label variable areaclass_20		"Area class: Wages & Pensions"
*label variable areaclass_12		"Area class: Non Available"
generate areaclass_0 = areaclass_1 + areaclass_2 + areaclass_3 + areaclass_4 + areaclass_5 + areaclass_6 + areaclass_7 + areaclass_8 + areaclass_9 + areaclass_10 + areaclass_11 + areaclass_12 + areaclass_13 + areaclass_14 + areaclass_15 + areaclass_16 + areaclass_17 + areaclass_18 + areaclass_19 + areaclass_20
summarize areaclass_*
quietly encode areaclass, generate(areaclassdum)
summarize areaclassdum
local maxareaclass = r(max)


save "MONA/Data MONA.dta" , replace all 
outsheet using "MONA/Data MONA.txt" , nolabel replace quote names 
outsheet using "MONA/Data MONA.csv" , comma nolabel replace quote names
clear all

** Create file which contains information per country and arrangement at the date of approval
use "MONA/Data MONA.dta"

*Make sure that we can sort all potential testdates (even for S9301-data)
replace testdatestata = 1000000+idS9301 if testdatestata>=. & idS9301<.
summarize testdatestata if substr(orgorder,1,5)=="S9301"
summarize testdatestata if substr(orgorder,1,5)!="S9301"

*Actual procedures to count the number of tests, condition types and area classes
generate temp = testdatestata if quantperf==1
sort programnr temp testdatestata orgorder
replace temp = . if testdatestata[_n]==testdatestata[_n-1] & programnr[_n]==programnr[_n-1] 
egen nrtests = count(temp) , by(programnr)
drop temp*

generate temp = revtypenr
sort programnr revtypenr testdatestata orgorder
replace temp = . if revtypenr[_n]==revtypenr[_n-1] & programnr[_n]==programnr[_n-1] 
by programnr : egen nrreviews = count(temp)
drop temp

forvalues iter = 0/`maxcondtype' {
* egen nrcond_`iter' = sum(condtype_`iter') , by(programnr) 
 forvalues iter2 = 0/`maxareaclass' {
  generate c_`iter'a_`iter2' = condtype_`iter'*areaclass_`iter2'
*  generate temp = condtype_`iter'*areaclass_`iter2'
*  egen nrc_`iter'a_`iter2' = sum(temp) , by(programnr)
*  drop temp
  }
 }
summarize c_*

*forvalues iter = 0/`maxareaclass' {
* egen nrarea_`iter' = sum(areaclass_`iter') , by(programnr) 
* }

** This way of creating "scope" is basically another way of creating "condtype"
*forvalues iter = 0/`maxcondtype' {
* egen scope_`iter' = rcount(c_`iter'a_*) , c(@>0 & @~=.)
* replace scope_`iter' = scope_`iter' - 1 if (c_`iter'a_0>0 & c_`iter'a_0<.)
* }
*summarize scope_*


generate temp = programnr
generate programentries = 1 if programnr<.
generate initialenddate = enddatestata
egen finalenddate = max(enddatestata) , by(programnr)
generate ftestdatestata = testdatestata
replace ftestdatestata = 17713 if testdatestata>17713 & testdatestata<1000000
replace ftestdatestata = . if testdatestata>1000000
egen lasttestdate = max(ftestdatestata) , by(programnr)
* Note that arrtype is NOT constant within a program (e.g. CAF in 1998 has a program coded as both ESAF and PRGF)
* This happens in total 17 times!
* This problem might occur with several variables listed below under "...first" or "...constant"
* A non-integer value of the "...dum" variables might reflect this problem
local varcollapsefirst "orgorder countryname wdicode arrtype condtype areaclass revstatus approvaldate initialenddate nrtests nrreviews" 
local varcollapseconstant "aclpcode programnr arrtypedum condtypedum areaclassdum revstatusdum approvaldatestata approvalyear"
local varcollapselast "finalenddate lasttestdate"
local varcollapsesum "programentries arrtype_* condtype_* areaclass_* c_* revstatus_*"
summarize `varcollapsefirst' `varcollapseconstant' `varcollapselast' `varcollapsesum'
keep temp `varcollapsefirst' `varcollapseconstant' `varcollapselast' `varcollapsesum'
sort programnr lasttestdate orgorder
save "micro conditionality database.dta" , replace
collapse (first) `varcollapsefirst' (mean) `varcollapseconstant' (last) `varcollapselast' (sum) `varcollapsesum' , by(temp)
drop temp

renpfix arrtype_ 	nrarrtype_
renpfix condtype_ 	nrcondtype_
renpfix areaclass_ 	nrareaclass_
renpfix c_		nrc_
renpfix revstatus_ 	nrrevstatus_
*renpfix scope_		nrscope_

generate orderorg = substr(orgorder,2,20) 
drop orgorder
*Needs to be corrected w.r.t. the sample (93 - 7/7/2008)
*11778 = 31.03.1992 (actually first approval date in sample)
generate fstartdate = approvaldatestata
replace fstartdate = 11778 if approvaldatestata<11778
generate nrdays = finalenddate - fstartdate
generate nrquarters = round(nrdays/90)
*17713 = 30.06.2008 (last date at which conditions have been tested in the sample)
*add 90 days to assure that at least 1 quarter is being tested
generate fenddate = finalenddate
replace fenddate = 17713+90 if finalenddate>(17713+90) & finalenddate<.
generate nrdayssmpl = fenddate - fstartdate if fenddate>fstartdate
generate nrquarterssmpl = round(nrdayssmpl/90)
generate nrdaystest = lasttestdate - fstartdate if lasttestdate>fstartdate
generate nrquarterstest = round(nrdaystest/90)
drop fstartdate fenddate nrdays*
* Note: "nrquarterstest" ("nrdaystest") is not available for all programs in final dataset (ethiopia, 1992 & chad, 1994 are NA)
* This does not hold for "nrquarterssmpl" ("nrdayssmpl") (or "nrquarters")
* Problem with "nrquarters" is that is goes beyond the sample period
* "...smpl" uses the last testdate recorded - "...test" uses the official enddate recorded


* Label those variables which not already have a label
label variable orderorg			"Identifier to trace back the original data"
label variable countryname		"Name of the country receiving a program"
label variable wdicode			"Country coding according to the WDI"
label variable arrtype			"Name of the facility under which money can be drawn"
label variable initialenddate		"Initial end date of the program in stata format"
label variable aclpcode			"Unique number for the country receiving a program"
label variable programnr		"Unique number for each individual program"
label variable arrtypedum		"Unique number for the facility under which money can be drawn"
label variable approvaldate		"Date at which the program is approved"
label variable approvaldatestata	"Date at which the program is approved in stata format"
label variable approvalyear		"Year in which the program is approved in stata format"
label variable finalenddate		"Final end date of the program in stata format"
label variable lasttestdate		"Last test date mentioned in this program in stata format"
label variable nrtests			"Number of tests performed by the IMF during the program"
label variable nrreviews		"Number of reviews performed by the IMF during the program during our sample"
label variable nrquarters		"Number of quarters the program is running until the end date"
label variable nrquarterssmpl		"Number of quarters the program is running until the last end data within the sample period"
label variable nrquarterstest		"Number of quarters the program is running until the last test date within the sample period"
forvalues iter = 0/`maxcondtype' {
 label variable nrcondtype_`iter'	"Number of conditions (sum over all tests) for condition type `iter'"
 forvalues iter2 = 0/`maxareaclass' {
  label variable nrc_`iter'a_`iter2'	"Number of conditions (sum over all tests) for condition type `iter' and area class `iter2'"
  }
 }
forvalues iter = 0/`maxareaclass' {
 label variable nrareaclass_`iter'		"Number of conditions (sum over all tests) for area class `iter'"
 }


local maxarrtype = 2
local maxcondtype = 3
local maxscope = `maxcondtype'
local maxrevstatus = 11
local maxareaclass = 20

local varlist "condtype revstatus areaclass arrtype"
foreach var in `varlist' {
 forvalues iter = 0/`max`var'' {
  quietly generate avg1`var'_`iter' = nr`var'_`iter'/nrquarters
  quietly generate avg2`var'_`iter' = nr`var'_`iter'/nrquarterssmpl
  quietly generate avg3`var'_`iter' = nr`var'_`iter'/nrquarterstest
* Both for theoretical and empirical reasons "nrquarterssmpl" appears to be the most appropriate scale variable
  quietly generate avg`var'_`iter' = nr`var'_`iter'/nrquarterssmpl
  }
 }

generate nrcondtype_all = nrcondtype_0
generate nrcondtype_pc = nrcondtype_1
generate nrcondtype_pa = nrcondtype_2
generate nrcondtype_sb = nrcondtype_3

* average number of conditions
generate avgcondtype_all = avgcondtype_0	
* average number of performance criteria
generate avgcondtype_pc = avgcondtype_1		
* average number of prior actions
generate avgcondtype_pa = avgcondtype_2		
* average number of structural benchmarks
generate avgcondtype_sb = avgcondtype_3		


*This exercise needs to be done with the "nrc_" variables - the micro information is needed
*(Need EGENMORE installed for RCOUNT-option with EGEN)
forvalues iter = 0(1)3 {
 egen scope_`iter' = rcount(nrc_`iter'a_*) , c(@>0 & @~=.)
 replace scope_`iter' = scope_`iter' - 1 if (nrc_`iter'a_0>0 & nrc_`iter'a_0<.)
 }
generate scope_all = scope_0
generate scope_pc = scope_1
generate scope_pa = scope_2
generate scope_sb = scope_3
*Divide scope by number of quarters (interpretation??)
forvalues iter = 0/`maxscope' {
*Both for theoretical and empirical reasons "nrquarterssmpl" appears to be the most appropriate scale variable
 quietly generate qrtscope_`iter' = scope_`iter'/nrquarterssmpl
 }
generate qrtscope_all = qrtscope_0
generate qrtscope_pc = qrtscope_1
generate qrtscope_pa = qrtscope_2
generate qrtscope_sb = qrtscope_3

* Produce scope variables per type of arrangement
forvalues iter = 0(1)`maxarrtype' {
 generate scopearr_`iter' = scope_all if nrarrtype_`iter'>0 & nrarrtype_`iter'<.
 generate qrtscopearr_`iter' = qrtscope_all if nrarrtype_`iter'>0 & nrarrtype_`iter'<.
 }

generate scopearr_all = scopearr_0
generate scopearr_eff = scopearr_1
generate scopearr_prgf = scopearr_2
*generate scopearr_sba = scopearr_3
generate qrtscopearr_all = qrtscopearr_0
generate qrtscopearr_eff = qrtscopearr_1
generate qrtscopearr_prgf = qrtscopearr_2 

** Produce histograms of all relevant variables
*foreach iter of varlist nrcondtype_* nrareaclass* scope* {
* histogram `iter' , scheme(s1mono)
* quietly graph export "EMF/`iter'.emf" , replace
* }

*Count the programs in a year in each country
egen idcnt = group(countryname)
generate cntyr = 10000*idcnt + approvalyear
egen nrprcntyr = count(approvalyear) , by(cntyr)
list countryname approvalyear arrtype if nrprcntyr>1
drop cntyr nrprcntyr idcnt
* Senegal has two programs in the year 1995. We "move" the second program into the next year to assure that each country only has one program in a year
replace approvalyear=1995 if countryname=="senegal" & approvalyear==1994 & arrtype=="ESAF"  
* Uganda has two programs in the year 2006. We "move" the second program into the next year to assure that each country only has one program in a year
replace approvalyear=2007 if countryname=="uganda" & approvalyear==2006 & approvaldate=="15.12.2006"

*Generate a dummy which measures whether an observation (country-year) refers to an observations in which there is an IMF program approved
generate imf = 1

generate country = countryname 
generate code = wdicode
generate year = approvalyear

* Check whether all MONA-countries have a wdicode name
egen idcnt = group(code)
tabulate countryname if idcnt>=.

quietly compress
save "Data IMF Conditions Country-Arrangements at Approval.dta" , replace all 
outsheet using "Data IMF Conditions Country-Arrangements at Approval.csv" , comma nolabel replace quote names

*clear all
*use "Data IMF Conditions Country-Arrangements at Approval.dta" 
*summarize if substr(orderorg,1,4)=="9301"
*summarize if substr(orderorg,1,4)=="0108"


****** (Modified) Input from Axel:

sort code year
compress
save "conditionality database temp.dta", replace
outsheet using "conditionality database temp.csv" , comma nolabel replace quote names


*** "Fix" code in DPI database
use "Other sources/dpi elections.dta", clear
replace code="YUG" if code=="YSR"
sort code year 
save "Other sources/dpi elections trans.dta", replace
outsheet using "Other sources/dpi elections trans.csv" , comma nolabel replace quote names
***

* Merge WDI2008 data into this database
use "conditionality database temp.dta", clear
replace code = wdicode if code==""
foreach iter in "NE_TRD_GNFS_ZS" "NY_GDP_FCST_CD" "NY_GDP_PCAP_KD" "NY_GDP_MKTP_KD_ZG" "NE_CON_GOVT_ZS" "FM_LBL_MQMY_GD_ZS" "NE_RSB_GNFS_ZS" "BN_CAB_XOKA_GD_ZS" "DT_DOD_DIMF_CD" "DT_DOD_DSTC_CD" "DT_DOD_DLXF_CD" "DT_TDS_DECT_GN_ZS" "FR_INR_DPST" "FR_INR_LEND" "BN_RES_INCL_CD" "FI_RES_TOTL_DT_ZS" "FI_RES_TOTL_MO" "DT_DOD_DECT_GN_ZS" "NE_GDI_FTOT_ZS" {
 display "`iter'"
 sort code year
 merge code year using "wdi2008/variables/`iter'.dta"
 *        _merge==1    obs. from master data                            
 *        _merge==2    obs. from only one using dataset                 
 *        _merge==3    obs. from at least two datasets, master or using 
 tabulate _merge 
 drop _merge 
 }
replace wdicode = code if wdicode==""
sort wdicode year
save "conditionality database temp.dta", replace
outsheet using "conditionality database temp.csv" , comma nolabel replace quote names
 
* Merge Polity IV data into this database
use "Other sources/big merge file.dta" , clear
keep wdi ccode
rename wdi wdicode
sort wdicode
save "temp.dta" , replace
use "Other sources/p4v2008.dta" , clear
keep ccode year polity2 
sort ccode year
save "temp2.dta" , replace
use "conditionality database temp.dta", clear
sort wdicode
merge wdicode using "temp.dta"
*        _merge==1    obs. from master data                            
*        _merge==2    obs. from only one using dataset                 
*        _merge==3    obs. from at least two datasets, master or using 
tabulate _merge
drop _merge 
sort ccode year
merge ccode year using "temp2.dta"
*        _merge==1    obs. from master data                            
*        _merge==2    obs. from only one using dataset                 
*        _merge==3    obs. from at least two datasets, master or using 
tabulate _merge 
drop _merge 
sort wdicode year
save "conditionality database temp.dta", replace
outsheet using "conditionality database temp.csv" , comma nolabel replace quote names
erase "temp.dta"
erase "temp2.dta"

* Merge Database of Political Institutions (DPI) into this database
use "Other sources/dpi2006_rev42008.dta" , clear
local varlist execrlc dateleg legelec exelec govfrac
keep ifs year `varlist'
foreach iter of local varlist {
 replace `iter' = . if `iter'==-999
 }
rename ifs wdicode
sort wdicode year
save "temp.dta" , replace
use "conditionality database temp.dta", clear
sort wdicode year
merge wdicode year using "temp.dta"
*        _merge==1    obs. from master data                            
*        _merge==2    obs. from only one using dataset                 
*        _merge==3    obs. from at least two datasets, master or using 
tabulate _merge 
drop _merge
sort wdicode year
save "conditionality database temp.dta", replace
outsheet using "conditionality database temp.csv" , comma nolabel replace quote names
erase "temp.dta"

* Merge other data into MONA-conditionality database
use "conditionality database temp.dta", clear
replace code = wdicode if code==""
foreach iter in "unsc" "wdi" "polity" "icrg" "kof" "dpi elections trans" "dd" "usaid" {
 display "`iter'"
 sort code year
 merge code year using "Other sources/`iter'.dta"
 *        _merge==1    obs. from master data                            
 *        _merge==2    obs. from only one using dataset                 
 *        _merge==3    obs. from at least two datasets, master or using 
 tabulate _merge 
 tabulate code if _merge==1 
 drop _merge 
 sort code year
 }
save "conditionality database temp.dta", replace
outsheet using "conditionality database temp.csv" , comma nolabel replace quote names

** Merge aid variables as requested by reviewer for JCR
*use "Other sources/Jan-Egbert aid data.dta" , clear
*keep code year odadisIMF_0 aiddisIMF_cur aidnflIMF_cur imf_all 
*sort code year
*save "temp.dta"
*use "conditionality database temp.dta", clear
*merge code year using "temp.dta"
*tabulate _merge
*tabulate code if _merge==1
*drop _merge
*sort code year
*save "conditionality database temp.dta", replace
*outsheet using "conditionality database temp.csv" , comma nolabel replace quote names
*erase "temp.dta"

* Only cross-sectional dimension in the dataset
merge code using "Other sources/ethfrac.dta"
tabulate _merge 
tabulate code if _merge==1 
drop _merge 
sort code year


drop idcnt
egen idcnt = group(code)
egen temp = mean(idcnt) , by(code)
* Remove countries (but not years) for which we do not have conditionality data
drop if temp>=. | year>=.
duplicates list idcnt year
tsset idcnt year , yearly


* Create some new series out of the newly added data

** Create UNSC dummies
generate unsc_t0 = f.unsc
replace unsc_t0=0 if l.unsc_t0==1
bysort code: generate unsc_t1 = (unsc[_n]==1 & unsc[_n+1]==1)
replace unsc_t1 =. if unsc==.
bysort code: generate unsc_t2 = (unsc[_n]==1 & unsc[_n-1]==1)
replace unsc_t2 =. if unsc==.
bysort code: generate unsc_t3 = (unsc[_n-1]==1 & unsc[_n]~=1)
replace unsc_t3 =. if unsc==.
bysort code: generate unsc_t4 = (unsc[_n-2]==1 & unsc[_n-1]~=1)
replace unsc_t4 =. if unsc==.

** UNSC membership including t-1
generate unsc3 = (unsc==1 | unsc_t0==1) 
replace unsc3 =. if unsc==.
* The following datapoint are filled in by hand - to not loose additional observations in the analysis
* PLEASE CHECK THAT THE NUMBERS USED HERE ARE CORRECT!
list countryname approvalyear avgcondtype_0 if unsc3>=. & avgcondtype_0<.
replace unsc3 = 0 if countryname=="ethiopia" & approvalyear==1992
replace unsc3 = 0 if countryname=="russian federation" & approvalyear==1995
replace unsc3 = 0 if countryname=="russian federation" & approvalyear==1996
replace unsc3 = 0 if countryname=="russian federation" & approvalyear==1999

** Make a few interpolations
bysort code: ipolate school_p approvalyear, gen(school_p_i) 	/* linear ipolation of primary school enrollment */
bysort code: ipolate school_s approvalyear, gen(school_s_i)	/* linear ipolation of secondary school enrollment */
bysort code: ipolate school_t approvalyear, gen(school_t_i)	/* linear ipolation of tertiary school enrollment */

* IMF data is complete. Hence, NAs can be replaced by zeros
foreach var in imf_conc imf_noconc imf_all {
 replace `var' = 0 if `var'>=.
 }
** Create some other variables
generate inf_cons_trans = (inf_cons/100)/(1+(inf_cons/100))
generate inf_gdp_trans = (inf_gdp/100)/(1+(inf_gdp/100))
generate ln_gdp_us = log(gdp_us)
generate ln_gdp_pc_us = log(gdp_pc_us)
generate imf_conc_gdp = 100*imf_conc/gdp_cur
generate imf_noconc_gdp = 100*imf_noconc/gdp_cur
generate imf_all_gdp = 100*imf_all/gdp_cur
generate pop_ln = log(pop)
generate gdp_ln = log(gdp_us)
generate elec = legelec
replace elec = exelec if exelec==1
sort idcnt year
generate legelec_l = l.legelec
generate elec_l = l.elec
generate exelec_l = l.exelec
*bysort code: generate legelec_l = legelec[_n-1]
*bysort code: generate elec_l = elec[_n-1]
*bysort code: generate exelec_l = exelec[_n-1]

*Is incorrect as oda is in constant 2009 USD
*generate oda_gdp = odadisIMF_0/gdp_cur




***************************** provide labels **********************************************************
label variable nrcondtype_all 		"Number of Conditions"
label variable nrcondtype_pc  		"Number - Condition type: Performance Criteria"	
label variable nrcondtype_pa  		"Number - Condition type: Prior Action"
label variable nrcondtype_sb  		"Number - Condition type: Structural Benchmark" 	
label variable avgcondtype_all  	"Average Number of Conditions in a quarter" 
label variable avgcondtype_pc  		"Average Number - Condition type: Performance Criteria/number of quarters"	
label variable avgcondtype_pa  		"Average Number - Condition type: Prior Action/number of quarters"
label variable avgcondtype_sb  		"Average Number - Condition type: Structural Benchmark/number of quarters" 	

label variable nrcondtype_0 		"Number of Conditions"
label variable nrcondtype_1  		"Number - Condition type: Performance Criteria"
label variable nrcondtype_2  		"Number - Condition type: Prior Action" 	
label variable nrcondtype_3  		"Number - Condition type: Structural Benchmark"	

label variable scope_all		"Scope of Conditions"
label variable scope_pc  		"Scope - Condition type: Performance Criteria"	
label variable scope_pa  		"Scope - Condition type: Prior Action"
label variable scope_sb  		"Scope - Condition type: Structural Benchmark" 	

label variable scope_0			"Scope of Conditions"
label variable scope_1  		"Scope - Condition type: Performance Criteria"	
label variable scope_2  		"Scope - Condition type: Prior Action"
label variable scope_3  		"Scope - Condition type: Structural Benchmark" 	

label variable scopearr_all		"Scope of Conditions"
label variable scopearr_eff  		"Scope - Arrangement type: EFF"	
label variable scopearr_prgf  		"Scope - Arrangement type: PRGF"
*label variable scopearr_sba  		"Scope - Arrangement type: SBA" 	

label variable scopearr_0		"Scope of Conditions"
label variable scopearr_1  		"Scope - Arrangement type: EFF"	
label variable scopearr_2  		"Scope - Arrangement type: PRGF"
*label variable scopearr_3  		"Scope - Arrangement type: SBA" 

*label variable nrscope_0		"Scope of Conditions"
*label variable nrscope_1  		"Scope - Condition type: Performance Criteria"	
*label variable nrscope_2  		"Scope - Condition type: Prior Action"
*label variable nrscope_3  		"Scope - Condition type: Structural Benchmark" 	

label variable nrareaclass_1		"Area class: Arrears"
label variable nrareaclass_2		"Area class: BOP/ Reserves"
label variable nrareaclass_3		"Area class: Capital Account"
label variable nrareaclass_4		"Area class: Central Bank Reform"
label variable nrareaclass_5		"Area class: Credit to Government"
label variable nrareaclass_6		"Area class: Debt"
label variable nrareaclass_7		"Area class: Exchange system"
label variable nrareaclass_8		"Area class: Financial sector"
label variable nrareaclass_9		"Area class: Governance"
label variable nrareaclass_10		"Area class: Government Budget"
label variable nrareaclass_11		"Area class: Monetary Ceiling"
label variable nrareaclass_12		"Area class: Other"
label variable nrareaclass_13		"Area class: Pricing"
label variable nrareaclass_14		"Area class: Private Sector Reforms"
label variable nrareaclass_15		"Area class: Privatization"
label variable nrareaclass_16		"Area class: Public Sector"
label variable nrareaclass_17		"Area class: Social"
label variable nrareaclass_18		"Area class: Systemic"
label variable nrareaclass_19		"Area class: Trade"
label variable nrareaclass_20		"Area class: Wages & Pensions"
*label variable nrareaclass_12		"Area class: Non Available"

label variable nrarrtype_1		"Arrangement type: EFF"
label variable nrarrtype_2		"Arrangement type: PRGF"
*label variable nrarrtype_3		"Arrangement type: SBA"

label variable nrrevstatus_1		"??? (NMOD)"
label variable nrrevstatus_2		"??? (WM)"
label variable nrrevstatus_3		"Cancelled (CAN)"
label variable nrrevstatus_4		"Delayed (DL)"
label variable nrrevstatus_5		"Met (M)"
label variable nrrevstatus_6		"Met With Delay (MD)"
label variable nrrevstatus_7		"Modified (MOD)"
label variable nrrevstatus_8		"NA"
label variable nrrevstatus_9		"Not Met (NM)"
label variable nrrevstatus_10		"Partly Met (PM)"
label variable nrrevstatus_11		"Waived (W)"

label variable ln_gdp_pc_us 		"Log of per capita income"
label variable gg 			"GDP growth"
label variable inf_cons_trans 		"Rate of inflation"
label variable res_imp 			"International reserves (to imports)"
label variable res_debt			"International reserves (% of external debt)"
label variable cab_gdp 			"Current account balance"
label variable gcf_gdp 			"Investment (% of GDP)"
label variable tds_gni			"Total debt service (% of GDP)"
label variable legelec_l		"Election year (t-1), dummy"
label variable gge_growth 		"Growth of government consumption"
*label variable inline_usa 		"Voting in line with the US in the UNGA"
label variable unsc 			"Temporary member of the UN Security Council"
label variable unsc3 			"Temporary member of the UN Security Council"
label variable gov_stab 		"Government stability"
label variable prs 			"Corruption"
label variable law_ord 			"Law and order"
label variable inv_prof 		"Investment profile"
label variable bur_qual 		"Bureaucracy quality"
label variable soc_cond 		"Social conditions"
label variable eth_ten 			"Ethnic tension"
label variable polity2 			"Democracy"
label variable a 			"Economic globalization"
label variable index 			"Overall globalization index"
label variable trade_gdp 		"Trade"
label variable school_p 		"Education"

label variable execrlc			"Right - Left - Center - No information - No executive"
label variable dateleg			"Month when presidential elections were held"
label variable legelec			"Dummy for a legislative election"
label variable govfrac			"Probability of picking deputies from different parties in government"

label variable NE_TRD_GNFS_ZS		"Trade (% of GDP)"
label variable NY_GDP_FCST_CD		"Gross value added at factor cost (current US$)"
label variable NY_GDP_PCAP_KD		"GDP per capita (constant 2000 US$)"
label variable NY_GDP_MKTP_KD_ZG	"GDP growth (annual %)"
label variable NE_CON_GOVT_ZS		"General government final consumption expenditure (% of GDP)"
label variable FM_LBL_MQMY_GD_ZS	"Money and quasi money (M2) as % of GDP"
label variable NE_RSB_GNFS_ZS		"External balance on goods and services (% of GDP)"
label variable BN_CAB_XOKA_GD_ZS	"Current account balance (% of GDP)"
label variable DT_DOD_DIMF_CD		"Use of IMF credit (DOD, current US$)"
label variable DT_DOD_DSTC_CD		"Short-term debt outstanding (DOD, current US$)"
label variable DT_DOD_DLXF_CD		"Long-term debt (DOD, current US$)"
label variable DT_TDS_DECT_GN_ZS	"Total debt service (% of GNI)"
label variable FR_INR_DPST		"Deposit interest rate (%)"
label variable FR_INR_LEND		"Lending interest rate (%)"
label variable BN_RES_INCL_CD		"Changes in net reserves (BoP, current US$)"
label variable FI_RES_TOTL_DT_ZS	"Total reserves (% of external debt)"
label variable FI_RES_TOTL_MO		"Total reserves in months of imports"
label variable DT_DOD_DECT_GN_ZS	"External debt, total (% of GNI)"
label variable NE_GDI_FTOT_ZS		"Gross fixed capital formation (% of GDP)"

label variable usaid			"US Aid (in current US$)"

rename NE_TRD_GNFS_ZS		Openness
rename NY_GDP_FCST_CD		nomGDPUSD
rename NY_GDP_PCAP_KD		GDPpc
rename NY_GDP_MKTP_KD_ZG	GDPgrowth
rename NE_CON_GOVT_ZS		GGovExpGDP
rename FM_LBL_MQMY_GD_ZS	M2GDP
rename NE_RSB_GNFS_ZS		ExtBalGDP
rename BN_CAB_XOKA_GD_ZS	CABalGDP
rename DT_DOD_DIMF_CD		UseIMFCredit
rename DT_DOD_DSTC_CD		STDebt
rename DT_DOD_DLXF_CD		LTDebt
rename DT_TDS_DECT_GN_ZS	DebtServGNI
rename FR_INR_DPST		DIntRate
rename FR_INR_LEND		LIntRate
rename BN_RES_INCL_CD		DNetRes
rename FI_RES_TOTL_DT_ZS	ResXDebt
rename FI_RES_TOTL_MO		ResMimp
rename DT_DOD_DECT_GN_ZS	XDebtGNI
rename NE_GDI_FTOT_ZS		GFCFGDP

generate shSTdebt = 100*STDebt/(STDebt+LTDebt)
generate UseIMFCredGDP = 100*UseIMFCredit/nomGDPUSD
generate lnGDPpc = log(GDPpc)
generate DNetResGDP = 100*DNetRes/nomGDPUSD
generate USaidGDP = 100*1000000*usaid/nomGDPUSD
generate DIntRateScaled = 100*(DIntRate/(100+DIntRate))

label variable shSTdebt			"Share of short-term debt in total debt"
label variable UseIMFCredGDP		"Use of IMF credit as share of GDP"
label variable lnGDPpc			"log of GDP per capita"
label variable DNetResGDP		"Change in net reserves as share of GDP"
label variable USaidGDP			"US Aid (% of GDP)"
label variable DIntRateScaled		"Deposit interest rate (100%/(100+%))"

tabulate execrlc , gen(execrlcdum)
summarize execrlcdum*
generate leftgov = execrlcdum4
drop execrlcdum* temp*
label variable leftgov			"Left-wing executive government"

* save complete database for further use
compress
sort code year		
save "conditionality database.dta", replace
outsheet using "conditionality database.csv" , comma nolabel replace quote names

* Clean up
erase "conditionality database temp.csv"
erase "conditionality database temp.dta"
erase "Other sources/dpi elections trans.csv"
erase "Other sources/dpi elections trans.dta"
erase "country_codes.dta"

summarize

exit, clear








**** IN CASE WE NEED UNVOTING DATA:
* So far not integrated, as we do not appear to be using this data



***********************************************************************************
*** Prepare UNGA data: Voting in line with the U.S., Japan, France, UK, Germany
*** Codes voting the same ==1, abstentions/absences==0.5; leads to the peculiarity that voting with onself is usually <1

use "UN Voting update Voeten wide.dta", clear
set more off

drop var*
drop if approvalyear==2006 /* based on 2 observations only */

foreach var of varlist usa - cze {
		replace `var'=. if `var'==9  /* 9 is the code for not being a member */
	}

foreach donor of varlist usa jpn fra gbr deu  {

foreach var of varlist usa - cze {
            generate `var'_vote=(`var'==`donor')
            replace `var'_vote=.5 if `var'==8 | `var'==2 | `donor'==2
            replace `var'_vote=. if `var'>=. | `donor'>=.
            bysort approvalyear: egen inline_`donor'_`var'=mean(`var'_vote)
            drop `var'_vote
	}
}

drop usa - cze

drop if approvalyear==approvalyear[_n-1]
reshape long inline_usa_  inline_jpn_  inline_fra_  inline_gbr_  inline_deu_, i(approvalyear) j(UNcode) string

generate code = upper(UNcode) 
drop UNcode

sort code approvalyear

foreach donor in usa jpn fra gbr deu {
  ren inline_`donor'_  inline_`donor'
}

drop yes abstain no rcid keyvote human_rights

sort code approvalyear
save "un voting trans.dta", replace
outsheet using "un voting trans.csv" , comma nolabel replace quote names


*** Prepare UNGA keyvote data: Voting in line with the U.S., Japan, France, UK, Germany ON KEYVOTES as defined by the US Department of State
*** Codes voting the same ==1, abstentions/absences==0.5; leads to the peculiarity that voting with onself is usually <1

use "UN Voting update Voeten wide.dta", clear
set more off
keep if keyvote==1   /* keep only votes defined to be key according to U.S. Department of Stata */

drop var*

foreach var of varlist usa - cze {
		replace `var'=. if `var'==9
	}

foreach donor of varlist usa jpn fra gbr deu  {

foreach var of varlist usa - cze {
            generate `var'_vote=(`var'==`donor')
            replace `var'_vote=.5 if `var'==8 | `var'==2 | `donor'==2
            replace `var'_vote=. if `var'>=. | `donor'>=.
            bysort approvalyear: egen inline_`donor'_`var'=mean(`var'_vote)
            drop `var'_vote
	}
}

drop usa - cze

drop if approvalyear==approvalyear[_n-1]
reshape long inline_usa_  inline_jpn_  inline_fra_  inline_gbr_  inline_deu_, i(approvalyear) j(UNcode) string

generate code = upper(UNcode) 
drop UNcode

sort code approvalyear

foreach donor in usa jpn fra gbr deu {
  ren inline_`donor'_  inlinekey_`donor'
}

drop yes abstain no rcid keyvote human_rights

sort code approvalyear
save "un keyvoting trans.dta", replace
outsheet using "un keyvoting trans.csv" , comma nolabel replace quote names


*******************************************************************************************************************
************* PART 2: merge databases
*******************************************************************************************************************


*** Merge transformed UNGA data
sort code approvalyear
merge code approvalyear using "un voting trans.dta"
/* variables include:
	inline_usa inline_jpn inline_fra inline_gbr inline_deu
*/
drop if _merge==2 /* drops years <1951, permanent UNSC members and Monaco */
drop _merge 

*** Merge transformed UNGA keynote data
sort code approvalyear
merge code approvalyear using "un keyvoting trans.dta"
/* variables include:
	inlinekey_usa inlinekey_jpn inlinekey_fra inlinekey_gbr inlinekey_deu
*/
drop if _merge==2 /* drops years <1951, permanent UNSC members and Monaco */
drop _merge 




