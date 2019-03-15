////Received new ED data part way through project this data needed to be merged with existing files
///this is the syntax to do this


//imported csv data into stata
///saved as NewEDdata


////in the new file there are almost no matches between the cupscid (of form #######SC#)in the new data and in the exisitng data.
//realised this is because the cupscid in the new data refer the position in the pathway of the 'E' s not the 'S' as in the exisiting data
////there are multiple Es for each pathway
////need to reshape wide so each ed arrival time is a variable then replace the old ed arrival time with a new one if the old one is missing 
////and there is a new one that is after the orignal SAS call
////first set data up for merge
////open data file 'linked data for merge'
rename cupscid iacutecupscid
///SAVE OUT
///open NewEDdata
rename acutecupid iacutecupscid
///in newED data 
///need to change variables to same type as in full linked data
destring attendancecategorycode patientflowcode edcupservicecontactnumber , replace
describe isdid

///reshape cuts the file names and this makes some of the variable names identical therfore need to rename before merge
rename ?????????* ?????????#, addnumber
rename iacutecup1  iacutecupscid


split cupscid, p("S")

gen cupscid2N=real(cupscid2)

gen edarrivalnew=clock(edarrival5, "DMYhm") 
hist edarrivalnew
sort edarrivalnew
///there are some duplicates in cupscid and these must be dropped before merge
///if time investigate these cases further
duplicates report cupscid
duplicates tag cupscid, gen(dup)
drop if dup>0
drop edarrivalnew
#delimit;
drop activityw2 activityw3 attendanc7 bodilyloc8 bodilyloc9 edfirstcl12 eddiagnos15 
eddiagnos16 eddiagnos17 eddiagnos18 externalc22 intentofi25 intentofi26 locationo27 
locationo28 natureofi29 natureofi30 patientfl31 patientfl32 placeofin33 placeofin34 
cuppathwa35 referredt36 referredt37 referredt38 referredt39 referredt40 referredt41 
edpatmant42 edpatmant43 eddiagnos46 eddiagnos47 eddiagnos48 eddiagnos49 eddiagnos50 
eddiagnos51 eddiagnos52 edinjuryd53 externalc55  v6*;
drop n_break n_break6 edcupserv60
drop cupscid1 cupscid2N

#delimit;
reshape wide isdid cupscid alcoholre4 edarrival5 attendanc6 edcomplet10 eddischar11 
eddiagnos13 eddiagnos14 discharge19 discharge20 discharge21 edtriagec23 edtriagec24 
edcupid eddiagnos44 eddiagnos45 discharge54 eddiagnos56 eddiagnos57 eddiagnos58 edpathway59, i(iacutecupscid) j(cupscid2, string);

///in new data wide
rename acutecunew2 cupscid
///in linked data for merge
merge m:1 iacutecupscid using "\\Farr-FS1\Study Data\1516-0138\Results\Original data\newEDdata3wide.dta"



summarize sas_calltime
////This step loops through each of the ED arrival times for each patient and replaces it if currently missing and if after the inital SAS call
gen ed_arrivaltimenew=ed_arrivaltime
foreach SCpos in C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11 C12 C13 C14 C15 C16 C17 C19 C20 C21 C24 C28  {
	gen edarrival5`SCpos'new =clock(edarrival5`SCpos', "DMYhm") 
	replace  ed_arrivaltimenew=edarrival5`SCpos'new if (missing(ed_arrivaltimenew)) & (!missing(edarrival5`SCpos'new)) & ((edarrival5`SCpos'new)>(sas_calltime))
			    }


summarize ed_arrivaltime
summarize ed_arrivaltimenew

describe *new
rename ed_arrivaltimenew ed_arrivaltimenew2				
drop *new

