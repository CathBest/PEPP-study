////returners
////NB this is returners only in 2011 
////this section records returners by pathway
////

duplicates report iacutecupscid
#delimit;
keep iacutecupscid cupscidstrSC saspathwayname sasincidentnhsboarddescription 
genderdescription sascallstartdatetime isdid deathsdate primcauseofdeathicd9icd10classif 
seccauseofdeath0code3char ampds edarrivaldatetime eddischargedatetime eddiagnosisgrouping1code 
dischargedestinationcode dischargetypedescription dischargetypecode eddiagnosisondischarge2code3char 
eddiagnosisondischarge3code3char eddiagnosisondischarge2code4char acuteadmissiondate 
acutedischargedate acuteinpatientdaycasemarkercis patientdobdate gendercode 
maritalstatusdescription ethnicgroupdescription isdid_first mhadmissiondate 
mhdischargedate patientnhsboardcode11 selfdischargeED2 EDdischargetime2 SAS_AE 
cutpathnoN SAS_to_EDtime2 deathsdateclock sas_calltime cupscid2N deathED2 ageexact maritaln ethnicn eddisdest simd;
drop pathorder
by iacutecupscid (cupscid2N), sort: gen pathorder=_n
tab pathorder

rename primcauseofdeathicd9icd10classif primcausedeath
rename eddiagnosisondischarge2code3char eddiagnosisondis
drop sas_calltime cupscid2N 
drop sasdiagnosisdescription
#delimit;
reshape wide cupscidstrSC saspathwayname sasincidentnhsboarddescription 
genderdescription sascallstartdatetime isdid deathsdate primcausedeath 
seccauseofdeath0code3char ampds edarrivaldatetime eddischargedatetime eddiagnosisgrouping1code 
dischargedestinationcode dischargetypedescription dischargetypecode eddiagnosisondis 
acuteadmissiondate acutedischargedate acuteinpatientdaycasemarkercis patientdobdate gendercode 
maritalstatusdescription ethnicgroupdescription isdid_first mhadmissiondate 
mhdischargedate patientnhsboardcode11 selfdischargeED2 EDdischargetime2 SAS_AE 
cutpathnoN SAS_to_EDtime2 deathsdateclock deathED2 ageexact maritaln ethnicn eddisdest
simd, i(iacutecupscid) j(pathorder);
bysort cutpathnoN1 : gen freq = -_N
egen cutpathgroupnew =group(freq cutpathnoN1)
tab cutpathgroupnew
recode cutpathgroupnew (6/823=0)
codebook sascallstartdatetime1
gen sas_calltime1=clock(sascallstartdatetime1,"YMDhms")
sum sas_calltime1
gen sas_calltime2=clock(sascallstartdatetime2,"YMDhms")
sum sas_calltime2
#delimit;
egen nocalls= rownonmiss(sascallstartdatetime1 sascallstartdatetime2 sascallstartdatetime3 sascallstartdatetime4
sascallstartdatetime5), strok;
describe
drop SAS_to_SAS2time
gen SAS_to_SAS2time=((sas_calltime2-sas_calltime1)/86400000)
summarize SAS_to_SAS2time
hist SAS_to_SAS2time
by cutpathgroupnew, sort: summarize SAS_to_SAS2time, detail
summarize SAS_to_SAS2time, detail


///need to do returners based on isdid not iacutecupscid
///this gives returners by person not pathway
duplicates report isdid
drop freqcall
bysort isdid : gen freqcall = _N
tab freqcall if callorder==1

#delimit;
keep iacutecupscid cupscidstrSC saspathwayname sasdiagnosisdescription sasincidentnhsboarddescription 
genderdescription sascallstartdatetime isdid deathsdate primcauseofdeathicd9icd10classif 
seccauseofdeath0code3char ampds edarrivaldatetime eddischargedatetime eddiagnosisgrouping1code 
dischargedestinationcode dischargetypedescription dischargetypecode eddiagnosisondischarge2code3char 
eddiagnosisondischarge3code3char eddiagnosisondischarge2code4char acuteadmissiondate 
acutedischargedate acuteinpatientdaycasemarkercis patientdobdate gendercode 
maritalstatusdescription ethnicgroupdescription isdid_first mhadmissiondate 
mhdischargedate patientnhsboardcode11 selfdischargeED2 EDdischargetime2 SAS_AE 
cutpathnoN SAS_to_EDtime2 deathsdateclock sas_calltime cupscid2N deathED2 freqcall;

by isdid (sas_calltime), sort: gen callorder=_n
tab callorder
bysort cutpathnoN : gen freq = -_N
egen cutpathgroupnew =group(freq cutpathnoN)
tab cutpathgroupnew
recode cutpathgroupnew (6/823=0)
label define pathgrouplbl 1 "SE" 2 "SEA" 3 "S" 4 "SEM" 5 "SM" 0 "other"
label values cutpathgroupnew pathgrouplbl
label variable cutpathgroupnew "Top 5 pathways rest from sas call no N- other"
tab selfdischargeED2 callorder if cutpathgroupnew==1, column chi
tab selfdischargeED2 callorder if cutpathgroupnew==1, column chi
tab genderdescription callorder if cutpathgroupnew==1, column chi
gen byte died=(!missing(deathsdateclock)) 
drop iacutecupscid sas_calltime cupscid2N 
drop freq
rename primcauseofdeathicd9icd10classif primcausedeath
rename eddiagnosisondischarge2code3char eddiagnosisondis

