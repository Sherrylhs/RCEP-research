*******data merge*******
use "D:\RCEP Research\data\gravity_raw_data\TIVA\latest_year\EXGR.dta",clear
sort Year Exp_cou Exp_ind Imp_cou
gen main_country=0
replace main_country =  1 if (Exp_cou ==	"ARE"	|Exp_cou	==	"ARG"	|Exp_cou	==	"AUS"	|Exp_cou	==	"BEL"	|Exp_cou	==	"BGD"	|Exp_cou	==	"BRA"	|Exp_cou	==	"BRN"	|Exp_cou	==	"CAN"	|Exp_cou	==	"CHL"	|Exp_cou	==	"CZE"	|Exp_cou	==	"DEU"	|Exp_cou	==	"EGY"	|Exp_cou	==	"ESP"	|Exp_cou	==	"FRA"	|Exp_cou	==	"GBR"	|Exp_cou	==	"HKG"	|Exp_cou	==	"IDN"	|Exp_cou	==	"IND"	|Exp_cou	==	"IRN"	|Exp_cou	==	"ISR"	|Exp_cou	==	"ITA"	|Exp_cou	==	"JPN"	|Exp_cou	==	"KAZ"	|Exp_cou	==	"KHM"	|Exp_cou	==	"KOR"	|Exp_cou	==	"LAO"	|Exp_cou	==	"MEX"	|Exp_cou	==	"MMR"	|Exp_cou	==	"MYS"	|Exp_cou	==	"NGA"	|Exp_cou	==	"NLD"	|Exp_cou	==	"NZL"	|Exp_cou	==	"PAK"	|Exp_cou	==	"PAN"	|Exp_cou	==	"PHL"	|Exp_cou	==	"POL"	|Exp_cou	==	"RUS"	|Exp_cou	==	"SAU"	|Exp_cou	==	"SGP"	|Exp_cou	==	"SWE"	|Exp_cou	==	"THA"	|Exp_cou	==	"TUR"	|Exp_cou	==	"TWN"	|Exp_cou	==	"USA"	|Exp_cou	==	"VNM"	|Exp_cou	==	"ZAF"	|Exp_cou	==	"CHN"|Exp_cou ==	"WLD"	) &(Imp_cou	==	"ARE"	|Imp_cou	==	"ARG"	|Imp_cou	==	"AUS"	|Imp_cou	==	"BEL"	|Imp_cou	==	"BGD"	|Imp_cou	==	"BRA"	|Imp_cou	==	"BRN"	|Imp_cou	==	"CAN"	|Imp_cou	==	"CHL"	|Imp_cou	==	"CZE"	|Imp_cou	==	"DEU"	|Imp_cou	==	"EGY"	|Imp_cou	==	"ESP"	|Imp_cou	==	"FRA"	|Imp_cou	==	"GBR"	|Imp_cou	==	"HKG"	|Imp_cou	==	"IDN"	|Imp_cou	==	"IND"	|Imp_cou	==	"IRN"	|Imp_cou	==	"ISR"	|Imp_cou	==	"ITA"	|Imp_cou	==	"JPN"	|Imp_cou	==	"KAZ"	|Imp_cou	==	"KHM"	|Imp_cou	==	"KOR"	|Imp_cou	==	"LAO"	|Imp_cou	==	"MEX"	|Imp_cou	==	"MMR"	|Imp_cou	==	"MYS"	|Imp_cou	==	"NGA"	|Imp_cou	==	"NLD"	|Imp_cou	==	"NZL"	|Imp_cou	==	"PAK"	|Imp_cou	==	"PAN"	|Imp_cou	==	"PHL"	|Imp_cou	==	"POL"	|Imp_cou	==	"RUS"	|Imp_cou	==	"SAU"	|Imp_cou	==	"SGP"	|Imp_cou	==	"SWE"	|Imp_cou	==	"THA"	|Imp_cou	==	"TUR"	|Imp_cou	==	"TWN"	|Imp_cou	==	"USA"	|Imp_cou	==	"VNM"	|Imp_cou	==	"ZAF"	|Imp_cou	==	"CHN"|Imp_cou ==	"WLD"	)
keep if main_country == 1
gen RCEP=0 
replace RCEP=1 if (Imp_cou == "JPN"|Imp_cou == "KOR"|Imp_cou == "AUS"|Imp_cou == "NZL"|Imp_cou == "BRN"|Imp_cou == "KHM"|Imp_cou == "IDN"|Imp_cou == "LAO"|Imp_cou == "MYS"|Imp_cou == "PHL"|Imp_cou == "SGP"| Imp_cou == "MMR"|Imp_cou == "THA"|Imp_cou == "VNM"|Imp_cou	==	"CHN") & (Exp_cou == "JPN"|Exp_cou == "KOR"|Exp_cou == "AUS"|Exp_cou == "NZL"|Exp_cou == "BRN"|Exp_cou == "KHM"|Exp_cou == "IDN"|Exp_cou == "LAO"|Exp_cou == "MYS"|Exp_cou == "PHL"|Exp_cou == "SGP"| Exp_cou == "MMR"|Exp_cou == "THA"|Exp_cou == "VNM"|Exp_cou == "CHN")
replace RCEP =0 if Imp_cou == Exp_cou
egen match = group(Year Exp_cou Exp_ind)
save "D:\RCEP\data\sector_processed_data\GrossExport.dta",replace  //

