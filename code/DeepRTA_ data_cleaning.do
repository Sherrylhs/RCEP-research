*由kmean++算法得到4个RTA的cluster(Silhouette method)
import delimited "D:\RCEP\data\gravity_raw_data\bilateralDATA2.csv", encoding(UTF-8) 
drop type
keep if year>=1995
gen main_country=0
replace main_country =  1 if (iso1=="ARG"|iso1=="AUS"|iso1=="BEL"|iso1=="BRA"|iso1=="BRN"|iso1=="CAN"|iso1=="CHL"|iso1=="CHN"|iso1=="CZE"|iso1=="DEU"|iso1=="ESP"|iso1=="FRA"|iso1=="GBR"|iso1=="HKG"|iso1=="IDN"|iso1=="IND"|iso1=="ISR"|iso1=="ITA"|iso1=="JPN"|iso1=="KAZ"|iso1=="KHM"|iso1=="KOR"|iso1=="LAO"|iso1=="MEX"|iso1=="MMR"|iso1=="MYS"|iso1=="NLD"|iso1=="NZL"|iso1=="PHL"|iso1=="POL"|iso1=="RUS"|iso1=="SAU"|iso1=="SWE"|iso1=="SGP"|iso1=="THA"|iso1=="TUR"|iso1=="TWN"|iso1=="USA"|iso1=="VNM"|iso1=="ZAF") &(iso2=="ARG"|iso2=="AUS"|iso2=="BEL"|iso2=="BRA"|iso2=="BRN"|iso2=="CAN"|iso2=="CHL"|iso2=="CHN"|iso2=="CZE"|iso2=="DEU"|iso2=="ESP"|iso2=="FRA"|iso2=="GBR"|iso2=="HKG"|iso2=="IDN"|iso2=="IND"|iso2=="ISR"|iso2=="ITA"|iso2=="JPN"|iso2=="KAZ"|iso2=="KHM"|iso2=="KOR"|iso2=="LAO"|iso2=="MEX"|iso2=="MMR"|iso2=="MYS"|iso2=="NLD"|iso2=="NZL"|iso2=="PHL"|iso2=="POL"|iso2=="RUS"|iso2=="SAU"|iso2=="SWE"|iso2=="SGP"|iso2=="THA"|iso2=="TUR"|iso2=="TWN"|iso2=="USA"|iso2=="VNM"|iso2=="ZAF")
keep if main_country == 1
//cluster4
gen RTA1 = 0 
replace RTA1=1 if cluster4 == 1
gen RTA2 = 0 
replace RTA2=1 if cluster4 == 2
gen RTA3 = 0 
replace RTA3=1 if cluster4 == 3
gen RTA4 = 0 
replace RTA4=1 if cluster4 == 4
keep iso1 iso2 year RTA1 RTA2 RTA3 RTA4 agreement entry_force
sort iso1 iso2 year
order year, b(agreement)
bysort iso1 iso2 year :egen p1 = sum(RTA1)
 replace p1 = 1 if p1 != 0
bysort iso1 iso2 year :egen p2 = sum(RTA2)
 replace p2 = 1 if p2 != 0
bysort iso1 iso2 year :egen p3 = sum(RTA3)
 replace p3 = 1 if p3 != 0
bysort iso1 iso2 year :egen p4 = sum(RTA4)
 replace p4 = 1 if p4 != 0
drop agreement entry_force RTA1 RTA2 RTA3 RTA4
gen RTA1 = p1
gen RTA2 = p2
gen RTA3 = p3
gen RTA4 = p4
drop p3 p4 p1 p2
duplicates drop
save "D:\RCEP\data\sector_processed_data\KmeanCluster4_2",replace
//
use "D:\RCEP\data\sector_processed_data\export_latest.dta",clear
keep Exp_cou Imp_cou Year
duplicates drop
save "D:\RCEP\data\sector_processed_data\head",replace
//
import delimited "D:\RCEP\data\gravity_raw_data\KmeanCluster4_2.csv", encoding(UTF-8) 
rename exp_cou Exp_cou
rename imp_cou Imp_cou
rename year Year
egen match= group(Year Exp_cou Imp_cou)
save "D:\RCEP\data\sector_processed_data\KCluster4_2",replace

