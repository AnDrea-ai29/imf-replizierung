Instructions to replicate the tables from: 

Dreher, Axel, Jan-Egbert Sturm, and James Raymond Vreeland. 
"Politics and IMF Conditionality." 

Published in Journal of Conflict Resolution

This README file has 4 parts: 
	(I) SET UP STATA: Install required supplemental commands for Stata
	(II) List of the included files necessary for the replication & instruction on where to put them on your computer
	(III) Required Edit to the do file (set up working directory)
	(IV) Run the do-file (Dreher_Sturm_Vreeland_JCR.do) & list of files produced by the do-file



(I) SET UP STATA: Install required supplemental commands for Stata

	(1) xtserial

	Type the following into Stata:

	        . findit xtserial
        	. net sj 3-2 st0039         (or click on st0039)
	        . net install st0039        (or click on click here to install)

	(2) outreg2

	Type the following into Stata:

	        . ssc install outreg2


(II) List of the included files necessary for the replication & instruction on where to put them on your computer

	Place the following files 
	(which are included in the zipped folder along with this README file) 
	all in the same working directory on your computer: 

		(1)  Dreher_Sturm_Vreeland_JCR.dta
		(2)  Dreher_Sturm_Vreeland_JCR.do
		(3)  JCR_DSV_Table1.doh
		(4)  JCR_DSV_Table2.doh
		(5)  JCR_DSV_Table3.doh
		(6)  JCR_DSV_Table4.doh
		(7)  JCR_DSV_Table5.doh
		(8)  JCR_DSV_TableS1.doh
		(9)  JCR_DSV_TableS2.doh
		(10) JCR_DSV_TableS3.doh
		(11) JCR_DSV_TableS4.doh
		(12) JCR_DSV_TableS5.doh


(III) Required Edit to the do file (set up working directory)

	Open Dreher_Sturm_Vreeland_JCR.do 
	and follow the instructions to set up your personal directory for the above files. 


(IV) Run the do-file (Dreher_Sturm_Vreeland_JCR.do) & list of files produced by the do-file

	The do-file will produce the following output files, 
	replicating the five tables in our publication 
	along with five supplemental tables from the Supplemental Appendix: 

		(1)  Dreher_Sturm_Vreeland_JCR.log
		(2)  JCR_DSV_Table1.log
		(3)  JCR_DSV_Table2.txt
		(4)  JCR_DSV_Table2.xml*
		(5)  JCR_DSV_Table3.txt
		(6)  JCR_DSV_Table3.xml*
		(7)  JCR_DSV_Table4.txt
		(8)  JCR_DSV_Table4.xml*
		(9)  JCR_DSV_Table5.txt
		(10) JCR_DSV_Table5.xml*
		(11) JCR_DSV_TableS1.log
		(12) JCR_DSV_TableS2.txt
		(13) JCR_DSV_TableS2.xml**
		(14) JCR_DSV_TableS3.txt
		(15) JCR_DSV_TableS3.xml**
		(16) JCR_DSV_TableS4.txt
		(17) JCR_DSV_TableS4.xml**
		(18) JCR_DSV_TableS5.log

*These files can be opened in Excel and produce exactly the indicated table from the article. 
Note that in the article tables, we report results only for the number of conditions. 
These tables also include the results for the scope of conditionality, 
which are also available in the Supplemental Appendix. 

**These files can be opened in Excel and produce exactly the indicated table from the Supplemental Appendix. 