use "D:\RCEP Research\data\gravity_raw_data\TIVA\latest_year\PROD.dta", clear
gen main_country=0
replace main_country =  1 if (Prod_cou ==	"ARE"	|Prod_cou	==	"ARG"	|Prod_cou	==	"AUS"	|Prod_cou	==	"BEL"	|Prod_cou	==	"BGD"	|Prod_cou	==	"BRA"	|Prod_cou	==	"BRN"	|Prod_cou	==	"CAN"	|Prod_cou	==	"CHL"	|Prod_cou	==	"CZE"	|Prod_cou	==	"DEU"	|Prod_cou	==	"EGY"	|Prod_cou	==	"ESP"	|Prod_cou	==	"FRA"	|Prod_cou	==	"GBR"	|Prod_cou	==	"HKG"	|Prod_cou	==	"IDN"	|Prod_cou	==	"IND"	|Prod_cou	==	"IRN"	|Prod_cou	==	"ISR"	|Prod_cou	==	"ITA"	|Prod_cou	==	"JPN"	|Prod_cou	==	"KAZ"	|Prod_cou	==	"KHM"	|Prod_cou	==	"KOR"	|Prod_cou	==	"LAO"	|Prod_cou	==	"MEX"	|Prod_cou	==	"MMR"	|Prod_cou	==	"MYS"	|Prod_cou	==	"NGA"	|Prod_cou	==	"NLD"	|Prod_cou	==	"NZL"	|Prod_cou	==	"PAK"	|Prod_cou	==	"PAN"	|Prod_cou	==	"PHL"	|Prod_cou	==	"POL"	|Prod_cou	==	"RUS"	|Prod_cou	==	"SAU"	|Prod_cou	==	"SGP"	|Prod_cou	==	"SWE"	|Prod_cou	==	"THA"	|Prod_cou	==	"TUR"	|Prod_cou	==	"TWN"	|Prod_cou	==	"USA"	|Prod_cou	==	"VNM"	|Prod_cou	==	"ZAF"	|Prod_cou	==	"CHN")
keep if main_country == 1
egen match = group(Year Prod_cou Prod_ind)
save "D:\RCEP\data\sector_processed_data\Production.dta",replace  //
*merge*
use "D:\RCEP\data\sector_processed_data\GrossExport.dta",clear
merge m:1 match using "D:\RCEP\data\sector_processed_data\Production.dta"
drop _merge World match Prod_cou Prod_ind
*generate intranational trade
generate xii = production - export
replace xii = 0 if Imp_cou != "WLD"
drop if Imp_cou == Exp_cou
replace Imp_cou = Exp_cou if Imp_cou == "WLD"
replace export = xii if Exp_cou == Imp_cou
sort Year Exp_cou Exp_ind Imp_cou
replace export = . if export<0
drop main_country xii 
egen match2= group( Year Exp_cou Imp_cou)
save "D:\RCEP\data\sector_processed_data\TivaExport.dta",replace