////reshape to wide- person period format
#delimit;
reshape wide cupscidstrSC saspathwayname sasincidentnhsboarddescription 
genderdescription sasdiagnosisdescription sascallstartdatetime deathsdate primcausedeath 
seccauseofdeath0code3char ampds edarrivaldatetime eddischargedatetime eddiagnosisgrouping1code 
dischargedestinationcode dischargetypedescription dischargetypecode eddiagnosisondis 
acuteadmissiondate acutedischargedate acuteinpatientdaycasemarkercis patientdobdate gendercode 
maritalstatusdescription ethnicgroupdescription isdid_first mhadmissiondate 
mhdischargedate patientnhsboardcode11 selfdischargeED2 EDdischargetime2 SAS_AE 
cutpathnoN SAS_to_EDtime2 deathsdateclock deathED2 cutpathgroupnew  died freqcall, i(isdid) j(callorder);

////calculate times between first two calls
gen sas_calltime1=clock(sascallstartdatetime1,"YMDhms")
gen sas_calltime2=clock(sascallstartdatetime2,"YMDhms")
drop SAS_to_SAS2time
gen SAS_to_SAS2time=((sas_calltime2-sas_calltime1)/86400000)
summarize SAS_to_SAS2time
summarize SAS_to_SAS2time, detail

///syntax for flow chart of pathways
gen SAS_AE=substr(cutpathnoN1, 1, 2)
gen SAS_AE_W=substr(cutpathnoN1, 1, 3)
gen SAS_AE_WN=substr(cutpathnoN1, 1, 4)
tab SAS_AE_WN
tab SAS_AE, sort
tab SAS_AE_W
tab SAS_AE cutpathgroup2, missing
tab SAS_AE_W died2, missing

gen SAS_to_deathtime=((deathsdateclock1-sas_calltime1)/86400000)
summarize SAS_to_deathtime
tab SAS_AE_W died1 if SAS_to_deathtime<365, missing

gen E=regexm(cutpathnoN1, "E")
tab E
gen A=regexm(cutpathnoN1, "A")
tab A
gen M=regexm(cutpathnoN1, "M")
tab M
tab died1 E if SAS_to_deathtime<365, missing
tab died1 if SAS_to_deathtime<365, missing



encode genderdescription1, gen(genderdescription1n)
///to get number of returns
#delimit ;
egen numreturns=rownonmiss(sascallstartdatetime2 sascallstartdatetime3 sascallstartdatetime4
sascallstartdatetime5 sascallstartdatetime6 sascallstartdatetime7 sascallstartdatetime8 sascallstartdatetime9
sascallstartdatetime10 sascallstartdatetime11 sascallstartdatetime12 sascallstartdatetime13
sascallstartdatetime14 sascallstartdatetime15 sascallstartdatetime16), strok;

tab numreturns died1 if SAS_to_deathtime<365, missing
tab numreturns 
gen lowestprioritySAS=regexm(sasdiagnosiscode1, "A")


tab lowestprioritySAS numreturns
tab cutpathgroupnew lowestprioritySAS if callorder==1, row

gen byte returner=(!missing( SAS_to_SAS2time))



//////syntax for cause of death categories
gen ICD10deathblock=substr(seccauseofdeath0code3char1, 1, 1)

list seccauseofdeath0code3char1 if ICD10deathblock=="E" & SAS_to_deahtime<366
list seccauseofdeath0code3char1 if ICD10deathblock=="G" & SAS_to_deahtime<366
list seccauseofdeath0code3char1 if ICD10deathblock=="I" & SAS_to_deahtime<366
list seccauseofdeath0code3char1 if ICD10deathblock=="X" & SAS_to_deahtime<366
list seccauseofdeath0code3char1 if ICD10deathblock=="Y" & SAS_to_deahtime<366
list seccauseofdeath0code3char1 if ICD10deathblock=="R" & SAS_to_deahtime<366
gen ICD10deathnum=substr(seccauseofdeath0code3char1, 2, .)
destring ICD10deathnum, replace
gen causeofdeath=.
recode causeofdeath (.=1) if (ICD10deathblock=="C") & (ICD10deathnum<97)
recode causeofdeath (.=2) if (ICD10deathblock=="E") & (ICD10deathnum<97)
recode causeofdeath (.=3) if (ICD10deathblock=="F") & (ICD10deathnum<97)
recode causeofdeath (.=4) if (ICD10deathblock=="G") & (ICD10deathnum<97)
recode causeofdeath (.=5) if (ICD10deathblock=="I") & (ICD10deathnum<97)
recode causeofdeath (.=6) if (ICD10deathblock=="J") & (ICD10deathnum<99)
recode causeofdeath (.=7) if (ICD10deathblock=="K") & (ICD10deathnum<99)
recode causeofdeath (.=8) if (ICD10deathblock=="R") & (ICD10deathnum<100)
recode causeofdeath (.=9) if (ICD10deathblock=="V") & (ICD10deathnum<99)
recode causeofdeath (.=9) if (ICD10deathblock=="W") & (ICD10deathnum<97)
recode causeofdeath (.=9) if (ICD10deathblock=="X") & (ICD10deathnum<60)
recode causeofdeath (.=10) if (ICD10deathblock=="X") & (ICD10deathnum>59)
recode causeofdeath (.=11) if (ICD10deathblock=="Y") & (ICD10deathnum<99)