use "D:\RCEP\data\sector_processed_data\export_latest.dta",clear
egen match= group(Year Exp_cou Imp_cou)
merge m:1 match using "D:\RCEP\data\sector_processed_data\KCluster4_2"
drop RTA _merge match
save "D:\RCEP\data\sector_processed_data\export_Cluster4_2.dta",replace

*由kmean++算法得到3个RTA的cluster(Gap Statistic Method)
import delimited "D:\RCEP\data\gravity_raw_data\bilateralDATA.csv", encoding(UTF-8) 
drop type
keep if year>=1995
gen main_country=0
replace main_country =  1 if (iso1=="ARG"|iso1=="AUS"|iso1=="BEL"|iso1=="BRA"|iso1=="BRN"|iso1=="CAN"|iso1=="CHL"|iso1=="CHN"|iso1=="CZE"|iso1=="DEU"|iso1=="ESP"|iso1=="FRA"|iso1=="GBR"|iso1=="HKG"|iso1=="IDN"|iso1=="IND"|iso1=="ISR"|iso1=="ITA"|iso1=="JPN"|iso1=="KAZ"|iso1=="KHM"|iso1=="KOR"|iso1=="LAO"|iso1=="MEX"|iso1=="MMR"|iso1=="MYS"|iso1=="NLD"|iso1=="NZL"|iso1=="PHL"|iso1=="POL"|iso1=="RUS"|iso1=="SAU"|iso1=="SWE"|iso1=="SGP"|iso1=="THA"|iso1=="TUR"|iso1=="TWN"|iso1=="USA"|iso1=="VNM"|iso1=="ZAF") &(iso2=="ARG"|iso2=="AUS"|iso2=="BEL"|iso2=="BRA"|iso2=="BRN"|iso2=="CAN"|iso2=="CHL"|iso2=="CHN"|iso2=="CZE"|iso2=="DEU"|iso2=="ESP"|iso2=="FRA"|iso2=="GBR"|iso2=="HKG"|iso2=="IDN"|iso2=="IND"|iso2=="ISR"|iso2=="ITA"|iso2=="JPN"|iso2=="KAZ"|iso2=="KHM"|iso2=="KOR"|iso2=="LAO"|iso2=="MEX"|iso2=="MMR"|iso2=="MYS"|iso2=="NLD"|iso2=="NZL"|iso2=="PHL"|iso2=="POL"|iso2=="RUS"|iso2=="SAU"|iso2=="SWE"|iso2=="SGP"|iso2=="THA"|iso2=="TUR"|iso2=="TWN"|iso2=="USA"|iso2=="VNM"|iso2=="ZAF")
keep if main_country == 1
//cluster3
gen RTA1 = 0 
replace RTA1=1 if cluster3 == 1
gen RTA2 = 0 
replace RTA2=1 if cluster3 == 2
gen RTA3 = 0 
replace RTA3=1 if cluster3 == 3
keep iso1 iso2 year RTA1 RTA2 RTA3 
save "D:\RCEP\data\sector_processed_data\KmeanCluster3",replace
//
import delimited "D:\RCEP\data\gravity_raw_data\KmeanCluster3.csv", encoding(UTF-8) 
rename exp_cou Exp_cou
rename imp_cou Imp_cou
rename year Year
egen match= group(Year Exp_cou Imp_cou)
save "D:\RCEP\data\sector_processed_data\KCluster3",replace
//
use "D:\RCEP\data\sector_processed_data\export_latest.dta",clear
keep if Year<=2017
egen match= group(Year Exp_cou Imp_cou)
merge m:1 match using "D:\RCEP\data\sector_processed_data\KCluster3"
drop RTA _merge match
save "D:\RCEP\data\sector_processed_data\export_Cluster3.dta",replace

**********INTL data k4**********
use "D:\RCEP\data\sector_processed_data\export_INTL_latest.dta",clear
keep if Year<=2017
egen match= group(Year Exp_cou Imp_cou)
merge m:1 match using "D:\RCEP\data\sector_processed_data\KCluster4"
drop RTA _merge match
save "D:\RCEP\data\sector_processed_data\export_INTL_Cluster4.dta",replace

**********FD data k4**********
use "D:\RCEP\data\sector_processed_data\export_FD_latest.dta",clear
keep if Year<=2017
egen match= group(Year Exp_cou Imp_cou)
merge m:1 match using "D:\RCEP\data\sector_processed_data\KCluster4"
drop RTA _merge match
save "D:\RCEP\data\sector_processed_data\export_FD_Cluster4.dta",replace