*********************gen cepii dataset *****************
use "D:\RCEP1\data\processed_data\export.dta",clear
keep if year>=1995 & year<=2018
keep year exporter importer RTA contig dist comlang_off comcol comrelig colony legal
gen main_country=0
replace main_country =  1 if (exporter	==	"ARG"	|exporter	==	"AUS"	|exporter	==	"BEL"|exporter	==	"BRA"	|exporter	==	"BRN"	|exporter	==	"CAN"	|exporter	==	"CHL"	|exporter	==	"CZE"	|exporter	==	"DEU"|exporter	==	"ESP"	|exporter	==	"FRA"	|exporter	==	"GBR"	|exporter	==	"HKG"	|exporter	==	"IDN"	|exporter	==	"IND"|exporter	==	"ISR"	|exporter	==	"ITA"	|exporter	==	"JPN"	|exporter	==	"KAZ"	|exporter	==	"KHM"	|exporter	==	"KOR"	|exporter	==	"MEX"|exporter	==	"MYS"	|exporter	==	"NLD"	|exporter	==	"NZL"	|exporter	==	"PHL"	|exporter	==	"POL"	|exporter	==	"RUS"	|exporter	==	"SAU"	|exporter	==	"SGP"	|exporter	==	"SWE"	|exporter	==	"THA"	|exporter	==	"TUR"	|exporter	==	"TWN"	|exporter	==	"USA"	|exporter	==	"VNM"	|exporter	==	"ZAF"	|exporter	==	"CHN"|exporter	==	"MMR"|exporter	==	"LAO") &(importer	==	"ARG"	|importer	==	"AUS"	|importer	==	"BEL"|importer	==	"BRA"	|importer	==	"BRN"	|importer	==	"CAN"	|importer	==	"CHL"	|importer	==	"CZE"	|importer	==	"DEU"|importer	==	"ESP"	|importer	==	"FRA"	|importer	==	"GBR"	|importer	==	"HKG"	|importer	==	"IDN"	|importer	==	"IND"|importer	==	"ISR"	|importer	==	"ITA"	|importer	==	"JPN"	|importer	==	"KAZ"	|importer	==	"KHM"	|importer	==	"KOR"	|importer	==	"MEX"|importer	==	"MYS"	|importer	==	"NLD"	|importer	==	"NZL"	|importer	==	"PHL"	|importer	==	"POL"	|importer	==	"RUS"	|importer	==	"SAU"	|importer	==	"SGP"	|importer	==	"SWE"	|importer	==	"THA"	|importer	==	"TUR"	|importer	==	"TWN"	|importer	==	"USA"	|importer	==	"VNM"	|importer	==	"ZAF"	|importer	==	"CHN"||importer	==	"MMR"|importer	==	"LAO")
keep if main_country == 1
drop main_country
egen match2= group(year exporter importer )
save "D:\RCEP\data\sector_processed_data\cepii_merge.dta",replace

****merge into final dataset*****
use "D:\RCEP\data\sector_processed_data\TivaExport.dta",clear
merge m:1 match2 using "D:\RCEP\data\sector_processed_data\cepii_merge.dta"
drop _merge year exporter importer match2 EXGR
order RCEP, after (RTA)
save "D:\RCEP\data\sector_processed_data\export_latest.dta",replace


*****************************************
*******2. gen INTL export dataset *******
*****************************************