#delimit;
label define deathcause 1 "Malignant neoplasms" 2 "Metabolic disorders" 3 "Mental and behavioural disorders"
4 "Diseases of the nervous system" 5 "Heart disease/ CVD" 6 "Diseases of the respiratory system" 7 "Diseases of the digestive system"
8 "Not elsewhere classified" 9 "Accident" 10 "Self-harm" 11 "Undetermined intent", replace ;

label values causeofdeath deathcause

tab causeofdeath if SAS_to_deahtime<365
tab cutpathgroupnew1 returner, row missing chi
by returner, sort: summarize EDdischargetime21 if cutpathgroupnew1==1, detail
tab selfdischargeED21 returner, row chi

////syntax for SAS categorisation
gen sasdiagnew=.

gen byte SASoverdose=regexm(sasdiagnosisdescription1, "OVERDOSE") 
gen byte SASserioushaem=regexm(sasdiagnosisdescription1, "SERIOUS") 
gen byte SASminorhaem=regexm(sasdiagnosisdescription1, "MINOR") 
gen byte SASthreatening=regexm(sasdiagnosisdescription1, "THREATENING") 
gen byte SASunconscious=regexm(sasdiagnosisdescription1, "ARREST")
gen byte SASnotalert=regexm(sasdiagnosisdescription1, "NOT ALERT")
gen byte SASawake=regexm(sasdiagnosisdescription1, "AWAKE")

replace sasdiagnew=1 if SASunconscious==1
replace sasdiagnew=1 if SASnotalert==1
replace sasdiagnew=2 if SASserioushaem==1
replace sasdiagnew=3 if SASoverdose==1
replace sasdiagnew=4 if SASminorhaem==1
replace sasdiagnew=5 if SASthreatening==1
replace sasdiagnew=6 if SASawake==1

label variable sasdiagnew "recode of SAS to < categories"
label define sasdiagnewlb 1 "unconscious or not alert" 2 "serious haemorrage" 3 "overdose" 4 "minor haemorrage" 5 "threatening suicide" 6 "psych awake and alert"
label values sasdiagnew sasdiagnewlb

logistic returner1 ib6.sasdiagnew 
describe maritalstatusdescription1
	gen maritalstat=maritalstatusdescription1

	/////replace missing demographic varaibles with data from later admissions if missing in first adminssion etc
	
	foreach num of numlist 2/79 {
	 
	replace  maritalstat=maritalstatusdescription`num' if ((maritalstat)==" "|(maritalstat)=="") 
			    }
tab maritalstat

gen byte female=regexm(genderdescription1, "FEMALE")
drop male
				replace dobany=patientdobdate1

	
	foreach num of numlist 2/79 {
	 
	replace  dobany=patientdobdate`num' if ((dobany)==" "|(dobany)=="") & (!missing(patientdobdate`num'))
			    }
				
				

	
drop ageany	
	gen dobanyclock=clock(dobany,"YMDhms")
gen ageany=(sas_calltime1-dobanyclock)/31536000000
summarize ageany
encode 
describe gendercode1
encode maritalstat, gen(maritaln)
nbreg numcallyear1 female  ib6.sasdiagnew ageany, irr

	gen ethnicany=ethnicgroupdescription1

	
	foreach num of numlist 2/79 {
	 
	replace  ethnicany=ethnicgroupdescription`num' if ((ethnicany)==" "|(ethnicany)=="") & (!missing(ethnicgroupdescription`num'))
			    }
				
				



drop ethnicn
encode ethnicany, gen(ethnicn)
label list ethnicn
recode ethnicn (1=.)
recode ethnicn (2/4=0) (5=1) (6=0) (7=1) (8/9=0) (10=1) (11=.) (12=0) (13=1) (14/16=0) (17=.) (18=1)
tab ethnicn
label define ethnicn2 0 "Other" 1 "White British"
label values ethnicn ethnicn2
sum ageany
gen centreageany =ageany-42.46
poisson numcallyear1 female ib6.sasdiagnew ethnicn i.maritaln centreageany , irr
logistic returner1 female ib6.sasdiagnew  if died==0 & sample21==1, or
sum numcallyear1, detail
drop died
gen died=1
replace died=0 if deathsdate1==""
replace died=0 if deathsdate1==" "
tab died