gen EDdischargetimenew=eddischargedatetimeclock
foreach SCpos in C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11 C12 C13 C14 C15 C16 C17 C19 C20 C21 C24 C28  {
	gen eddischar11`SCpos'new =clock(eddischar11`SCpos', "DMYhm") 
	replace  EDdischargetimenew=eddischar11`SCpos'new if (missing(EDdischargetimenew)) & (!missing(eddischar11`SCpos'new)) & ((eddischar11`SCpos'new)>(ed_arrivaltimenew2))
			    }

	drop Eddischargetype2
	gen Eddischargetype2=dischargetypecode
	tab Eddischargetype2
	tab discharge21C1 Eddischargetype2, missing
	foreach SCpos in C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11 C12 C13 C14 C15 C16 C17 C19 C20 C21 C24 C28  {
	 
	replace  Eddischargetype2=discharge21`SCpos' if ((Eddischargetype2)==" ") & (!missing(discharge21`SCpos'))
			    }

	tab Eddischargetype2 dischargetypecode, missing
	tab Eddischargetype2
	tab dischargetypecode
	rename cutpathgroupnew cutpathgroupnew2 
summarize EDdischargetimenew
summarize eddischargedatetimeclock
summarize ed_arrivaltimenew
summarize eddischargedatetimeclock

foreach SCpos in C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11 C12 C13 C14 C15 C16 C17 C19 C20 C21 C24 C28  {
	gen eddischnew12`SCpos'new =clock(eddischar11C5`SCpos', "DMYhm") 
	replace  EDdischargetimenew=eddischnew12`SCpos'new if (missing(EDdischargetimenew)) & (!missing(eddischnew12`SCpos'new)) & ((eddischnew12`SCpos'new)>(ed_arrivaltimenew))
			    }
 
	foreach var of varlist discharge19* {
	label variable `var' "ed discharge destination code" 
	}
	

foreach var of varlist discharge20* {
	label variable `var' "ed discharge type description" 
	}
	
	foreach var of varlist discharge21* {
	label variable `var' "ed discharge type code" 
	}
	
	foreach var of varlist edtriagec23* {
	label variable `var' "ed triage category code" 
	}
	
	foreach var of varlist edtriagec24* {
	label variable `var' "ed triage category description" 
	}
	
	foreach var of varlist eddiagnos44* {
	label variable `var' "ed diagnosis on discharge1code3char" 
	}
	
		foreach var of varlist eddiagnos45* {
	label variable `var' "ed diagnosis on discharge2code3char" 
	}
	
		foreach var of varlist discharge54* {
	label variable `var' "ed discharge destination description" 
	}
	
		foreach var of varlist eddiagnos56* {
	label variable `var' "ed diagnosis discharge description1" 
	}
	
	
		foreach var of varlist eddiagnos57* {
	label variable `var' "ed diagnosis discharge description2" 
	}
	
	drop *new
describe discharge19C1
	gen Eddischargedest2=dischargedestinationcode
	tab Eddischargedest2
////same loop for discharge destination
	foreach SCpos in C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11 C12 C13 C14 C15 C16 C17 C19 C20 C21 C24 C28  {
	 
	replace  Eddischargedest2=discharge19`SCpos' if ((Eddischargedest2)==" ") & (discharge19`SCpos' !=" ")&((clock(eddischar11`SCpos', "DMYhm"))>(ed_arrivaltimenew))
			    }

	gen Edtriagecatcode2=edtriagecategorycode
	tab Edtriagecatcode2
////same loop for Ed triage code
	foreach SCpos in C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11 C12 C13 C14 C15 C16 C17 C19 C20 C21 C24 C28  {
	 
	replace  Edtriagecatcode2=edtriagec23`SCpos' if ((Edtriagecatcode2)==" ") & (edtriagec23`SCpos' !=" ")&((clock(eddischar11`SCpos', "DMYhm"))>(ed_arrivaltimenew))
			    }	
	
	by Edtriagecatcode2, sort: summarize EDdischargetime2, detail
	tab Edtriagecatcode2 selfdischargeED2, column missing
	tab Edtriagecatcode2 
	drop Eddischargcatcode2
	gen Eddischargcatcode2=eddiagnosisondischarge1code3char
	describe eddiagnos44C1
	tab Eddischargcatcode2 
	
		foreach SCpos in C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11 C12 C13 C14 C15 C16 C17 C19 C20 C21 C24 C28  {
	 
	replace  Eddischargcatcode2=eddiagnos44`SCpos' if ((Eddischargcatcode2)==" ") & (eddiagnos44`SCpos' !=" ") & (!missing(eddiagnos44`SCpos'))
			    }	
	

	
	tab Eddischargcatcode2
	
	by isdid, sort: gen callnum= _n