//gen INT and FD production 
use "D:\RCEP Research\data\gravity_raw_data\TIVA\latest_year\PROD_VASH.dta", clear
gen main_country=0
replace main_country =  1 if (Prod_cou ==	"ARE"	|Prod_cou	==	"ARG"	|Prod_cou	==	"AUS"	|Prod_cou	==	"BEL"	|Prod_cou	==	"BGD"	|Prod_cou	==	"BRA"	|Prod_cou	==	"BRN"	|Prod_cou	==	"CAN"	|Prod_cou	==	"CHL"	|Prod_cou	==	"CZE"	|Prod_cou	==	"DEU"	|Prod_cou	==	"EGY"	|Prod_cou	==	"ESP"	|Prod_cou	==	"FRA"	|Prod_cou	==	"GBR"	|Prod_cou	==	"HKG"	|Prod_cou	==	"IDN"	|Prod_cou	==	"IND"	|Prod_cou	==	"IRN"	|Prod_cou	==	"ISR"	|Prod_cou	==	"ITA"	|Prod_cou	==	"JPN"	|Prod_cou	==	"KAZ"	|Prod_cou	==	"KHM"	|Prod_cou	==	"KOR"	|Prod_cou	==	"LAO"	|Prod_cou	==	"MEX"	|Prod_cou	==	"MMR"	|Prod_cou	==	"MYS"	|Prod_cou	==	"NGA"	|Prod_cou	==	"NLD"	|Prod_cou	==	"NZL"	|Prod_cou	==	"PAK"	|Prod_cou	==	"PAN"	|Prod_cou	==	"PHL"	|Prod_cou	==	"POL"	|Prod_cou	==	"RUS"	|Prod_cou	==	"SAU"	|Prod_cou	==	"SGP"	|Prod_cou	==	"SWE"	|Prod_cou	==	"THA"	|Prod_cou	==	"TUR"	|Prod_cou	==	"TWN"	|Prod_cou	==	"USA"	|Prod_cou	==	"VNM"	|Prod_cou	==	"ZAF"	|Prod_cou	==	"CHN") 
keep if main_country == 1
egen match = group(Year Prod_cou Prod_ind)
save "D:\RCEP\data\sector_processed_data\Prod_Per.dta",replace //
use "D:\RCEP\data\sector_processed_data\Production.dta",clear  
merge m:1 match using "D:\RCEP\data\sector_processed_data\Prod_Per.dta"
drop main_country PROD_VASH _merge
gen FD_per = prod_percent/100
gen INTL_per = 1 - FD_per
gen FD_prod = production * FD_per
gen INTL_prod = production * INTL_per
save "D:\RCEP\data\sector_processed_data\Prod_FD&INTL.dta",replace
use "D:\RCEP\data\sector_processed_data\Prod_FD&INTL.dta",clear
drop World production prod_percent FD_per INTL_per FD_prod
save "D:\RCEP\data\sector_processed_data\Prod_INTL.dta",replace   //INTL production
use "D:\RCEP\data\sector_processed_data\Prod_FD&INTL.dta",clear
drop World production FD_per INTL_per prod_percent INTL_prod
save "D:\RCEP\data\sector_processed_data\Prod_FD.dta",replace  //FD production


