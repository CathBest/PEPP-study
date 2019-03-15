
////use a data file that has sample 2 identified and is merged with new ED data (set up for this in minimum syntax file 1 final)
///e.g. use cath MERGED DATA4

///create variable for position of the critical S in pathway- that is a variable that contain the position of the index call 'S' in the carepathway name
drop   cupscidstrSC2 cupscidstrSC1
drop cutpath
///split the string containing the position of the index call 
split cupscidstrSC, p("C")
///change the number after the C into a numeric variable
gen cupscid2N=real(cupscidstrSC2)

//cut pathway name at critical S value
gen cutpath= substr(saspathwayname,cupscid2N,.)
tab cutpath
///remove Ns from pathway name and count them
///this is a loop that loops over each pathway and removes Ns one at a time and counts them
tempvar t1 t2
gen `t1'=cutpath
gen `t2'=cutpath
gen numN=0
gen cutpathnoN=" "
while 1{
	replace `t2'=regexr(`t1',"N", "")
	cap ass `t1'==`t2'
	if _rc {
		replace numN=numN+ (`t1' != `t2')
		replace cutpathnoN= `t2'
		replace `t1' =`t2'
		 
	}
	else continue, br
	}


	
	tab cutpathnoN, sort
//variable for any SE string in pathway///
////to get numbers taken straight to A&E
gen SAS_AE=regexm(cutpathnoN, "SE")
tab SAS_AE

//// group the carepathways and count how many in each group (freq)
bysort cutpathnoN : gen freq = -_N
///label the groups cutpathgroupnew
egen cutpathgroupnew =group(freq cutpathnoN)
tab cutpathgroupnew
///keep only the first 5 groups recode rest to 0
recode cutpathgroupnew (6/823=0)

tab cutpathgroupnew 
////label the groups
label define pathgrouplbl2 1 "SE" 2 "SEA" 3 "S" 4 "SEM" 5 "SM" 0 "other"
label values cutpathgroupnew pathgrouplbl2
label variable cutpathgroupnew "Top 5 pathways vs rest from SAS call no N or death"
tab cutpathgroupnew
list iacutecupscid saspathwayname cupscidstrSC if missing(cutpathgroupnew)
////pathways where is the critical S is in position greater than 11 are missing n=27 recode these to other
recode cutpathgroupnew (.=0)

///calculate times for each step of pathway
///gen sas_calltime=clock( sascallstartdatetime, "YMDhms")///already in file


gen ed_arrivaltime=clock(edarrivaldatetime,"YMDhms")
gen SAS_to_EDtime=((ed_arrivaltime-sas_calltime)/60000)
label variable SAS_to_EDtime "Time from SAS psych call to ED arrival mins"
////this needed recalculating after receiving revised data on A&E attendances from Kathy
////the syntax files for including (merging) new data and calcaulting new variables based on new file are in the 
////folder Cath data\Syntax to use new A&E data\
gen SAS_to_EDtime2=((ed_arrivaltimenew-sas_calltime)/60000)
label variable SAS_to_EDtime2 "New Time from SAS psych call to ED arrival mins"

////calculate time for SAS call until death
gen deathsdateclock=clock(deathsdate,"YMDhms")
gen deathSAScall=(deathsdateclock-sas_calltime)/86400000
label variable deathED "Days from SAS psych call to death"
summarize deathED if cutpathnoN=="S"
hist deathSAScall

///calculate time from ED arrival until death
gen deathED2=(deathsdateclock-ed_arrivaltimenew)/86400000
label variable deathED "Days from ED arrival to death"

///syntax for tables in revised Word doc
///calculate time in ED
gen eddischargedatetimeclock=clock(eddischargedatetime,"YMDhms")
gen EDdischargetime=(eddischargedatetimeclock-ed_arrivaltime)/60000
hist EDdischargetime
gen EDdischargetime2=(EDdischargetimenew-ed_arrivaltimenew)/60000
hist EDdischargetime2
list 
summarize EDdischargetime2
eddischargedatetimeclock
 EDdischargetimenew
summarize ed_arrivaltimenew
list ed_arrivaltimenew  EDdischargetimenew if EDdischargetime2<-10000
recode cutpathgroupnew (.=0)
///breakdown for tables

//use one below for column 2
by cutpathgroupnew, sort: summarize SAS_to_EDtime2, detail
///this still includes negative values
by cutpathgroupnew, sort: summarize SAS_to_EDtime2 if (SAS_to_EDtime2>0), detail
//use one below for column 3
by cutpathgroupnew, sort: summarize EDdischargetime2, detail
by cutpathgroupnew, sort: summarize EDdischargetime2, detail
summarize EDdischargetime2 if (cutpathgroupnew!=3) & (cutpathgroupnew!=5), detail 
by cutpathgroupnew, sort: summarize SAS_to_EDtime2 if (SAS_to_EDtime2>0) & (sasalcoholrelated=="N")  , detail
by cutpathgroupnew, sort: summarize SAS_to_EDtime2, detail
by cutpathgroupnew, sort: summarize EDdischargetime2 if (sasalcoholrelated=="N"), detail
by cutpathgroupnew, sort: summarize EDdischargetime2, detail


by cutpathgroup4, sort: summarize SAS_to_EDtime2 if (SAS_to_EDtime2>0)  , detail
by cutpathgroup4, sort: summarize EDdischargetime2, detail
by cutpathgroup4, sort: summarize deathSAScall, detail

///calculate time in acute hospital
gen acuteadmissiondateclock=clock(acuteadmissiondate,"YMDhms")
gen acutedischargedateclock=clock(acutedischargedate,"YMDhms")
gen acutestaytime=(acutedischargedateclock-acuteadmissiondateclock)/86400000
by cutpathgroupnew, sort: summarize acutestaytime, detail

///calculate time in MH hospital
gen mhadmissiondateclock=clock(mhadmissiondate,"YMDhms")
gen mhdischargedateclock=clock(mhdischargedate,"YMDhms")

gen mhstaytime=(mhdischargedateclock-mhadmissiondateclock)/86400000
by cutpathgroupnew, sort: summarize mhstaytime, detail
///to get mental health stay time for SM and SEM together
summarize mhstaytime if cutpathgroupnew>3, detail
by cutpathgroup4, sort: summarize mhstaytime, detail
drop secndcaretime

gen acutestaytime2=acutestaytime
recode acutestaytime2 (.=0)
gen mhstaytime2= mhstaytime
recode mhstaytime2 (.=0)
gen secndcaretime=mhstaytime2+acutestaytime2
recode secndcaretime (0=.)


summarize secndcaretime if cutpathgroupnew==0, detail
summarize SAS_to_EDtime2 if (SAS_to_EDtime2>0), detail
summarize EDdischargetime2 if (SAS_to_EDtime2>0), detail
summarize mhstaytime, detail
tab cutpathgroup4, missing
summarize deathSAScall, detail
recode cutpathgroup4 (.=0)
///investigate why so many zeros in acute stay
gen byte nilacutestay=(acutestaytime==0) if !missing(acutestaytime)
tab nilacutestay

////create a variable for self-discharge from ED
gen byte selfdischargeED2=regexm(Eddischargetype2, "04") if !missing(Eddischargetype2)
codebook Eddischargetype2

recode selfdischargeED2 (0=.)  if (Eddischargetype2==" ")
recode selfdischargeED2 (0=.)  if (Eddischargetype2=="")
 
by selfdischargeED2, sort: summarize  EDdischargetime2 if (cutpathgroupnew2==1), detail

///generate variable for SAS priority
gen str1 AMPDSpriority= substr(sasdiagnosiscode, 3, 1)
tab AMPDSpriority Edtriagecatcode2, missing

///make combined variable for any drug use
encode opiaterelated, gen(opiaterelated2)
encode amphetaminerelated, gen(amphetaminerelated2) 
encode barbituraterelated, gen(barbituraterelated2)
encode inhalantrelated, gen(inhalantrelated2)
encode cannabisrelated, gen(cannabisrelated2) 
encode cocainerelated, gen(cocainerelated2) 
encode ecstasyrelated, gen(ecstasyrelated2) 

codebook opiaterelated2
#delimit ;
egen drugrelated =anymatch(opiaterelated2 amphetaminerelated2 
barbituraterelated2 inhalantrelated2 cannabisrelated2 cocainerelated2 ecstasyrelated2), values(2);
tab drugrelated

tab AMPDSpriority Edtriagecatcode2, missing


/////create a variable for ED discharge ICD10 codes
gen ICD10edblock=substr(Eddischargcatcode2 , 1, 1)

gen ICD10ednum=substr(Eddischargcatcode2, 2, .)
destring ICD10ednum, replace
gen eddischargediagblock=.

recode eddischargediagblock (.=1) if (ICD10edblock=="C") & (ICD10ednum<97)
recode eddischargediagblock (.=2) if (ICD10edblock=="E") & (ICD10ednum<97)
recode eddischargediagblock (.=3) if (ICD10edblock=="F") & (ICD10ednum<97)
recode eddischargediagblock(.=4) if (ICD10edblock=="G") & (ICD10ednum<97)
recode eddischargediagblock (.=5) if (ICD10edblock=="I") & (ICD10ednum<97)
recode eddischargediagblock (.=6) if (ICD10edblock=="J") & (ICD10ednum<99)
recode eddischargediagblock (.=7) if (ICD10edblock=="K") & (ICD10ednum<99)
recode eddischargediagblock (.=8) if (ICD10edblock=="R") & (ICD10ednum<100)
recode eddischargediagblock (.=9) if (ICD10edblock=="V") & (ICD10ednum<99)
recode eddischargediagblock (.=9) if (ICD10edblock=="W") & (ICD10ednum<97)
recode eddischargediagblock (.=9) if (ICD10edblock=="X") & (ICD10ednum<60)
recode eddischargediagblock (.=10) if (ICD10edblock=="X") & (ICD10ednum>59)
recode eddischargediagblock (.=11) if (ICD10edblock=="Y") & (ICD10ednum<99)
recode eddischargediagblock (.=12) if (ICD10edblock=="A") & (ICD10ednum<99)
recode eddischargediagblock (.=12) if (ICD10edblock=="B") & (ICD10ednum<99)
recode eddischargediagblock (.=1) if (ICD10edblock=="D") & (ICD10ednum<99)
recode eddischargediagblock (.=13) if (ICD10edblock=="L") & (ICD10ednum<99)
recode eddischargediagblock (.=14) if (ICD10edblock=="M") & (ICD10ednum<99)
recode eddischargediagblock (.=15) if (ICD10edblock=="N") & (ICD10ednum<99)
recode eddischargediagblock (.=16) if (ICD10edblock=="S") & (ICD10ednum<99)
recode eddischargediagblock (.=16) if (ICD10edblock=="T") & (ICD10ednum<99)
recode eddischargediagblock (.=17) if (ICD10edblock=="Z") & (ICD10ednum<99)
#delimit;
label define eddiag 1 "Neoplasms" 2 "Metabolic disorders" 3 "Mental and behavioural disorders"
4 "Diseases of the nervous system" 5 "Heart disease/ CVD" 6 "Diseases of the respiratory system" 7 "Diseases of the digestive system"
8 "Not elsewhere classified" 9 "Accident" 10 "Self-harm" 11 "Undetermined intent" 12 "Infectious or parasitic diseases"
13 "Diseases of the skin" 14 "Diseases of the musculoskeletal system" 15 "Diseases of the genitourinary system"
16 "Injury or poisoning" 17 "Factors influencing health serice utilization" , replace ;

label values eddischargediagblock eddiag
tab  eddischargediagblock, missing
tab  eddischargediagblock  sasdiagnosisdescription if SAS_to_EDtime<300, missing
drop eddischdiagmh

///recode to fewer categories
recode eddischargediagblock (1/2=0) (3=1) (4=1) (5/8=0) (9=2) (10/11=3) (12/15=0) (16=3) (17=4), gen(eddischdiagmh)
tab eddischdiagmh eddischargediagblock, missing
label define eddiag2 0 "Physical health" 1 "Mental and behavioural disorders" 2 "Accident" 3 "Self-harm/ undetermined intent" 4 " Factors influencing health service utilization"
label values eddischdiagmh eddiag2
tab eddischdiagmh
tab eddischdiagmh selfdischargeED2, missing
tab eddischdiagmh selfdischargeED2, column chi
tab eddischdiagmh selfdischargeED2 if cutpathgroupnew2==1, row missing 


////create a variable for SAS categories from SAS diagnosis description
gen sasdiagnew=.

gen byte SASoverdose=regexm(sasdiagnosisdescription, "OVERDOSE") 
gen byte SASserioushaem=regexm(sasdiagnosisdescription, "SERIOUS") 
gen byte SASminorhaem=regexm(sasdiagnosisdescription, "MINOR") 
gen byte SASthreatening=regexm(sasdiagnosisdescription, "THREATENING") 
gen byte SASunconscious=regexm(sasdiagnosisdescription, "ARREST")
gen byte SASnotalert=regexm(sasdiagnosisdescription, "NOT ALERT")
gen byte SASawake=regexm(sasdiagnosisdescription, "AWAKE")

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


///investigate relationships
tab AMPDSpriority selfdischargeED2, row chi
tab selfdischargeED2 sasdiagnew, column chi
tab selfdischargeED2 sasdiagnew if cutpathgroupnew2==1, column chi
by sasdiagnew, sort: summarize deathED2, detail

tab sasdiagnew eddischdiagmh if (cutpathgroupnew2==1), row missing
encode genderdescription, gen(sex)
encode sasalcoholrelated, gen(alcohol)
by selfdischargeED2, sort: summarize  EDdischargetime2 if (cutpathgroupnew2==1), detail
median EDdischargetime2 if (cutpathgroupnew2==1) , by (alcohol)
median EDdischargetime2 if (cutpathgroupnew2==1) , by (selfdischargeED2)
ranksum EDdischargetime2 if (cutpathgroupnew2==1) , by (selfdischargeED2)
tab alcohol selfdischargeED2 if (cutpathgroupnew2==1), row chi
tab sasdiagnew selfdischargeED2 if (cutpathgroupnew2==1), row chi 

tab sasdiagnew selfdischargeED2
tab sex if SAS_AE, missing
tab sex sasdiagnew, column chi
poisson freqcall sex ib6.sasdiagnew alcohol selfdischargeED2 i.simd if callorder==1


////investigate why some have negative time between SAs call and ED arrival
list ïacutecupid cupscid saspathwayname sascallstartdatetime edarrivaldatetime if (SAS_to_EDtime<0) & (cutpathgroup3==0)
gen byte neg_arrival_time=(SAS_to_EDtime<0) if !missing(SAS_to_EDtime)
tab neg_arrival_time

summarize SAS_to_EDtime if (cutpathgroupnew==0) & (SAS_to_EDtime>0) &(SAS_to_EDtime>300), detail
list ïacutecupid cupscid saspathwayname SAS_to_EDtime sascallstartdatetime edarrivaldatetime if (cutpathgroupnew==0) & (SAS_to_EDtime>0) &(SAS_to_EDtime>300) &!missing(SAS_to_EDtime)


///syntax for flow chart of pathways- all syntax below not used 
gen SAS_AE=substr(cutpathnoN, 1, 2)
gen SAS_AE_W=substr(cutpathnoN, 1, 3)
gen SAS_AE_WN=substr(cutpathnoN, 1, 4)
tab SAS_AE_WN
tab SAS_AE, sort
tab SAS_AE_W
tab SAS_AE cutpathgroup2, missing


/* Calls made in Year 2011  */
gen sascall_2011=.
replace sascall_2011=1 if sascall_date >= td(03jan2011) & sascall_date <= td(31dec2011)
tab sascall_2011



/// count Es
tempvar t1 t2
gen `t1'=cutpath
gen `t2'=cutpath
gen numE=0

while 1{
	replace `t2'=regexr(`t1',"E", "")
	cap ass `t1'==`t2'
	if _rc {
		replace numE=numE+ (`t1' != `t2')
			replace `t1' =`t2'
		 
	}
	else continue, br
}

by numE, sort:summarize SAS_to_EDtime

list cupscid edarrivaldatetime cutpathnoN if (numE==2) & (age<30) &(age>20)
list cupscid edarrivaldatetime cutpathnoN if (numE==2) & (age==20)
list cupscid edarrivaldatetime cutpathnoN if (numE==2) & (age>=30) & (age<40)