use "D:\RCEP Research\data\gravity_raw_data\TIVA\latest_year\EXGR_INT.dta",clear
sort Year Exp_cou Exp_ind Imp_cou
gen main_country=0
replace main_country =  1 if (Exp_cou ==	"ARE"	|Exp_cou	==	"ARG"	|Exp_cou	==	"AUS"	|Exp_cou	==	"BEL"	|Exp_cou	==	"BGD"	|Exp_cou	==	"BRA"	|Exp_cou	==	"BRN"	|Exp_cou	==	"CAN"	|Exp_cou	==	"CHL"	|Exp_cou	==	"CZE"	|Exp_cou	==	"DEU"	|Exp_cou	==	"EGY"	|Exp_cou	==	"ESP"	|Exp_cou	==	"FRA"	|Exp_cou	==	"GBR"	|Exp_cou	==	"HKG"	|Exp_cou	==	"IDN"	|Exp_cou	==	"IND"	|Exp_cou	==	"IRN"	|Exp_cou	==	"ISR"	|Exp_cou	==	"ITA"	|Exp_cou	==	"JPN"	|Exp_cou	==	"KAZ"	|Exp_cou	==	"KHM"	|Exp_cou	==	"KOR"	|Exp_cou	==	"LAO"	|Exp_cou	==	"MEX"	|Exp_cou	==	"MMR"	|Exp_cou	==	"MYS"	|Exp_cou	==	"NGA"	|Exp_cou	==	"NLD"	|Exp_cou	==	"NZL"	|Exp_cou	==	"PAK"	|Exp_cou	==	"PAN"	|Exp_cou	==	"PHL"	|Exp_cou	==	"POL"	|Exp_cou	==	"RUS"	|Exp_cou	==	"SAU"	|Exp_cou	==	"SGP"	|Exp_cou	==	"SWE"	|Exp_cou	==	"THA"	|Exp_cou	==	"TUR"	|Exp_cou	==	"TWN"	|Exp_cou	==	"USA"	|Exp_cou	==	"VNM"	|Exp_cou	==	"ZAF"	|Exp_cou	==	"CHN"|Exp_cou ==	"WLD"	) &(Imp_cou	==	"ARE"	|Imp_cou	==	"ARG"	|Imp_cou	==	"AUS"	|Imp_cou	==	"BEL"	|Imp_cou	==	"BGD"	|Imp_cou	==	"BRA"	|Imp_cou	==	"BRN"	|Imp_cou	==	"CAN"	|Imp_cou	==	"CHL"	|Imp_cou	==	"CZE"	|Imp_cou	==	"DEU"	|Imp_cou	==	"EGY"	|Imp_cou	==	"ESP"	|Imp_cou	==	"FRA"	|Imp_cou	==	"GBR"	|Imp_cou	==	"HKG"	|Imp_cou	==	"IDN"	|Imp_cou	==	"IND"	|Imp_cou	==	"IRN"	|Imp_cou	==	"ISR"	|Imp_cou	==	"ITA"	|Imp_cou	==	"JPN"	|Imp_cou	==	"KAZ"	|Imp_cou	==	"KHM"	|Imp_cou	==	"KOR"	|Imp_cou	==	"LAO"	|Imp_cou	==	"MEX"	|Imp_cou	==	"MMR"	|Imp_cou	==	"MYS"	|Imp_cou	==	"NGA"	|Imp_cou	==	"NLD"	|Imp_cou	==	"NZL"	|Imp_cou	==	"PAK"	|Imp_cou	==	"PAN"	|Imp_cou	==	"PHL"	|Imp_cou	==	"POL"	|Imp_cou	==	"RUS"	|Imp_cou	==	"SAU"	|Imp_cou	==	"SGP"	|Imp_cou	==	"SWE"	|Imp_cou	==	"THA"	|Imp_cou	==	"TUR"	|Imp_cou	==	"TWN"	|Imp_cou	==	"USA"	|Imp_cou	==	"VNM"	|Imp_cou	==	"ZAF"	|Imp_cou	==	"CHN"|Imp_cou ==	"WLD"	)
keep if main_country == 1
gen RCEP=0 
replace RCEP=1 if (Imp_cou == "JPN"|Imp_cou == "KOR"|Imp_cou == "AUS"|Imp_cou == "NZL"|Imp_cou == "BRN"|Imp_cou == "KHM"|Imp_cou == "IDN"|Imp_cou == "LAO"|Imp_cou == "MYS"|Imp_cou == "PHL"|Imp_cou == "SGP"| Imp_cou == "MMR"|Imp_cou == "THA"|Imp_cou == "VNM"|Imp_cou	==	"CHN") & (Exp_cou == "JPN"|Exp_cou == "KOR"|Exp_cou == "AUS"|Exp_cou == "NZL"|Exp_cou == "BRN"|Exp_cou == "KHM"|Exp_cou == "IDN"|Exp_cou == "LAO"|Exp_cou == "MYS"|Exp_cou == "PHL"|Exp_cou == "SGP"| Exp_cou == "MMR"|Exp_cou == "THA"|Exp_cou == "VNM"|Exp_cou == "CHN")
replace RCEP =0 if Imp_cou == Exp_cou
egen match = group(Year Exp_cou Exp_ind)
save "D:\RCEP\data\sector_processed_data\GrossExport_INT.dta",replace  //Export_INT
//merge Export_INT and Prod_INTL
use "D:\RCEP\data\sector_processed_data\GrossExport_INT.dta",clear
merge m:1 match using "D:\RCEP\data\sector_processed_data\Prod_INTL.dta"
drop _merge match main_country Prod_cou Prod_ind 
//generate intranational trade
generate xii = INTL_prod - export_int
replace xii = 0 if Imp_cou != "WLD"
drop if Imp_cou == Exp_cou
replace Imp_cou = Exp_cou if Imp_cou == "WLD"
replace export = xii if Exp_cou == Imp_cou
sort Year Exp_cou Exp_ind Imp_cou
replace export = . if export<0
drop xii 
egen match2= group( Year Exp_cou Imp_cou)
save "D:\RCEP\data\sector_processed_data\TivaExport_INTL.dta",replace
//merge Export_prod_INTL and cepii
use "D:\RCEP\data\sector_processed_data\TivaExport_INTL.dta",clear
merge m:1 match2 using "D:\RCEP\data\sector_processed_data\cepii_merge.dta"
drop _merge year exporter importer match2
order RCEP, after (RTA)
save "D:\RCEP\data\sector_processed_data\export_INTL_latest.dta",replace

***************************************
*******4. gen FD export dataset *******
***************************************

use "D:\RCEP Research\data\gravity_raw_data\TIVA\latest_year\EXGR_FNL.dta",clear
sort Year Exp_cou Exp_ind Imp_cou
gen main_country=0
replace main_country =  1 if (Exp_cou ==	"ARE"	|Exp_cou	==	"ARG"	|Exp_cou	==	"AUS"	|Exp_cou	==	"BEL"	|Exp_cou	==	"BGD"	|Exp_cou	==	"BRA"	|Exp_cou	==	"BRN"	|Exp_cou	==	"CAN"	|Exp_cou	==	"CHL"	|Exp_cou	==	"CZE"	|Exp_cou	==	"DEU"	|Exp_cou	==	"EGY"	|Exp_cou	==	"ESP"	|Exp_cou	==	"FRA"	|Exp_cou	==	"GBR"	|Exp_cou	==	"HKG"	|Exp_cou	==	"IDN"	|Exp_cou	==	"IND"	|Exp_cou	==	"IRN"	|Exp_cou	==	"ISR"	|Exp_cou	==	"ITA"	|Exp_cou	==	"JPN"	|Exp_cou	==	"KAZ"	|Exp_cou	==	"KHM"	|Exp_cou	==	"KOR"	|Exp_cou	==	"LAO"	|Exp_cou	==	"MEX"	|Exp_cou	==	"MMR"	|Exp_cou	==	"MYS"	|Exp_cou	==	"NGA"	|Exp_cou	==	"NLD"	|Exp_cou	==	"NZL"	|Exp_cou	==	"PAK"	|Exp_cou	==	"PAN"	|Exp_cou	==	"PHL"	|Exp_cou	==	"POL"	|Exp_cou	==	"RUS"	|Exp_cou	==	"SAU"	|Exp_cou	==	"SGP"	|Exp_cou	==	"SWE"	|Exp_cou	==	"THA"	|Exp_cou	==	"TUR"	|Exp_cou	==	"TWN"	|Exp_cou	==	"USA"	|Exp_cou	==	"VNM"	|Exp_cou	==	"ZAF"	|Exp_cou	==	"CHN"|Exp_cou ==	"WLD"	) &(Imp_cou	==	"ARE"	|Imp_cou	==	"ARG"	|Imp_cou	==	"AUS"	|Imp_cou	==	"BEL"	|Imp_cou	==	"BGD"	|Imp_cou	==	"BRA"	|Imp_cou	==	"BRN"	|Imp_cou	==	"CAN"	|Imp_cou	==	"CHL"	|Imp_cou	==	"CZE"	|Imp_cou	==	"DEU"	|Imp_cou	==	"EGY"	|Imp_cou	==	"ESP"	|Imp_cou	==	"FRA"	|Imp_cou	==	"GBR"	|Imp_cou	==	"HKG"	|Imp_cou	==	"IDN"	|Imp_cou	==	"IND"	|Imp_cou	==	"IRN"	|Imp_cou	==	"ISR"	|Imp_cou	==	"ITA"	|Imp_cou	==	"JPN"	|Imp_cou	==	"KAZ"	|Imp_cou	==	"KHM"	|Imp_cou	==	"KOR"	|Imp_cou	==	"LAO"	|Imp_cou	==	"MEX"	|Imp_cou	==	"MMR"	|Imp_cou	==	"MYS"	|Imp_cou	==	"NGA"	|Imp_cou	==	"NLD"	|Imp_cou	==	"NZL"	|Imp_cou	==	"PAK"	|Imp_cou	==	"PAN"	|Imp_cou	==	"PHL"	|Imp_cou	==	"POL"	|Imp_cou	==	"RUS"	|Imp_cou	==	"SAU"	|Imp_cou	==	"SGP"	|Imp_cou	==	"SWE"	|Imp_cou	==	"THA"	|Imp_cou	==	"TUR"	|Imp_cou	==	"TWN"	|Imp_cou	==	"USA"	|Imp_cou	==	"VNM"	|Imp_cou	==	"ZAF"	|Imp_cou	==	"CHN"|Imp_cou ==	"WLD"	)
keep if main_country == 1
gen RCEP=0 
replace RCEP=1 if (Imp_cou == "JPN"|Imp_cou == "KOR"|Imp_cou == "AUS"|Imp_cou == "NZL"|Imp_cou == "BRN"|Imp_cou == "KHM"|Imp_cou == "IDN"|Imp_cou == "LAO"|Imp_cou == "MYS"|Imp_cou == "PHL"|Imp_cou == "SGP"| Imp_cou == "MMR"|Imp_cou == "THA"|Imp_cou == "VNM"|Imp_cou	==	"CHN") & (Exp_cou == "JPN"|Exp_cou == "KOR"|Exp_cou == "AUS"|Exp_cou == "NZL"|Exp_cou == "BRN"|Exp_cou == "KHM"|Exp_cou == "IDN"|Exp_cou == "LAO"|Exp_cou == "MYS"|Exp_cou == "PHL"|Exp_cou == "SGP"| Exp_cou == "MMR"|Exp_cou == "THA"|Exp_cou == "VNM"|Exp_cou == "CHN")
replace RCEP =0 if Imp_cou == Exp_cou
egen match = group(Year Exp_cou Exp_ind)
save "D:\RCEP\data\sector_processed_data\GrossExport_FD.dta",replace  //
//merge Export_FD and Prod_FD
use "D:\RCEP\data\sector_processed_data\GrossExport_FD.dta",clear
merge m:1 match using "D:\RCEP\data\sector_processed_data\Prod_FD.dta"
drop _merge match main_country Prod_cou Prod_ind 
//generate intranational trade
generate xii = FD_prod - export_fnl
replace xii = 0 if Imp_cou != "WLD"
drop if Imp_cou == Exp_cou
replace Imp_cou = Exp_cou if Imp_cou == "WLD"
replace export = xii if Exp_cou == Imp_cou
sort Year Exp_cou Exp_ind Imp_cou
replace export = . if export<0
drop xii 
egen match2= group( Year Exp_cou Imp_cou)
save "D:\RCEP\data\sector_processed_data\TivaExport_FD.dta",replace
//merge Export_Prod_FD and cepii
use "D:\RCEP\data\sector_processed_data\TivaExport_FD.dta",clear
merge m:1 match2 using "D:\RCEP\data\sector_processed_data\cepii_merge.dta"
drop _merge year exporter importer match2
order RCEP, after (RTA)
save "D:\RCEP\data\sector_processed_data\export_FD_latest.dta",replace


*********************gen country dataset code*****************
use "D:\RCEP Research\data\gravity_raw_data\Gravity_dta_V202102\Countries_V202102.dta",clear
gen main_country=0
replace main_country =  1 if (iso3	==	"ARG"	|iso3	==	"AUS"	|iso3	==	"BEL"	|iso3	==	"BRA"	|iso3	==	"BRN"	|iso3	==	"CAN"	|iso3	==	"CHL"	|iso3	==	"CZE"	|iso3	==	"DEU"	|iso3	==	"ESP"	|iso3	==	"FRA"	|iso3	==	"GBR"	|iso3	==	"HKG"	|iso3	==	"IDN"	|iso3	==	"IND"	|iso3	==	"ISR"	|iso3	==	"ITA"	|iso3	==	"JPN"	|iso3	==	"KAZ"	|iso3	==	"KHM"	|iso3	==	"KOR"	|iso3	==	"LAO"	|iso3	==	"MEX"	|iso3	==	"MMR"	|iso3	==	"MYS"	|iso3	==	"NLD"	|iso3	==	"NZL"	|iso3	==	"PHL"	|iso3	==	"POL"	|iso3	==	"RUS"	|iso3	==	"SAU"	|iso3	==	"SGP"	|iso3	==	"SWE"	|iso3	==	"THA"	|iso3	==	"TUR"	|iso3	==	"TWN"	|iso3	==	"USA"	|iso3	==	"VNM"	|iso3	==	"ZAF"	|iso3	==	"CHN"|iso3 ==	"WLD"	)
keep if main_country == 1
gen RCEP=0 
replace RCEP=1 if iso3 == "JPN"|iso3 == "KOR"|iso3 == "AUS"|iso3 == "NZL"|iso3 == "BRN"|iso3 == "KHM"|iso3 == "IDN"|iso3 == "LAO"|iso3 == "MYS"|iso3 == "PHL"|iso3 == "SGP"| iso3 == "MMR"|iso3 == "THA"|iso3 == "VNM"|iso3 == "CHN"
keep iso3 country RCEP
sort iso3
save "D:\RCEP\data\sector_processed_data\CountryName",replace
export excel using "D:\RCEP\data\sector_output\CountryName.xls", firstrow(variables) replace

******* initial analysis*******
use "D:\RCEP Research\data\gravity_raw_data\TIVA\latest_year\EXGR.dta",clear
sort Year Exp_cou Exp_ind Imp_cou
keep if Exp_cou == "JPN"|Exp_cou == "KOR"|Exp_cou == "AUS"|Exp_cou == "NZL"|Exp_cou == "BRN"|Exp_cou == "KHM"|Exp_cou == "IDN"|Exp_cou == "LAO"|Exp_cou == "MYS"|Exp_cou == "PHL"|Exp_cou == "SGP"| Exp_cou == "MMR"|Exp_cou == "THA"|Exp_cou == "VNM"|Exp_cou	==	"CHN"
keep if Year ==2018
keep if Imp_cou == "WLD"
keep if Exp_ind == "DTOTAL"|Exp_ind == "D01T03"|Exp_ind == "D10T33"|Exp_ind == "D45T82"
drop Imp_cou EXGR
order Year, first
save "D:\RCEP\data\processed_data\sector_per.dta",replace
//ASEAN sector output
use "D:\RCEP\data\processed_data\sector_per.dta",clear
keep if Exp_cou == "BRN"|Exp_cou == "KHM"|Exp_cou == "IDN"|Exp_cou == "LAO"|Exp_cou == "MYS"|Exp_cou == "PHL"|Exp_cou == "SGP"| Exp_cou == "MMR"|Exp_cou == "THA"|Exp_cou == "VNM"
bysort Exp_ind: egen ASEAN_trade =sum(export)
drop export Exp_cou
duplicates drop
save "D:\RCEP\data\processed_data\sector_per_ASEAN.dta",replace


//INTL and FNL
use "D:\RCEP Research\data\gravity_raw_data\TIVA\latest_year\EXGR_INT.dta",clear
sort Year Exp_cou Exp_ind Imp_cou
keep if Exp_cou == "JPN"|Exp_cou == "KOR"|Exp_cou == "AUS"|Exp_cou == "NZL"|Exp_cou == "BRN"|Exp_cou == "KHM"|Exp_cou == "IDN"|Exp_cou == "LAO"|Exp_cou == "MYS"|Exp_cou == "PHL"|Exp_cou == "SGP"| Exp_cou == "MMR"|Exp_cou == "THA"|Exp_cou == "VNM"|Exp_cou	==	"CHN"
keep if Year ==2018
keep if Imp_cou == "WLD"
keep if Exp_ind == "DTOTAL"
drop Imp_cou EXGR
order Year, first
save "D:\RCEP\data\processed_data\INTL_per.dta",replace
//ASEAN
use "D:\RCEP\data\processed_data\INTL_per.dta",clear
keep if Exp_cou == "BRN"|Exp_cou == "KHM"|Exp_cou == "IDN"|Exp_cou == "LAO"|Exp_cou == "MYS"|Exp_cou == "PHL"|Exp_cou == "SGP"| Exp_cou == "MMR"|Exp_cou == "THA"|Exp_cou == "VNM"
bysort Exp_ind: egen ASEAN_trade =sum(export)
drop export Exp_cou
duplicates drop
//sum_export
use "D:\RCEP Research\data\gravity_raw_data\TIVA\latest_year\EXGR.dta",clear
sort Year Exp_cou Exp_ind Imp_cou
keep if Exp_cou == "JPN"|Exp_cou == "KOR"|Exp_cou == "AUS"|Exp_cou == "NZL"|Exp_cou == "BRN"|Exp_cou == "KHM"|Exp_cou == "IDN"|Exp_cou == "LAO"|Exp_cou == "MYS"|Exp_cou == "PHL"|Exp_cou == "SGP"| Exp_cou == "MMR"|Exp_cou == "THA"|Exp_cou == "VNM"|Exp_cou	==	"CHN"
keep if Year ==2018
keep if Imp_cou == "WLD"
keep if Exp_ind == "DTOTAL"
save "D:\RCEP\data\processed_data\sum_RCEP_export.dta",replace
keep if Exp_cou == "BRN"|Exp_cou == "KHM"|Exp_cou == "IDN"|Exp_cou == "LAO"|Exp_cou == "MYS"|Exp_cou == "PHL"|Exp_cou == "SGP"| Exp_cou == "MMR"|Exp_cou == "THA"|Exp_cou == "VNM"
bysort Exp_ind: egen ASEAN_trade =sum(export)
drop export Exp_cou
duplicates drop

*********************gen CHN export dataset for graph*************************

use "D:\RCEP\data\sector_processed_data\export_latest.dta",clear
keep if Exp_cou == "CHN"
keep if RCEP==1
keep if Exp_ind == "DTOTAL"
rename Exp_cou iso3_o
rename Imp_cou iso3_d
rename export tradeflow_comtrade_o
rename Year year
keep year iso3_o iso3_d tradeflow_comtrade_o
save "D:\RCEP\data\processed_data\CHN_EXPORT.dta",replace
