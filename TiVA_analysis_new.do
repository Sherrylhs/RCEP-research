****************
* TiVA analysis *
*****************

* Clear memory and set parameters
	clear all
	set more off
	clear matrix
	set memory 500m
	set matsize 8000
	set maxvar 30000
	set type double, permanently

******************************************
*           1. baseline ppml             * 
******************************************
	
/*********1.1 total export*********/
use "D:\RCEP\data\sector_processed_data\export_latest.dta",clear
keep if Year==1995|Year==2000| Year==2005| Year==2010| Year==2015| Year==2018
keep if Exp_ind == "DTOTAL"
gen ln_distance=ln(dist)
bysort Exp_cou Year: egen Y = sum(export)
bysort Imp_cou Year: egen E = sum(export)
*description summary*
*table 1
sum contig comlang_off colony comcol comrelig ln_distance legal export RTA
outreg2 using "D:\RCEP\data\sector_output\summary_table1.xls", replace sum(log) keep(contig comlang_off colony comcol comrelig ln_distance legal export RTA) title(Decriptive statistics)
*table 2
correlate contig comlang_off colony comcol comrelig ln_distance legal export RTA
export excel using  "D:\RCEP\data\sector_output\summary_table2.xls", keepcellfmt replace

* Chose a country for reference group: GERMANY
		gen E_R_BLN = E if Imp_cou == "DEU"
			replace Exp_cou = "ZZZ" if Exp_cou == "DEU"
			replace Imp_cou = "ZZZ" if Imp_cou == "DEU"
		bysort Year: egen E_R = mean(E_R_BLN)
* Create pair_id
egen pair_id = group(Exp_cou Imp_cou)

* Create Exp_cou time fixed effects
		egen exp_time = group(Exp_cou Year)
		quietly tabulate exp_time, gen(EXPORTER_TIME_FE)

* Create Imp_cou time fixed effects
		egen imp_time = group(Imp_cou Year)
		quietly tabulate imp_time, gen(IMPORTER_TIME_FE)
* Rearrange so that country pairs, which will be dropped due to no export, are last	
		bysort pair_id: egen X = sum(export)
		quietly summarize pair_id
		replace pair_id = pair_id + r(max) + 1 if X == 0 | X == .
		drop X
* Rearrange so that the last country pair is the one for internal export
		quietly sum pair_id
		replace pair_id = r(max) + 1 if Exp_cou == Imp_cou
		quietly tabulate pair_id, gen(PAIR_FE)	

* Set additional exogenous parameters
		quietly ds EXPORTER_TIME_FE*
		global NT = `: word count `r(varlist)'' 
		
		quietly tabulate Year, gen(TIME_FE)		
		quietly ds TIME_FE*
		global Nyr = `: word count `r(varlist)''
		global NT_yr = $NT - $Nyr
		
		quietly ds PAIR_FE*
		global NTij = `: word count `r(varlist)'' 
		global NTij_1 = $NTij - 1
		global NTij_8 = $NTij - 8

* Save data
save "D:\RCEP\data\sector_processed_data\RTAImpacts_total.dta", replace

*table 3*
*ppml with CONTROL
use "D:\RCEP\data\sector_processed_data\RTAImpacts_total.dta", clear
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export RTA `CONTROL' if Exp_cou != Imp_cou, absorb(exp_time imp_time, savefe) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\baseline_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*ppml with pair_id
est clear
eststo: ppmlhdfe export RTA , absorb(exp_time imp_time pair_id) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\baseline_pairID.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*2018 estimation
keep if Year==2018
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export RTA `CONTROL' if Exp_cou != Imp_cou, absorb(Exp_cou Imp_cou, savefe) noconst d
esttab using "D:\RCEP\data\sector_output\2018_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 	
save "D:\RCEP\data\sector_processed_data\2018.dta",replace

/*********1.2 Agriculture*********/
use "D:\RCEP\data\sector_processed_data\export_latest.dta",clear
keep if Year==1995|Year==2000| Year==2005| Year==2010| Year==2015| Year==2018
keep if Exp_ind == "D01T03"
gen ln_distance=ln(dist)
bysort Exp_cou Year: egen Y = sum(export)
bysort Imp_cou Year: egen E = sum(export)
* Chose a country for reference group: GERMANY
		gen E_R_BLN = E if Imp_cou == "DEU"
			replace Exp_cou = "ZZZ" if Exp_cou == "DEU"
			replace Imp_cou = "ZZZ" if Imp_cou == "DEU"
		bysort Year: egen E_R = mean(E_R_BLN)
* Create pair_id
egen pair_id = group(Exp_cou Imp_cou)

* Create Exp_cou time fixed effects
		egen exp_time = group(Exp_cou Year)
		quietly tabulate exp_time, gen(EXPORTER_TIME_FE)

* Create Imp_cou time fixed effects
		egen imp_time = group(Imp_cou Year)
		quietly tabulate imp_time, gen(IMPORTER_TIME_FE)
* Rearrange so that country pairs, which will be dropped due to no export, are last	
		bysort pair_id: egen X = sum(export)
		quietly summarize pair_id
		replace pair_id = pair_id + r(max) + 1 if X == 0 | X == .
		drop X
* Rearrange so that the last country pair is the one for internal export
		quietly sum pair_id
		replace pair_id = r(max) + 1 if Exp_cou == Imp_cou
		quietly tabulate pair_id, gen(PAIR_FE)	

* Set additional exogenous parameters
		quietly ds EXPORTER_TIME_FE*
		global NT = `: word count `r(varlist)'' 
		
		quietly tabulate Year, gen(TIME_FE)		
		quietly ds TIME_FE*
		global Nyr = `: word count `r(varlist)''
		global NT_yr = $NT - $Nyr
		
		quietly ds PAIR_FE*
		global NTij = `: word count `r(varlist)'' 
		global NTij_1 = $NTij - 1
		global NTij_8 = $NTij - 8
* Save data
save "D:\RCEP\data\sector_processed_data\RTAImpacts_Agriculture.dta", replace

*table 4*
*ppml with CONTROL
use "D:\RCEP\data\sector_processed_data\RTAImpacts_Agriculture.dta", clear
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export RTA `CONTROL' if Exp_cou != Imp_cou, absorb(exp_time imp_time, savefe) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\Agriculture_baseline_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*ppml with pair_id
est clear
eststo: ppmlhdfe export RTA , absorb(exp_time imp_time pair_id) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\Agriculture_baseline_pairID.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*2018 estimation
keep if Year==2018
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export RTA `CONTROL' if Exp_cou != Imp_cou, absorb(Exp_cou Imp_cou, savefe) noconst d
esttab using "D:\RCEP\data\sector_output\Agriculture_2018_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 	
save "D:\RCEP\data\sector_processed_data\Agriculture_2018.dta",replace

/*********1.3 Manufacturing*********/
use "D:\RCEP\data\sector_processed_data\export_latest.dta",clear
keep if Year==1995|Year==2000| Year==2005| Year==2010| Year==2015| Year==2018
keep if Exp_ind == "D10T33"
gen ln_distance=ln(dist)
bysort Exp_cou Year: egen Y = sum(export)
bysort Imp_cou Year: egen E = sum(export)
* Chose a country for reference group: GERMANY
		gen E_R_BLN = E if Imp_cou == "DEU"
			replace Exp_cou = "ZZZ" if Exp_cou == "DEU"
			replace Imp_cou = "ZZZ" if Imp_cou == "DEU"
		bysort Year: egen E_R = mean(E_R_BLN)
* Create pair_id
egen pair_id = group(Exp_cou Imp_cou)

* Create Exp_cou time fixed effects
		egen exp_time = group(Exp_cou Year)
		quietly tabulate exp_time, gen(EXPORTER_TIME_FE)

* Create Imp_cou time fixed effects
		egen imp_time = group(Imp_cou Year)
		quietly tabulate imp_time, gen(IMPORTER_TIME_FE)
* Rearrange so that country pairs, which will be dropped due to no export, are last	
		bysort pair_id: egen X = sum(export)
		quietly summarize pair_id
		replace pair_id = pair_id + r(max) + 1 if X == 0 | X == .
		drop X
* Rearrange so that the last country pair is the one for internal export
		quietly sum pair_id
		replace pair_id = r(max) + 1 if Exp_cou == Imp_cou
		quietly tabulate pair_id, gen(PAIR_FE)	

* Set additional exogenous parameters
		quietly ds EXPORTER_TIME_FE*
		global NT = `: word count `r(varlist)'' 
		
		quietly tabulate Year, gen(TIME_FE)		
		quietly ds TIME_FE*
		global Nyr = `: word count `r(varlist)''
		global NT_yr = $NT - $Nyr
		
		quietly ds PAIR_FE*
		global NTij = `: word count `r(varlist)'' 
		global NTij_1 = $NTij - 1
		global NTij_8 = $NTij - 8
* Save data
save "D:\RCEP\data\sector_processed_data\RTAImpacts_Manufacturing.dta", replace

*table 4*
*ppml with CONTROL
use "D:\RCEP\data\sector_processed_data\RTAImpacts_Manufacturing.dta", clear
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export RTA `CONTROL' if Exp_cou != Imp_cou, absorb(exp_time imp_time, savefe) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\Manufacturing_baseline_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*ppml with pair_id
est clear
eststo: ppmlhdfe export RTA , absorb(exp_time imp_time pair_id) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\Manufacturing_baseline_pairID.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*2018 estimation
keep if Year==2018
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export RTA `CONTROL' if Exp_cou != Imp_cou, absorb(Exp_cou Imp_cou, savefe) noconst d
esttab using "D:\RCEP\data\sector_output\Manufacturing_2018_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 	
save "D:\RCEP\data\sector_processed_data\Manufacturing_2018.dta",replace

/*********1.4 Services*********/
use "D:\RCEP\data\sector_processed_data\export_latest.dta",clear
keep if Year==1995|Year==2000| Year==2005| Year==2010| Year==2015| Year==2018
keep if Exp_ind == "D45T82"
gen ln_distance=ln(dist)
bysort Exp_cou Year: egen Y = sum(export)
bysort Imp_cou Year: egen E = sum(export)
* Chose a country for reference group: GERMANY
		gen E_R_BLN = E if Imp_cou == "DEU"
			replace Exp_cou = "ZZZ" if Exp_cou == "DEU"
			replace Imp_cou = "ZZZ" if Imp_cou == "DEU"
		bysort Year: egen E_R = mean(E_R_BLN)
* Create pair_id
egen pair_id = group(Exp_cou Imp_cou)

* Create Exp_cou time fixed effects
		egen exp_time = group(Exp_cou Year)
		quietly tabulate exp_time, gen(EXPORTER_TIME_FE)

* Create Imp_cou time fixed effects
		egen imp_time = group(Imp_cou Year)
		quietly tabulate imp_time, gen(IMPORTER_TIME_FE)
* Rearrange so that country pairs, which will be dropped due to no export, are last	
		bysort pair_id: egen X = sum(export)
		quietly summarize pair_id
		replace pair_id = pair_id + r(max) + 1 if X == 0 | X == .
		drop X
* Rearrange so that the last country pair is the one for internal export
		quietly sum pair_id
		replace pair_id = r(max) + 1 if Exp_cou == Imp_cou
		quietly tabulate pair_id, gen(PAIR_FE)	

* Set additional exogenous parameters
		quietly ds EXPORTER_TIME_FE*
		global NT = `: word count `r(varlist)'' 
		
		quietly tabulate Year, gen(TIME_FE)		
		quietly ds TIME_FE*
		global Nyr = `: word count `r(varlist)''
		global NT_yr = $NT - $Nyr
		
		quietly ds PAIR_FE*
		global NTij = `: word count `r(varlist)'' 
		global NTij_1 = $NTij - 1
		global NTij_8 = $NTij - 8
* Save data
save "D:\RCEP\data\sector_processed_data\RTAImpacts_Service.dta", replace

*table 6*
*ppml with CONTROL
use "D:\RCEP\data\sector_processed_data\RTAImpacts_Service.dta", clear
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export RTA `CONTROL' if Exp_cou != Imp_cou, absorb(exp_time imp_time, savefe) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\Service_baseline_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*ppml with pair_id
est clear
eststo: ppmlhdfe export RTA , absorb(exp_time imp_time pair_id) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\Service_baseline_pairID.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*2018 estimation
keep if Year==2018
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export RTA `CONTROL' if Exp_cou != Imp_cou, absorb(Exp_cou Imp_cou, savefe) noconst d
esttab using "D:\RCEP\data\sector_output\Service_2018_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 	
save "D:\RCEP\data\sector_processed_data\Service_2018.dta",replace

/*********1.5 Intermediate*********/
use "D:\RCEP\data\sector_processed_data\export_INTL_latest.dta", clear
keep if Year==1995|Year==2000| Year==2005| Year==2010| Year==2015| Year==2018
keep if  Exp_ind == "DTOTAL"
gen ln_distance=ln(dist)
bysort Exp_cou Year: egen Y = sum(export)
bysort Imp_cou Year: egen E = sum(export)
* Chose a country for reference group: GERMANY
		gen E_R_BLN = E if Imp_cou == "DEU"
			replace Exp_cou = "ZZZ" if Exp_cou == "DEU"
			replace Imp_cou = "ZZZ" if Imp_cou == "DEU"
		bysort Year: egen E_R = mean(E_R_BLN)
* Create pair_id
egen pair_id = group(Exp_cou Imp_cou)

* Create Exp_cou time fixed effects
		egen exp_time = group(Exp_cou Year)
		quietly tabulate exp_time, gen(EXPORTER_TIME_FE)

* Create Imp_cou time fixed effects
		egen imp_time = group(Imp_cou Year)
		quietly tabulate imp_time, gen(IMPORTER_TIME_FE)
* Rearrange so that country pairs, which will be dropped due to no export, are last	
		bysort pair_id: egen X = sum(export)
		quietly summarize pair_id
		replace pair_id = pair_id + r(max) + 1 if X == 0 | X == .
		drop X
* Rearrange so that the last country pair is the one for internal export
		quietly sum pair_id
		replace pair_id = r(max) + 1 if Exp_cou == Imp_cou
		quietly tabulate pair_id, gen(PAIR_FE)	

* Set additional exogenous parameters
		quietly ds EXPORTER_TIME_FE*
		global NT = `: word count `r(varlist)'' 
		
		quietly tabulate Year, gen(TIME_FE)		
		quietly ds TIME_FE*
		global Nyr = `: word count `r(varlist)''
		global NT_yr = $NT - $Nyr
		
		quietly ds PAIR_FE*
		global NTij = `: word count `r(varlist)'' 
		global NTij_1 = $NTij - 1
		global NTij_8 = $NTij - 8

* Save data
save "D:\RCEP\data\sector_processed_data\RTAImpacts_INTL.dta", replace

*table 7*
*ppml with CONTROL
use "D:\RCEP\data\sector_processed_data\RTAImpacts_INTL.dta", clear
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export RTA `CONTROL' if Exp_cou != Imp_cou, absorb(exp_time imp_time, savefe) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\INTL_baseline_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*ppml with pair_id
est clear
eststo: ppmlhdfe export RTA , absorb(exp_time imp_time pair_id) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\INTL_baseline_pairID.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*2018 estimation
keep if Year==2018
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export RTA `CONTROL' if Exp_cou != Imp_cou, absorb(Exp_cou Imp_cou, savefe) noconst d
esttab using "D:\RCEP\data\sector_output\INTL_2018_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 	
save "D:\RCEP\data\sector_processed_data\INTL_2018.dta",replace

/*********1.6 FD*********/
use "D:\RCEP\data\sector_processed_data\export_FD_latest.dta", clear
keep if Year==1995|Year==2000| Year==2005| Year==2010| Year==2015| Year==2018
keep if  Exp_ind == "DTOTAL"
gen ln_distance=ln(dist)
bysort Exp_cou Year: egen Y = sum(export)
bysort Imp_cou Year: egen E = sum(export)
* Chose a country for reference group: GERMANY
		gen E_R_BLN = E if Imp_cou == "DEU"
			replace Exp_cou = "ZZZ" if Exp_cou == "DEU"
			replace Imp_cou = "ZZZ" if Imp_cou == "DEU"
		bysort Year: egen E_R = mean(E_R_BLN)
* Create pair_id
egen pair_id = group(Exp_cou Imp_cou)

* Create Exp_cou time fixed effects
		egen exp_time = group(Exp_cou Year)
		quietly tabulate exp_time, gen(EXPORTER_TIME_FE)

* Create Imp_cou time fixed effects
		egen imp_time = group(Imp_cou Year)
		quietly tabulate imp_time, gen(IMPORTER_TIME_FE)
* Rearrange so that country pairs, which will be dropped due to no export, are last	
		bysort pair_id: egen X = sum(export)
		quietly summarize pair_id
		replace pair_id = pair_id + r(max) + 1 if X == 0 | X == .
		drop X
* Rearrange so that the last country pair is the one for internal export
		quietly sum pair_id
		replace pair_id = r(max) + 1 if Exp_cou == Imp_cou
		quietly tabulate pair_id, gen(PAIR_FE)	

* Set additional exogenous parameters
		quietly ds EXPORTER_TIME_FE*
		global NT = `: word count `r(varlist)'' 
		
		quietly tabulate Year, gen(TIME_FE)		
		quietly ds TIME_FE*
		global Nyr = `: word count `r(varlist)''
		global NT_yr = $NT - $Nyr
		
		quietly ds PAIR_FE*
		global NTij = `: word count `r(varlist)'' 
		global NTij_1 = $NTij - 1
		global NTij_8 = $NTij - 8

* Save data
save "D:\RCEP\data\sector_processed_data\RTAImpacts_FD.dta", replace

*table 7*
*ppml with CONTROL
use "D:\RCEP\data\sector_processed_data\RTAImpacts_FD.dta", clear
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export RTA `CONTROL' if Exp_cou != Imp_cou, absorb(exp_time imp_time, savefe) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\FD_baseline_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*ppml with pair_id
est clear
eststo: ppmlhdfe export RTA , absorb(exp_time imp_time pair_id) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\FD_baseline_pairID.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*2018 estimation
keep if Year==2018
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export RTA `CONTROL' if Exp_cou != Imp_cou, absorb(Exp_cou Imp_cou, savefe) noconst d
esttab using "D:\RCEP\data\sector_output\FD_2018_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 	
save "D:\RCEP\data\sector_processed_data\FD_2018.dta",replace


******************************
* 2  Counterfactual steps    *
******************************


/*********2.1 total export*********/

****************************** PART (i) *****************************
use "D:\RCEP\data\sector_processed_data\RTAImpacts_total.dta",clear
rename Exp_cou exporter
rename Imp_cou importer
rename Year year
rename export trade
  
* Estimate the gravity model 
		ppml trade PAIR_FE1-PAIR_FE$NTij_1 EXPORTER_TIME_FE* IMPORTER_TIME_FE1-IMPORTER_TIME_FE$NT_yr RTA , iter(35) noconst
* Save the estimation results 
			estimate store gravity_panel

***************************** PART (ii) *****************************
************************* GENERAL EQUILIBRIUM ANALYSIS *************************
* Step I: Solve the baseline gravity model
* Step I.a. Obtain estimates of trade costs and trade elasticities baseline indexes
                * Stage 1: Obtain the estimates of pair fixed effects and the effects of RTAs
* Alternatively recall the results of the gravity model obtained above 
				estimate restore gravity_panel
				scalar RTA_est = _b[RTA]	
* Construct the trade costs from the pair fixed effects
					forvalues ijt = 1(1)$NTij_8{
						 cap qui replace PAIR_FE`ijt' = PAIR_FE`ijt' * _b[PAIR_FE`ijt']
					}	
					egen gamma_ij = rowtotal(PAIR_FE1-PAIR_FE$NTij )
						replace gamma_ij = . if gamma_ij == 1 & exporter != importer
						replace gamma_ij = 0 if gamma_ij == 1 & exporter == importer
					generate tij_bar = exp(gamma_ij)
					generate tij_bln = exp(gamma_ij + RTA_est*RTA)
                 
				 * Stage 2: Regress the estimates of pair fixed effects on gravity variables and country fixed effects
* Perform the regression for the baseline year
					keep if year == 2018
* Specify the dependent variable as the estimates of pair fixed effects
					generate tij = exp(gamma_ij)
* Create the exporters and importers fixed effects	
					quietly tabulate exporter, gen(EXPORTER_FE)
					quietly tabulate importer, gen(IMPORTER_FE)
* Estimate the standard gravity model 
				ppmlhdfe tij ln_distance contig comlang_off colony comcol comrelig legal if exporter != importer, absorb(exp_time imp_time, savefe) cluster(pair_id) d
					estimates store gravity_est
					
				* Create the predicted values 	
					predict tij_noRTA, mu
						replace tij_noRTA = 1 if exporter == importer
* Replace the missing trade costs with predictions from the
				* standard gravity regression
					replace tij_bar = tij_noRTA if tij_bar == . 
					replace tij_bln = tij_bar * exp(RTA_est*RTA) if tij_bln == .	
				    generate ln_tij_bln = log(tij_bln)	
* Set the number of exporter fixed effects variables
		quietly ds EXPORTER_FE*
		global N = `: word count `r(varlist)'' 
		global N_1 = $N - 1	
	
		* Estimate the gravity model in the "baseline" scenario 
		ppml trade EXPORTER_FE* IMPORTER_FE1-IMPORTER_FE$N_1 , noconst offset(ln_tij_bln) iter(30)
			predict tradehat_BLN, mu


* Step I.b. Construct baseline indexes	
		* Based on the estimated exporter and importer fixed effects, create
		* the actual set of fixed effects
			forvalues i = 1 (1) $N_1 {
				quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
				quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
			}
			
		* Create the exporter and importer fixed effects for the country of 
		* reference (Germany)
			quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
			quietly replace IMPORTER_FE$N = IMPORTER_FE$N * exp(0)
			
		* Create the variables stacking all the non-zero exporter and importer 
		* fixed effects, respectively		
			egen exp_pi_BLN = rowtotal(EXPORTER_FE1-EXPORTER_FE$N )
			egen exp_chi_BLN = rowtotal(IMPORTER_FE1-IMPORTER_FE$N ) 

		* Compute the variable of bilateral trade costs, i.e. the fitted trade
		* value by omitting the exporter and importer fixed effects		
			generate tij_BLN = tij_bln			

		* Compute the outward and inward multilateral resistances using the 
		* additive property of the PPML estimator that links the exporter and  
		* importer fixed effects with their respective multilateral resistances
		* taking into account the normalisation imposed
			generate OMR_BLN = Y * E_R / exp_pi_BLN
			generate IMR_BLN = E / (exp_chi_BLN * E_R)	
			
		* Compute the estimated level of international trade in the baseline for
		* the given level of ouptput and expenditures			
			generate tempXi_BLN = tradehat_BLN if exporter != importer
				bysort exporter: egen Xi_BLN = sum(tempXi_BLN)
					drop tempXi_BLN
			generate Y_BLN = Y
			generate E_BLN = E

* Step II: Define a conterfactual scenario
generate RTA_CFL = RTA
 replace RTA_CFL = 1 if RCEP == 1
generate tij_CFL = tij_bar * exp(RTA_est  * RTA_CFL) 
generate ln_tij_CFL = log(tij_CFL)
* Re-create the exporters and imports fixed effects
				drop EXPORTER_FE* IMPORTER_FE*
			quietly tabulate exporter, generate(EXPORTER_FE)
			quietly tabulate importer, generate(IMPORTER_FE)

		* Estimate the constrained gravity model and generate predicted trade
		* value
		ppml trade EXPORTER_FE* IMPORTER_FE1-IMPORTER_FE$N_1 ,noconst offset(ln_tij_CFL) iter(40)
			predict tradehat_CDL, mu
        
		* (ii):	Construct conditional general equilibrium multilateral resistances
	
		* Based on the estimated exporter and importer fixed effects, create
		* the actual set of counterfactual fixed effects	
			forvalues i = 1(1)$N_1 {
				quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
				quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
			}
		
		* Create the exporter and importer fixed effects for the country of 
		* reference (Germany)
			quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
			quietly replace IMPORTER_FE$N = IMPORTER_FE$N * exp(0)
			
		* Create the variables stacking all the non-zero exporter and importer 
		* fixed effects, respectively		
			egen exp_pi_CDL = rowtotal( EXPORTER_FE1-EXPORTER_FE$N )
			egen exp_chi_CDL = rowtotal( IMPORTER_FE1-IMPORTER_FE$N )
			
		* Compute the outward and inward multilateral resistances 				
			generate OMR_CDL = Y * E_R / exp_pi_CDL
			generate IMR_CDL = E / (exp_chi_CDL * E_R)
			
		* Compute the estimated level of conditional general equilibrium 
		* international trade for the given level of ouptput and expenditures		
			generate tempXi_CDL = tradehat_CDL if exporter != importer
				bysort exporter: egen Xi_CDL = sum(tempXi_CDL)
					drop tempXi_CDL
					
					* Step III.b: Obtain full endowment general equilibrium effects
* The constant elasticity of substitutin is taken from the literature


   drop EXPORTER_FE* IMPORTER_FE*
			quietly tabulate exporter, generate(EXPORTER_FE)
			quietly tabulate importer, generate(IMPORTER_FE)
     quietly ds EXPORTER_FE*
		global N = `: word count `r(varlist)'' 
		global N_1 = $N - 1	
		
			scalar sigma = 7
			
			* The parameter phi links the value of output with expenditures
			bysort year: generate phi = E/Y if exporter == importer
			
			* Compute the change in bilateral trade costs resulting from the 
			* counterfactual
			generate change_tij = tij_CFL / tij_BLN	

			* Re-specify the variables in the baseline and conditional scenarios
				* output 
				generate Y_0 = Y
				generate Y_1 = Y
				
				* Expenditures, including with respect to the reference country   
				generate E_0 = E
				generate E_R_0 = E_R
				generate E_1 = E
				generate E_R_1 = E_R			
			
				* Predicted level of trade 
				generate tradehat_1 = tradehat_CDL

        * (i)	Allow for endogenous factory-gate prices
	
			* Re-specify the factory-gate prices under the baseline and 
			* conditional scenarios				
			generate exp_pi_0 = exp_pi_BLN
			generate tempexp_pi_ii_0 = exp_pi_0 if exporter == importer
				bysort importer: egen exp_pi_j_0 = mean(tempexp_pi_ii_0)
			generate exp_pi_1 = exp_pi_CDL
			generate tempexp_pi_ii_1 = exp_pi_1 if exporter == importer
				bysort importer: egen exp_pi_j_1 = mean(tempexp_pi_ii_1)
				drop tempexp_pi_ii_*
			generate exp_chi_0 = exp_chi_BLN	
			generate exp_chi_1 = exp_chi_CDL	
			
			* Compute the first order change in factory-gate prices	in the 
			* baseline and conditional scenarios
			generate change_pricei_0 = 0				
			generate change_pricei_1 = ((exp_pi_1 / exp_pi_0) / (E_R_1 / E_R_0))^(1/(1-sigma))
			generate change_pricej_1 = ((exp_pi_j_1 / exp_pi_j_0) / (E_R_1 / E_R_0))^(1/(1-sigma))
		
			* Re-specify the outward and inward multilateral resistances in the
			* baseline and conditional scenarios
			generate OMR_FULL_0 = Y_0 * E_R_0 / exp_pi_0
			generate IMR_FULL_0 = E_0 / (exp_chi_0 * E_R_0)		
			generate IMR_FULL_1 = E_1 / (exp_chi_1 * E_R_1)
			generate OMR_FULL_1 = Y_1 * E_R_1 / exp_pi_1
			
		* Compute initial change in outward and multilateral resitances, which 
		* are set to zero		
			generate change_IMR_FULL_1 = exp(0)		
			generate change_OMR_FULL_1 = exp(0)
save "D:\RCEP\data\sector_processed_data\before_iter_total.dta", replace

****************************************************************************
	******************** Start of the Iterative Procedure  *********************
	* Set the criteria of convergence, namely that either the standard errors or
	* maximum of the difference between two iterations of the factory-gate 
	* prices are smaller than 0.01, where s is the number of iterations	
	
use  "D:\RCEP\data\sector_processed_data\before_iter_total.dta", clear
		local s = 3	
		local sd_dif_change_pi = 1
		local max_dif_change_pi = 1
	  while (`sd_dif_change_pi' > 0.01) | (`max_dif_change_pi' > 0.01) {
		local s_1 = `s' - 1
		local s_2 = `s' - 2
		local s_3 = `s' - 3
* (ii)	Allow for endogenous income, expenditures and trade	
		*	generate trade_`s_1' = change_tij * tradehat_`s_2' * change_pricei_`s_2' * change_pricej_`s_2' / (change_OMR_FULL_`s_2'*change_IMR_FULL_`s_2')
			generate trade_`s_1' =  tradehat_`s_2' * change_pricei_`s_2' * change_pricej_`s_2' / (change_OMR_FULL_`s_2'*change_IMR_FULL_`s_2')

			
		* (iii)	Estimation of the structural gravity model
				drop EXPORTER_FE* IMPORTER_FE*
				quietly tabulate exporter, generate (EXPORTER_FE)
				quietly tabulate importer, generate (IMPORTER_FE)
			   capture glm trade_`s_1' EXPORTER_FE* IMPORTER_FE*, offset(ln_tij_CFL) family(poisson) noconst irls iter(30)
				predict tradehat_`s_1', mu
					
			* Update output & expenditure			
				bysort exporter: egen Y_`s_1' = total(tradehat_`s_1')
				quietly generate tempE_`s_1' = phi * Y_`s_1' if exporter == importer
					bysort importer: egen E_`s_1' = mean(tempE_`s_1')
				quietly generate tempE_R_`s_1' = E_`s_1' if importer == "ZZZ"
					egen E_R_`s_1' = mean(tempE_R_`s_1')
				
			* Update factory-gate prices 
				forvalues i = 1(1)$N_1 {
				 quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
					 quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
				}
				 quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
				egen exp_pi_`s_1' = rowtotal(EXPORTER_FE1-EXPORTER_FE$N ) 
				quietly generate tempvar1 = exp_pi_`s_1' if exporter == importer
					bysort importer: egen exp_pi_j_`s_1' = mean(tempvar1) 		
					
			* Update multilateral resistances
				generate change_pricei_`s_1' = ((exp_pi_`s_1' / exp_pi_`s_2') / (E_R_`s_1' / E_R_`s_2'))^(1/(1-sigma))
				generate change_pricej_`s_1' = ((exp_pi_j_`s_1' / exp_pi_j_`s_2') / (E_R_`s_1' / E_R_`s_2'))^(1/(1-sigma))
				generate OMR_FULL_`s_1' = (Y_`s_1' * E_R_`s_1') / exp_pi_`s_1' 
					generate change_OMR_FULL_`s_1' = OMR_FULL_`s_1' / OMR_FULL_`s_2'					
				egen exp_chi_`s_1' = rowtotal(IMPORTER_FE1-IMPORTER_FE$N )	
				generate IMR_FULL_`s_1' = E_`s_1' / (exp_chi_`s_1' * E_R_`s_1')
					generate change_IMR_FULL_`s_1' = IMR_FULL_`s_1' / IMR_FULL_`s_2'
				
			* Iteration until the change in factory-gate prices converges to zero
				generate dif_change_pi_`s_1' = change_pricei_`s_2' - change_pricei_`s_3'
					display "************************* iteration number " `s_2' " *************************"
						summarize dif_change_pi_`s_1', format
					display "**********************************************************************"
					display " "
						local sd_dif_change_pi = r(sd)
						local max_dif_change_pi = abs(r(max))	
						
			local s = `s' + 1
			drop temp* 
	}
	

	********************* End of the Iterative Procedure  **********************
	****************************************************************************
		
		* (iv)	Construction of the "full endowment general equilibrium" 
		*		effects indexes
			* Use the result of the latest iteration S
			local S = `s' - 2
		*	forvalues i = 1 (1) $N_1 {
		*		quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
		*	}		
		* Compute the full endowment general equilibrium of factory-gate price
			generate change_pricei_FULL = ((exp_pi_`S' / exp_pi_0) / (E_R_`S' / E_R_0))^(1/(1-sigma))		

		* Compute the full endowment general equilibrium of the value output
			generate Y_FULL = change_pricei_FULL  * Y_BLN

		* Compute the full endowment general equilibrium of the value of 
		* aggregate expenditures
			generate tempE_FULL = phi * Y_FULL if exporter == importer
				bysort importer: egen E_FULL = mean(tempE_FULL)
					drop tempE_FULL
			
		* Compute the full endowment general equilibrium of the outward and 
		* inward multilateral resistances 
			generate OMR_FULL = Y_FULL * E_R_`S' / exp_pi_`S'
			generate IMR_FULL = E_`S' / (exp_chi_`S' * E_R_`S')	

		* Compute the full endowment general equilibrium of the value of 
		* bilateral trade 
			generate X_FULL = (Y_FULL * E_FULL * tij_CFL) /(IMR_FULL * OMR_FULL)			
		
		* Compute the full endowment general equilibrium of the value of 
		* total international trade 
			generate tempXi_FULL = X_FULL if exporter != importer
				bysort exporter: egen Xi_FULL = sum(tempXi_FULL)
					drop tempXi_FULL
					
	* Save the conditional and general equilibrium effects results		
	save "D:\RCEP\data\sector_processed_data\FULLGE_total.dta", replace


* Step IV: Collect, construct, and report indexes of interest
	use "D:\RCEP\data\sector_processed_data\FULLGE_total.dta", clear
		collapse(mean) OMR_FULL OMR_CDL OMR_BLN change_pricei_FULL Xi_* Y_BLN Y_FULL, by(exporter)
			rename exporter country
			replace country = "DEU" if country == "ZZZ"
			sort country
		
		* Percent change in full endowment general equilibrium of factory-gate prices
			generate change_price_FULL = (1 - change_pricei_FULL) / 1 * 100
			
		* Percent change in full endowment general equilibirum of outward multilateral resistances
			generate change_OMR_CDL = (OMR_CDL^(1/(1-sigma)) - OMR_BLN^(1/(1-sigma))) / OMR_BLN^(1/(1-sigma)) * 100
		
		* Percent change in full endowment general equilibrium of outward multilateral resistances			
			generate change_OMR_FULL = (OMR_FULL^(1/(1-sigma)) - OMR_BLN^(1/(1-sigma))) / OMR_BLN^(1/(1-sigma)) * 100

		* Percent change in conditional general equilibrium of bilateral trade
			generate change_Xi_CDL = (Xi_CDL - Xi_BLN) / Xi_BLN * 100	
			
		* Percent change in full endowment general equilibrium of bilateral trade		
			generate change_Xi_FULL = (Xi_FULL - Xi_BLN) / Xi_BLN * 100
	save "D:\RCEP\data\sector_processed_data\FULL_PROD_total.dta", replace


	* Construct the percentage changes on import/consumption side
	use "D:\RCEP\data\sector_processed_data\FULLGE_total.dta", clear
		collapse(mean) IMR_FULL IMR_CDL IMR_BLN, by(importer)
			rename importer country
			replace country = "DEU" if country == "ZZZ"
			sort country		

		* Conditional general equilibrium of inward multilateral resistances
			generate change_IMR_CDL = (IMR_CDL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
			
		* Full endowment general equilibrium of inward multilateral resistances
			generate change_IMR_FULL = (IMR_FULL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
	save "D:\RCEP\data\sector_processed_data\FULL_CONS_total.dta", replace

	* Merge the general equilibrium results from the production and consumption
	* sides
	use "D:\RCEP\data\sector_processed_data\FULL_PROD_total.dta", clear
		joinby country using "D:\RCEP\data\sector_processed_data\FULL_CONS_total.dta"
		
		* Full endowment general equilibrium of real GDP
			generate rGDP_BLN = Y_BLN / (IMR_BLN ^(1 / (1 -sigma)))
			generate rGDP_FULL = Y_FULL / (IMR_FULL ^(1 / (1 -sigma)))
				generate change_rGDP_FULL = (rGDP_FULL - rGDP_BLN) / rGDP_BLN * 100

		* Keep indexes of interest	
			keep country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
			order country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
				
	* Export the results in Excel
	//total result
	save "D:\RCEP\data\sector_processed_data\FULL_result_total.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_total.xls", firstrow(variables) keepcellfmt replace
	//RCEP country result
	use  "D:\RCEP\data\sector_processed_data\FULL_result_total.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP == 1
	rename iso3_d country
	save "D:\RCEP\data\sector_processed_data\FULL_RCEP_total.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_RCEP_total.xls", firstrow(variables) keepcellfmt replace
	//NO RCEP country result
	use  "D:\RCEP\data\sector_processed_data\FULL_result_total.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP!=1
	rename iso3_d country 
	save "D:\RCEP\data\sector_processed_data\FULL_NORCEP_total.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_NORCEP_total.xls", firstrow(variables) keepcellfmt replace
	

/*********2.2 Agriculture*********/

****************************** PART (i) *****************************
use "D:\RCEP\data\sector_processed_data\RTAImpacts_Agriculture.dta",clear
rename Exp_cou exporter
rename Imp_cou importer
rename Year year
rename export trade
  
* Estimate the gravity model 
		ppml trade PAIR_FE1-PAIR_FE$NTij_1 EXPORTER_TIME_FE* IMPORTER_TIME_FE1-IMPORTER_TIME_FE$NT_yr RTA , iter(35) noconst
* Save the estimation results 
			estimate store gravity_panel

***************************** PART (ii) *****************************
************************* GENERAL EQUILIBRIUM ANALYSIS *************************
* Step I: Solve the baseline gravity model
* Step I.a. Obtain estimates of trade costs and trade elasticities baseline indexes
                * Stage 1: Obtain the estimates of pair fixed effects and the effects of RTAs
* Alternatively recall the results of the gravity model obtained above 
				estimate restore gravity_panel
				scalar RTA_est = _b[RTA]	
* Construct the trade costs from the pair fixed effects
					forvalues ijt = 1(1)$NTij_8{
						 cap qui replace PAIR_FE`ijt' = PAIR_FE`ijt' * _b[PAIR_FE`ijt']
					}	
					egen gamma_ij = rowtotal(PAIR_FE1-PAIR_FE$NTij )
						replace gamma_ij = . if gamma_ij == 1 & exporter != importer
						replace gamma_ij = 0 if gamma_ij == 1 & exporter == importer
					generate tij_bar = exp(gamma_ij)
					generate tij_bln = exp(gamma_ij + RTA_est*RTA)
                 
				 * Stage 2: Regress the estimates of pair fixed effects on gravity variables and country fixed effects
* Perform the regression for the baseline year
					keep if year == 2018
* Specify the dependent variable as the estimates of pair fixed effects
					generate tij = exp(gamma_ij)
* Create the exporters and importers fixed effects	
					quietly tabulate exporter, gen(EXPORTER_FE)
					quietly tabulate importer, gen(IMPORTER_FE)
* Estimate the standard gravity model 
				ppmlhdfe tij ln_distance contig comlang_off colony comcol comrelig legal if exporter != importer, absorb(exp_time imp_time, savefe) cluster(pair_id) d
					estimates store gravity_est
					
				* Create the predicted values 	
					predict tij_noRTA, mu
						replace tij_noRTA = 1 if exporter == importer
* Replace the missing trade costs with predictions from the
				* standard gravity regression
					replace tij_bar = tij_noRTA if tij_bar == . 
					replace tij_bln = tij_bar * exp(RTA_est*RTA) if tij_bln == .	
				    generate ln_tij_bln = log(tij_bln)	
* Set the number of exporter fixed effects variables
		quietly ds EXPORTER_FE*
		global N = `: word count `r(varlist)'' 
		global N_1 = $N - 1	
	
		* Estimate the gravity model in the "baseline" scenario 
		ppml trade EXPORTER_FE* IMPORTER_FE1-IMPORTER_FE$N_1 , noconst offset(ln_tij_bln) iter(30)
			predict tradehat_BLN, mu


* Step I.b. Construct baseline indexes	
		* Based on the estimated exporter and importer fixed effects, create
		* the actual set of fixed effects
			forvalues i = 1 (1) $N_1 {
				quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
				quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
			}
			
		* Create the exporter and importer fixed effects for the country of 
		* reference (Germany)
			quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
			quietly replace IMPORTER_FE$N = IMPORTER_FE$N * exp(0)
			
		* Create the variables stacking all the non-zero exporter and importer 
		* fixed effects, respectively		
			egen exp_pi_BLN = rowtotal(EXPORTER_FE1-EXPORTER_FE$N )
			egen exp_chi_BLN = rowtotal(IMPORTER_FE1-IMPORTER_FE$N ) 

		* Compute the variable of bilateral trade costs, i.e. the fitted trade
		* value by omitting the exporter and importer fixed effects		
			generate tij_BLN = tij_bln			

		* Compute the outward and inward multilateral resistances using the 
		* additive property of the PPML estimator that links the exporter and  
		* importer fixed effects with their respective multilateral resistances
		* taking into account the normalisation imposed
			generate OMR_BLN = Y * E_R / exp_pi_BLN
			generate IMR_BLN = E / (exp_chi_BLN * E_R)	
			
		* Compute the estimated level of international trade in the baseline for
		* the given level of ouptput and expenditures			
			generate tempXi_BLN = tradehat_BLN if exporter != importer
				bysort exporter: egen Xi_BLN = sum(tempXi_BLN)
					drop tempXi_BLN
			generate Y_BLN = Y
			generate E_BLN = E

* Step II: Define a conterfactual scenario
generate RTA_CFL = RTA
 replace RTA_CFL = 1 if RCEP == 1
generate tij_CFL = tij_bar * exp(RTA_est  * RTA_CFL) 
generate ln_tij_CFL = log(tij_CFL)
* Re-create the exporters and imports fixed effects
				drop EXPORTER_FE* IMPORTER_FE*
			quietly tabulate exporter, generate(EXPORTER_FE)
			quietly tabulate importer, generate(IMPORTER_FE)

		* Estimate the constrained gravity model and generate predicted trade
		* value
		ppml trade EXPORTER_FE* IMPORTER_FE1-IMPORTER_FE$N_1 ,noconst offset(ln_tij_CFL) iter(40)
			predict tradehat_CDL, mu
        
		* (ii):	Construct conditional general equilibrium multilateral resistances
	
		* Based on the estimated exporter and importer fixed effects, create
		* the actual set of counterfactual fixed effects	
			forvalues i = 1(1)$N_1 {
				quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
				quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
			}
		
		* Create the exporter and importer fixed effects for the country of 
		* reference (Germany)
			quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
			quietly replace IMPORTER_FE$N = IMPORTER_FE$N * exp(0)
			
		* Create the variables stacking all the non-zero exporter and importer 
		* fixed effects, respectively		
			egen exp_pi_CDL = rowtotal( EXPORTER_FE1-EXPORTER_FE$N )
			egen exp_chi_CDL = rowtotal( IMPORTER_FE1-IMPORTER_FE$N )
			
		* Compute the outward and inward multilateral resistances 				
			generate OMR_CDL = Y * E_R / exp_pi_CDL
			generate IMR_CDL = E / (exp_chi_CDL * E_R)
			
		* Compute the estimated level of conditional general equilibrium 
		* international trade for the given level of ouptput and expenditures		
			generate tempXi_CDL = tradehat_CDL if exporter != importer
				bysort exporter: egen Xi_CDL = sum(tempXi_CDL)
					drop tempXi_CDL
					
					* Step III.b: Obtain full endowment general equilibrium effects
* The constant elasticity of substitutin is taken from the literature
*(ps:I have problem in full endowment GE PPML, the research result is still unachieved in this step )

   drop EXPORTER_FE* IMPORTER_FE*
			quietly tabulate exporter, generate(EXPORTER_FE)
			quietly tabulate importer, generate(IMPORTER_FE)
     quietly ds EXPORTER_FE*
		global N = `: word count `r(varlist)'' 
		global N_1 = $N - 1	
		
			scalar sigma = 7
			
			* The parameter phi links the value of output with expenditures
			bysort year: generate phi = E/Y if exporter == importer
			
			* Compute the change in bilateral trade costs resulting from the 
			* counterfactual
			generate change_tij = tij_CFL / tij_BLN	

			* Re-specify the variables in the baseline and conditional scenarios
				* output 
				generate Y_0 = Y
				generate Y_1 = Y
				
				* Expenditures, including with respect to the reference country   
				generate E_0 = E
				generate E_R_0 = E_R
				generate E_1 = E
				generate E_R_1 = E_R			
			
				* Predicted level of trade 
				generate tradehat_1 = tradehat_CDL

        * (i)	Allow for endogenous factory-gate prices
	
			* Re-specify the factory-gate prices under the baseline and 
			* conditional scenarios				
			generate exp_pi_0 = exp_pi_BLN
			generate tempexp_pi_ii_0 = exp_pi_0 if exporter == importer
				bysort importer: egen exp_pi_j_0 = mean(tempexp_pi_ii_0)
			generate exp_pi_1 = exp_pi_CDL
			generate tempexp_pi_ii_1 = exp_pi_1 if exporter == importer
				bysort importer: egen exp_pi_j_1 = mean(tempexp_pi_ii_1)
				drop tempexp_pi_ii_*
			generate exp_chi_0 = exp_chi_BLN	
			generate exp_chi_1 = exp_chi_CDL	
			
			* Compute the first order change in factory-gate prices	in the 
			* baseline and conditional scenarios
			generate change_pricei_0 = 0				
			generate change_pricei_1 = ((exp_pi_1 / exp_pi_0) / (E_R_1 / E_R_0))^(1/(1-sigma))
			generate change_pricej_1 = ((exp_pi_j_1 / exp_pi_j_0) / (E_R_1 / E_R_0))^(1/(1-sigma))
		
			* Re-specify the outward and inward multilateral resistances in the
			* baseline and conditional scenarios
			generate OMR_FULL_0 = Y_0 * E_R_0 / exp_pi_0
			generate IMR_FULL_0 = E_0 / (exp_chi_0 * E_R_0)		
			generate IMR_FULL_1 = E_1 / (exp_chi_1 * E_R_1)
			generate OMR_FULL_1 = Y_1 * E_R_1 / exp_pi_1
			
		* Compute initial change in outward and multilateral resitances, which 
		* are set to zero		
			generate change_IMR_FULL_1 = exp(0)		
			generate change_OMR_FULL_1 = exp(0)
save "D:\RCEP\data\sector_processed_data\before_iter_Agri.dta", replace

****************************************************************************
	******************** Start of the Iterative Procedure  *********************
	* Set the criteria of convergence, namely that either the standard errors or
	* maximum of the difference between two iterations of the factory-gate 
	* prices are smaller than 0.01, where s is the number of iterations	
	
use  "D:\RCEP\data\sector_processed_data\before_iter_Agri.dta", clear
		local s = 3	
		local sd_dif_change_pi = 1
		local max_dif_change_pi = 1
	  while (`sd_dif_change_pi' > 0.01) | (`max_dif_change_pi' > 0.01) {
		local s_1 = `s' - 1
		local s_2 = `s' - 2
		local s_3 = `s' - 3
* (ii)	Allow for endogenous income, expenditures and trade	
		*	generate trade_`s_1' = change_tij * tradehat_`s_2' * change_pricei_`s_2' * change_pricej_`s_2' / (change_OMR_FULL_`s_2'*change_IMR_FULL_`s_2')
			generate trade_`s_1' =  tradehat_`s_2' * change_pricei_`s_2' * change_pricej_`s_2' / (change_OMR_FULL_`s_2'*change_IMR_FULL_`s_2')

			
		* (iii)	Estimation of the structural gravity model
				drop EXPORTER_FE* IMPORTER_FE*
				quietly tabulate exporter, generate (EXPORTER_FE)
				quietly tabulate importer, generate (IMPORTER_FE)
			   capture glm trade_`s_1' EXPORTER_FE* IMPORTER_FE*, offset(ln_tij_CFL) family(poisson) noconst irls iter(30)
				predict tradehat_`s_1', mu
					
			* Update output & expenditure			
				bysort exporter: egen Y_`s_1' = total(tradehat_`s_1')
				quietly generate tempE_`s_1' = phi * Y_`s_1' if exporter == importer
					bysort importer: egen E_`s_1' = mean(tempE_`s_1')
				quietly generate tempE_R_`s_1' = E_`s_1' if importer == "ZZZ"
					egen E_R_`s_1' = mean(tempE_R_`s_1')
				
			* Update factory-gate prices 
				forvalues i = 1(1)$N_1 {
				 quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
					 quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
				}
				 quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
				egen exp_pi_`s_1' = rowtotal(EXPORTER_FE1-EXPORTER_FE$N ) 
				quietly generate tempvar1 = exp_pi_`s_1' if exporter == importer
					bysort importer: egen exp_pi_j_`s_1' = mean(tempvar1) 		
					
			* Update multilateral resistances
				generate change_pricei_`s_1' = ((exp_pi_`s_1' / exp_pi_`s_2') / (E_R_`s_1' / E_R_`s_2'))^(1/(1-sigma))
				generate change_pricej_`s_1' = ((exp_pi_j_`s_1' / exp_pi_j_`s_2') / (E_R_`s_1' / E_R_`s_2'))^(1/(1-sigma))
				generate OMR_FULL_`s_1' = (Y_`s_1' * E_R_`s_1') / exp_pi_`s_1' 
					generate change_OMR_FULL_`s_1' = OMR_FULL_`s_1' / OMR_FULL_`s_2'					
				egen exp_chi_`s_1' = rowtotal(IMPORTER_FE1-IMPORTER_FE$N )	
				generate IMR_FULL_`s_1' = E_`s_1' / (exp_chi_`s_1' * E_R_`s_1')
					generate change_IMR_FULL_`s_1' = IMR_FULL_`s_1' / IMR_FULL_`s_2'
				
			* Iteration until the change in factory-gate prices converges to zero
				generate dif_change_pi_`s_1' = change_pricei_`s_2' - change_pricei_`s_3'
					display "************************* iteration number " `s_2' " *************************"
						summarize dif_change_pi_`s_1', format
					display "**********************************************************************"
					display " "
						local sd_dif_change_pi = r(sd)
						local max_dif_change_pi = abs(r(max))	
						
			local s = `s' + 1
			drop temp* 
	}
	

	********************* End of the Iterative Procedure  **********************
	****************************************************************************
		
		* (iv)	Construction of the "full endowment general equilibrium" 
		*		effects indexes
			* Use the result of the latest iteration S
			local S = `s' - 2
		*	forvalues i = 1 (1) $N_1 {
		*		quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
		*	}		
		* Compute the full endowment general equilibrium of factory-gate price
			generate change_pricei_FULL = ((exp_pi_`S' / exp_pi_0) / (E_R_`S' / E_R_0))^(1/(1-sigma))		

		* Compute the full endowment general equilibrium of the value output
			generate Y_FULL = change_pricei_FULL  * Y_BLN

		* Compute the full endowment general equilibrium of the value of 
		* aggregate expenditures
			generate tempE_FULL = phi * Y_FULL if exporter == importer
				bysort importer: egen E_FULL = mean(tempE_FULL)
					drop tempE_FULL
			
		* Compute the full endowment general equilibrium of the outward and 
		* inward multilateral resistances 
			generate OMR_FULL = Y_FULL * E_R_`S' / exp_pi_`S'
			generate IMR_FULL = E_`S' / (exp_chi_`S' * E_R_`S')	

		* Compute the full endowment general equilibrium of the value of 
		* bilateral trade 
			generate X_FULL = (Y_FULL * E_FULL * tij_CFL) /(IMR_FULL * OMR_FULL)			
		
		* Compute the full endowment general equilibrium of the value of 
		* total international trade 
			generate tempXi_FULL = X_FULL if exporter != importer
				bysort exporter: egen Xi_FULL = sum(tempXi_FULL)
					drop tempXi_FULL
					
	* Save the conditional and general equilibrium effects results		
	save "D:\RCEP\data\sector_processed_data\FULLGE_Agri.dta", replace


* Step IV: Collect, construct, and report indexes of interest
	use "D:\RCEP\data\sector_processed_data\FULLGE_Agri.dta", clear
		collapse(mean) OMR_FULL OMR_CDL OMR_BLN change_pricei_FULL Xi_* Y_BLN Y_FULL, by(exporter)
			rename exporter country
			replace country = "DEU" if country == "ZZZ"
			sort country
		
		* Percent change in full endowment general equilibrium of factory-gate prices
			generate change_price_FULL = (1 - change_pricei_FULL) / 1 * 100
			
		* Percent change in full endowment general equilibirum of outward multilateral resistances
			generate change_OMR_CDL = (OMR_CDL^(1/(1-sigma)) - OMR_BLN^(1/(1-sigma))) / OMR_BLN^(1/(1-sigma)) * 100
		
		* Percent change in full endowment general equilibrium of outward multilateral resistances			
			generate change_OMR_FULL = (OMR_FULL^(1/(1-sigma)) - OMR_BLN^(1/(1-sigma))) / OMR_BLN^(1/(1-sigma)) * 100

		* Percent change in conditional general equilibrium of bilateral trade
			generate change_Xi_CDL = (Xi_CDL - Xi_BLN) / Xi_BLN * 100	
			
		* Percent change in full endowment general equilibrium of bilateral trade		
			generate change_Xi_FULL = (Xi_FULL - Xi_BLN) / Xi_BLN * 100
	save "D:\RCEP\data\sector_processed_data\FULL_PROD_Agri.dta", replace


	* Construct the percentage changes on import/consumption side
	use "D:\RCEP\data\sector_processed_data\FULLGE_Agri.dta", clear
		collapse(mean) IMR_FULL IMR_CDL IMR_BLN, by(importer)
			rename importer country
			replace country = "DEU" if country == "ZZZ"
			sort country		

		* Conditional general equilibrium of inward multilateral resistances
			generate change_IMR_CDL = (IMR_CDL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
			
		* Full endowment general equilibrium of inward multilateral resistances
			generate change_IMR_FULL = (IMR_FULL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
	save "D:\RCEP\data\sector_processed_data\FULL_CONS_Agri.dta", replace

	* Merge the general equilibrium results from the production and consumption
	* sides
	use "D:\RCEP\data\sector_processed_data\FULL_PROD_Agri.dta", clear
		joinby country using "D:\RCEP\data\sector_processed_data\FULL_CONS_Agri.dta"
		
		* Full endowment general equilibrium of real GDP
			generate rGDP_BLN = Y_BLN / (IMR_BLN ^(1 / (1 -sigma)))
			generate rGDP_FULL = Y_FULL / (IMR_FULL ^(1 / (1 -sigma)))
				generate change_rGDP_FULL = (rGDP_FULL - rGDP_BLN) / rGDP_BLN * 100

		* Keep indexes of interest	
			keep country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
			order country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
				
	* Export the results in Excel
	//total result
	save "D:\RCEP\data\sector_processed_data\FULL_result_Agri.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_Agri.xls", firstrow(variables) keepcellfmt replace
	//RCEP country result
	use  "D:\RCEP\data\sector_processed_data\FULL_result_Agri.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP == 1
	rename iso3_d country
	save "D:\RCEP\data\sector_processed_data\FULL_RCEP_Agri.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_RCEP_Agri.xls", firstrow(variables) keepcellfmt replace
	//NO RCEP country result
	use  "D:\RCEP\data\sector_processed_data\FULL_result_Agri.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP!=1
	rename iso3_d country 
	save "D:\RCEP\data\sector_processed_data\FULL_NORCEP_Agri.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_NORCEP_Agri.xls", firstrow(variables) keepcellfmt replace

	
/*********2.3 Manufacturing*********/

****************************** PART (i) *****************************
use "D:\RCEP\data\sector_processed_data\RTAImpacts_Manufacturing.dta",clear
rename Exp_cou exporter
rename Imp_cou importer
rename Year year
rename export trade
  
* Estimate the gravity model 
		ppml trade PAIR_FE1-PAIR_FE$NTij_1 EXPORTER_TIME_FE* IMPORTER_TIME_FE1-IMPORTER_TIME_FE$NT_yr RTA , iter(35) noconst
* Save the estimation results 
			estimate store gravity_panel

***************************** PART (ii) *****************************
************************* GENERAL EQUILIBRIUM ANALYSIS *************************
* Step I: Solve the baseline gravity model
* Step I.a. Obtain estimates of trade costs and trade elasticities baseline indexes
                * Stage 1: Obtain the estimates of pair fixed effects and the effects of RTAs
* Alternatively recall the results of the gravity model obtained above 
				estimate restore gravity_panel
				scalar RTA_est = _b[RTA]	
* Construct the trade costs from the pair fixed effects
					forvalues ijt = 1(1)$NTij_8{
						 cap qui replace PAIR_FE`ijt' = PAIR_FE`ijt' * _b[PAIR_FE`ijt']
					}	
					egen gamma_ij = rowtotal(PAIR_FE1-PAIR_FE$NTij )
						replace gamma_ij = . if gamma_ij == 1 & exporter != importer
						replace gamma_ij = 0 if gamma_ij == 1 & exporter == importer
					generate tij_bar = exp(gamma_ij)
					generate tij_bln = exp(gamma_ij + RTA_est*RTA)
                 
				 * Stage 2: Regress the estimates of pair fixed effects on gravity variables and country fixed effects
* Perform the regression for the baseline year
					keep if year == 2018
* Specify the dependent variable as the estimates of pair fixed effects
					generate tij = exp(gamma_ij)
* Create the exporters and importers fixed effects	
					quietly tabulate exporter, gen(EXPORTER_FE)
					quietly tabulate importer, gen(IMPORTER_FE)
* Estimate the standard gravity model 
				ppmlhdfe tij ln_distance contig comlang_off colony comcol comrelig legal if exporter != importer, absorb(exp_time imp_time, savefe) cluster(pair_id) d
					estimates store gravity_est
					
				* Create the predicted values 	
					predict tij_noRTA, mu
						replace tij_noRTA = 1 if exporter == importer
* Replace the missing trade costs with predictions from the
				* standard gravity regression
					replace tij_bar = tij_noRTA if tij_bar == . 
					replace tij_bln = tij_bar * exp(RTA_est*RTA) if tij_bln == .	
				    generate ln_tij_bln = log(tij_bln)	
* Set the number of exporter fixed effects variables
		quietly ds EXPORTER_FE*
		global N = `: word count `r(varlist)'' 
		global N_1 = $N - 1	
	
		* Estimate the gravity model in the "baseline" scenario 
		ppml trade EXPORTER_FE* IMPORTER_FE1-IMPORTER_FE$N_1 , noconst offset(ln_tij_bln) iter(30)
			predict tradehat_BLN, mu


* Step I.b. Construct baseline indexes	
		* Based on the estimated exporter and importer fixed effects, create
		* the actual set of fixed effects
			forvalues i = 1 (1) $N_1 {
				quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
				quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
			}
			
		* Create the exporter and importer fixed effects for the country of 
		* reference (Germany)
			quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
			quietly replace IMPORTER_FE$N = IMPORTER_FE$N * exp(0)
			
		* Create the variables stacking all the non-zero exporter and importer 
		* fixed effects, respectively		
			egen exp_pi_BLN = rowtotal(EXPORTER_FE1-EXPORTER_FE$N )
			egen exp_chi_BLN = rowtotal(IMPORTER_FE1-IMPORTER_FE$N ) 

		* Compute the variable of bilateral trade costs, i.e. the fitted trade
		* value by omitting the exporter and importer fixed effects		
			generate tij_BLN = tij_bln			

		* Compute the outward and inward multilateral resistances using the 
		* additive property of the PPML estimator that links the exporter and  
		* importer fixed effects with their respective multilateral resistances
		* taking into account the normalisation imposed
			generate OMR_BLN = Y * E_R / exp_pi_BLN
			generate IMR_BLN = E / (exp_chi_BLN * E_R)	
			
		* Compute the estimated level of international trade in the baseline for
		* the given level of ouptput and expenditures			
			generate tempXi_BLN = tradehat_BLN if exporter != importer
				bysort exporter: egen Xi_BLN = sum(tempXi_BLN)
					drop tempXi_BLN
			generate Y_BLN = Y
			generate E_BLN = E

* Step II: Define a conterfactual scenario
generate RTA_CFL = RTA
 replace RTA_CFL = 1 if RCEP == 1
generate tij_CFL = tij_bar * exp(RTA_est  * RTA_CFL) 
generate ln_tij_CFL = log(tij_CFL)
* Re-create the exporters and imports fixed effects
				drop EXPORTER_FE* IMPORTER_FE*
			quietly tabulate exporter, generate(EXPORTER_FE)
			quietly tabulate importer, generate(IMPORTER_FE)

		* Estimate the constrained gravity model and generate predicted trade
		* value
		ppml trade EXPORTER_FE* IMPORTER_FE1-IMPORTER_FE$N_1 ,noconst offset(ln_tij_CFL) iter(40)
			predict tradehat_CDL, mu
        
		* (ii):	Construct conditional general equilibrium multilateral resistances
	
		* Based on the estimated exporter and importer fixed effects, create
		* the actual set of counterfactual fixed effects	
			forvalues i = 1(1)$N_1 {
				quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
				quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
			}
		
		* Create the exporter and importer fixed effects for the country of 
		* reference (Germany)
			quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
			quietly replace IMPORTER_FE$N = IMPORTER_FE$N * exp(0)
			
		* Create the variables stacking all the non-zero exporter and importer 
		* fixed effects, respectively		
			egen exp_pi_CDL = rowtotal( EXPORTER_FE1-EXPORTER_FE$N )
			egen exp_chi_CDL = rowtotal( IMPORTER_FE1-IMPORTER_FE$N )
			
		* Compute the outward and inward multilateral resistances 				
			generate OMR_CDL = Y * E_R / exp_pi_CDL
			generate IMR_CDL = E / (exp_chi_CDL * E_R)
			
		* Compute the estimated level of conditional general equilibrium 
		* international trade for the given level of ouptput and expenditures		
			generate tempXi_CDL = tradehat_CDL if exporter != importer
				bysort exporter: egen Xi_CDL = sum(tempXi_CDL)
					drop tempXi_CDL
					
					* Step III.b: Obtain full endowment general equilibrium effects
* The constant elasticity of substitutin is taken from the literature
*(ps:I have problem in full endowment GE PPML, the research result is still unachieved in this step )

   drop EXPORTER_FE* IMPORTER_FE*
			quietly tabulate exporter, generate(EXPORTER_FE)
			quietly tabulate importer, generate(IMPORTER_FE)
     quietly ds EXPORTER_FE*
		global N = `: word count `r(varlist)'' 
		global N_1 = $N - 1	
		
			scalar sigma = 7
			
			* The parameter phi links the value of output with expenditures
			bysort year: generate phi = E/Y if exporter == importer
			
			* Compute the change in bilateral trade costs resulting from the 
			* counterfactual
			generate change_tij = tij_CFL / tij_BLN	

			* Re-specify the variables in the baseline and conditional scenarios
				* output 
				generate Y_0 = Y
				generate Y_1 = Y
				
				* Expenditures, including with respect to the reference country   
				generate E_0 = E
				generate E_R_0 = E_R
				generate E_1 = E
				generate E_R_1 = E_R			
			
				* Predicted level of trade 
				generate tradehat_1 = tradehat_CDL

        * (i)	Allow for endogenous factory-gate prices
	
			* Re-specify the factory-gate prices under the baseline and 
			* conditional scenarios				
			generate exp_pi_0 = exp_pi_BLN
			generate tempexp_pi_ii_0 = exp_pi_0 if exporter == importer
				bysort importer: egen exp_pi_j_0 = mean(tempexp_pi_ii_0)
			generate exp_pi_1 = exp_pi_CDL
			generate tempexp_pi_ii_1 = exp_pi_1 if exporter == importer
				bysort importer: egen exp_pi_j_1 = mean(tempexp_pi_ii_1)
				drop tempexp_pi_ii_*
			generate exp_chi_0 = exp_chi_BLN	
			generate exp_chi_1 = exp_chi_CDL	
			
			* Compute the first order change in factory-gate prices	in the 
			* baseline and conditional scenarios
			generate change_pricei_0 = 0				
			generate change_pricei_1 = ((exp_pi_1 / exp_pi_0) / (E_R_1 / E_R_0))^(1/(1-sigma))
			generate change_pricej_1 = ((exp_pi_j_1 / exp_pi_j_0) / (E_R_1 / E_R_0))^(1/(1-sigma))
		
			* Re-specify the outward and inward multilateral resistances in the
			* baseline and conditional scenarios
			generate OMR_FULL_0 = Y_0 * E_R_0 / exp_pi_0
			generate IMR_FULL_0 = E_0 / (exp_chi_0 * E_R_0)		
			generate IMR_FULL_1 = E_1 / (exp_chi_1 * E_R_1)
			generate OMR_FULL_1 = Y_1 * E_R_1 / exp_pi_1
			
		* Compute initial change in outward and multilateral resitances, which 
		* are set to zero		
			generate change_IMR_FULL_1 = exp(0)		
			generate change_OMR_FULL_1 = exp(0)
save "D:\RCEP\data\sector_processed_data\before_iter_Manu.dta", replace

****************************************************************************
	******************** Start of the Iterative Procedure  *********************
	* Set the criteria of convergence, namely that either the standard errors or
	* maximum of the difference between two iterations of the factory-gate 
	* prices are smaller than 0.01, where s is the number of iterations	
	
use  "D:\RCEP\data\sector_processed_data\before_iter_Manu.dta", clear
		local s = 3	
		local sd_dif_change_pi = 1
		local max_dif_change_pi = 1
	  while (`sd_dif_change_pi' > 0.01) | (`max_dif_change_pi' > 0.01) {
		local s_1 = `s' - 1
		local s_2 = `s' - 2
		local s_3 = `s' - 3
* (ii)	Allow for endogenous income, expenditures and trade	
		*	generate trade_`s_1' = change_tij * tradehat_`s_2' * change_pricei_`s_2' * change_pricej_`s_2' / (change_OMR_FULL_`s_2'*change_IMR_FULL_`s_2')
			generate trade_`s_1' =  tradehat_`s_2' * change_pricei_`s_2' * change_pricej_`s_2' / (change_OMR_FULL_`s_2'*change_IMR_FULL_`s_2')

			
		* (iii)	Estimation of the structural gravity model
				drop EXPORTER_FE* IMPORTER_FE*
				quietly tabulate exporter, generate (EXPORTER_FE)
				quietly tabulate importer, generate (IMPORTER_FE)
			   capture glm trade_`s_1' EXPORTER_FE* IMPORTER_FE*, offset(ln_tij_CFL) family(poisson) noconst irls iter(30)
				predict tradehat_`s_1', mu
					
			* Update output & expenditure			
				bysort exporter: egen Y_`s_1' = total(tradehat_`s_1')
				quietly generate tempE_`s_1' = phi * Y_`s_1' if exporter == importer
					bysort importer: egen E_`s_1' = mean(tempE_`s_1')
				quietly generate tempE_R_`s_1' = E_`s_1' if importer == "ZZZ"
					egen E_R_`s_1' = mean(tempE_R_`s_1')
				
			* Update factory-gate prices 
				forvalues i = 1(1)$N_1 {
				 quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
					 quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
				}
				 quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
				egen exp_pi_`s_1' = rowtotal(EXPORTER_FE1-EXPORTER_FE$N ) 
				quietly generate tempvar1 = exp_pi_`s_1' if exporter == importer
					bysort importer: egen exp_pi_j_`s_1' = mean(tempvar1) 		
					
			* Update multilateral resistances
				generate change_pricei_`s_1' = ((exp_pi_`s_1' / exp_pi_`s_2') / (E_R_`s_1' / E_R_`s_2'))^(1/(1-sigma))
				generate change_pricej_`s_1' = ((exp_pi_j_`s_1' / exp_pi_j_`s_2') / (E_R_`s_1' / E_R_`s_2'))^(1/(1-sigma))
				generate OMR_FULL_`s_1' = (Y_`s_1' * E_R_`s_1') / exp_pi_`s_1' 
					generate change_OMR_FULL_`s_1' = OMR_FULL_`s_1' / OMR_FULL_`s_2'					
				egen exp_chi_`s_1' = rowtotal(IMPORTER_FE1-IMPORTER_FE$N )	
				generate IMR_FULL_`s_1' = E_`s_1' / (exp_chi_`s_1' * E_R_`s_1')
					generate change_IMR_FULL_`s_1' = IMR_FULL_`s_1' / IMR_FULL_`s_2'
				
			* Iteration until the change in factory-gate prices converges to zero
				generate dif_change_pi_`s_1' = change_pricei_`s_2' - change_pricei_`s_3'
					display "************************* iteration number " `s_2' " *************************"
						summarize dif_change_pi_`s_1', format
					display "**********************************************************************"
					display " "
						local sd_dif_change_pi = r(sd)
						local max_dif_change_pi = abs(r(max))	
						
			local s = `s' + 1
			drop temp* 
	}
	

	********************* End of the Iterative Procedure  **********************
	****************************************************************************
		
		* (iv)	Construction of the "full endowment general equilibrium" 
		*		effects indexes
			* Use the result of the latest iteration S
			local S = `s' - 2
		*	forvalues i = 1 (1) $N_1 {
		*		quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
		*	}		
		* Compute the full endowment general equilibrium of factory-gate price
			generate change_pricei_FULL = ((exp_pi_`S' / exp_pi_0) / (E_R_`S' / E_R_0))^(1/(1-sigma))		

		* Compute the full endowment general equilibrium of the value output
			generate Y_FULL = change_pricei_FULL  * Y_BLN

		* Compute the full endowment general equilibrium of the value of 
		* aggregate expenditures
			generate tempE_FULL = phi * Y_FULL if exporter == importer
				bysort importer: egen E_FULL = mean(tempE_FULL)
					drop tempE_FULL
			
		* Compute the full endowment general equilibrium of the outward and 
		* inward multilateral resistances 
			generate OMR_FULL = Y_FULL * E_R_`S' / exp_pi_`S'
			generate IMR_FULL = E_`S' / (exp_chi_`S' * E_R_`S')	

		* Compute the full endowment general equilibrium of the value of 
		* bilateral trade 
			generate X_FULL = (Y_FULL * E_FULL * tij_CFL) /(IMR_FULL * OMR_FULL)			
		
		* Compute the full endowment general equilibrium of the value of 
		* total international trade 
			generate tempXi_FULL = X_FULL if exporter != importer
				bysort exporter: egen Xi_FULL = sum(tempXi_FULL)
					drop tempXi_FULL
					
	* Save the conditional and general equilibrium effects results		
	save "D:\RCEP\data\sector_processed_data\FULLGE_Manu.dta", replace


* Step IV: Collect, construct, and report indexes of interest
	use "D:\RCEP\data\sector_processed_data\FULLGE_Manu.dta", clear
		collapse(mean) OMR_FULL OMR_CDL OMR_BLN change_pricei_FULL Xi_* Y_BLN Y_FULL, by(exporter)
			rename exporter country
			replace country = "DEU" if country == "ZZZ"
			sort country
		
		* Percent change in full endowment general equilibrium of factory-gate prices
			generate change_price_FULL = (1 - change_pricei_FULL) / 1 * 100
			
		* Percent change in full endowment general equilibirum of outward multilateral resistances
			generate change_OMR_CDL = (OMR_CDL^(1/(1-sigma)) - OMR_BLN^(1/(1-sigma))) / OMR_BLN^(1/(1-sigma)) * 100
		
		* Percent change in full endowment general equilibrium of outward multilateral resistances			
			generate change_OMR_FULL = (OMR_FULL^(1/(1-sigma)) - OMR_BLN^(1/(1-sigma))) / OMR_BLN^(1/(1-sigma)) * 100

		* Percent change in conditional general equilibrium of bilateral trade
			generate change_Xi_CDL = (Xi_CDL - Xi_BLN) / Xi_BLN * 100	
			
		* Percent change in full endowment general equilibrium of bilateral trade		
			generate change_Xi_FULL = (Xi_FULL - Xi_BLN) / Xi_BLN * 100
	save "D:\RCEP\data\sector_processed_data\FULL_PROD_Manu.dta", replace


	* Construct the percentage changes on import/consumption side
	use "D:\RCEP\data\sector_processed_data\FULLGE_Manu.dta", clear
		collapse(mean) IMR_FULL IMR_CDL IMR_BLN, by(importer)
			rename importer country
			replace country = "DEU" if country == "ZZZ"
			sort country		

		* Conditional general equilibrium of inward multilateral resistances
			generate change_IMR_CDL = (IMR_CDL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
			
		* Full endowment general equilibrium of inward multilateral resistances
			generate change_IMR_FULL = (IMR_FULL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
	save "D:\RCEP\data\sector_processed_data\FULL_CONS_Manu.dta", replace

	* Merge the general equilibrium results from the production and consumption
	* sides
	use "D:\RCEP\data\sector_processed_data\FULL_PROD_Manu.dta", clear
		joinby country using "D:\RCEP\data\sector_processed_data\FULL_CONS_Manu.dta"
		
		* Full endowment general equilibrium of real GDP
			generate rGDP_BLN = Y_BLN / (IMR_BLN ^(1 / (1 -sigma)))
			generate rGDP_FULL = Y_FULL / (IMR_FULL ^(1 / (1 -sigma)))
				generate change_rGDP_FULL = (rGDP_FULL - rGDP_BLN) / rGDP_BLN * 100

		* Keep indexes of interest	
			keep country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
			order country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
				
	* Export the results in Excel
	//total result
	save "D:\RCEP\data\sector_processed_data\FULL_result_Manu.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_Manu.xls", firstrow(variables) keepcellfmt replace
	//RCEP country result
	use  "D:\RCEP\data\sector_processed_data\FULL_result_Manu.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP == 1
	rename iso3_d country
	save "D:\RCEP\data\sector_processed_data\FULL_RCEP_Manu.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_RCEP_Manu.xls", firstrow(variables) keepcellfmt replace
	//NO RCEP country result
	use  "D:\RCEP\data\sector_processed_data\FULL_result_Manu.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP!=1
	rename iso3_d country 
	save "D:\RCEP\data\sector_processed_data\FULL_NORCEP_Manu.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_NORCEP_Manu.xls", firstrow(variables) keepcellfmt replace	
	
	
/*********3.4 Services*********/

****************************** PART (i) *****************************
use "D:\RCEP\data\sector_processed_data\RTAImpacts_Service.dta",clear
rename Exp_cou exporter
rename Imp_cou importer
rename Year year
rename export trade
  
* Estimate the gravity model 
		ppml trade PAIR_FE1-PAIR_FE$NTij_1 EXPORTER_TIME_FE* IMPORTER_TIME_FE1-IMPORTER_TIME_FE$NT_yr RTA , iter(35) noconst
* Save the estimation results 
			estimate store gravity_panel

***************************** PART (ii) *****************************
************************* GENERAL EQUILIBRIUM ANALYSIS *************************
* Step I: Solve the baseline gravity model
* Step I.a. Obtain estimates of trade costs and trade elasticities baseline indexes
                * Stage 1: Obtain the estimates of pair fixed effects and the effects of RTAs
* Alternatively recall the results of the gravity model obtained above 
				estimate restore gravity_panel
				scalar RTA_est = _b[RTA]	
* Construct the trade costs from the pair fixed effects
					forvalues ijt = 1(1)$NTij_8{
						 cap qui replace PAIR_FE`ijt' = PAIR_FE`ijt' * _b[PAIR_FE`ijt']
					}	
					egen gamma_ij = rowtotal(PAIR_FE1-PAIR_FE$NTij )
						replace gamma_ij = . if gamma_ij == 1 & exporter != importer
						replace gamma_ij = 0 if gamma_ij == 1 & exporter == importer
					generate tij_bar = exp(gamma_ij)
					generate tij_bln = exp(gamma_ij + RTA_est*RTA)
                 
				 * Stage 2: Regress the estimates of pair fixed effects on gravity variables and country fixed effects
* Perform the regression for the baseline year
					keep if year == 2018
* Specify the dependent variable as the estimates of pair fixed effects
					generate tij = exp(gamma_ij)
* Create the exporters and importers fixed effects	
					quietly tabulate exporter, gen(EXPORTER_FE)
					quietly tabulate importer, gen(IMPORTER_FE)
* Estimate the standard gravity model 
				ppmlhdfe tij ln_distance contig comlang_off colony comcol comrelig legal if exporter != importer, absorb(exp_time imp_time, savefe) cluster(pair_id) d
					estimates store gravity_est
					
				* Create the predicted values 	
					predict tij_noRTA, mu
						replace tij_noRTA = 1 if exporter == importer
* Replace the missing trade costs with predictions from the
				* standard gravity regression
					replace tij_bar = tij_noRTA if tij_bar == . 
					replace tij_bln = tij_bar * exp(RTA_est*RTA) if tij_bln == .	
				    generate ln_tij_bln = log(tij_bln)	
* Set the number of exporter fixed effects variables
		quietly ds EXPORTER_FE*
		global N = `: word count `r(varlist)'' 
		global N_1 = $N - 1	
	
		* Estimate the gravity model in the "baseline" scenario 
		ppml trade EXPORTER_FE* IMPORTER_FE1-IMPORTER_FE$N_1 , noconst offset(ln_tij_bln) iter(30)
			predict tradehat_BLN, mu


* Step I.b. Construct baseline indexes	
		* Based on the estimated exporter and importer fixed effects, create
		* the actual set of fixed effects
			forvalues i = 1 (1) $N_1 {
				quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
				quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
			}
			
		* Create the exporter and importer fixed effects for the country of 
		* reference (Germany)
			quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
			quietly replace IMPORTER_FE$N = IMPORTER_FE$N * exp(0)
			
		* Create the variables stacking all the non-zero exporter and importer 
		* fixed effects, respectively		
			egen exp_pi_BLN = rowtotal(EXPORTER_FE1-EXPORTER_FE$N )
			egen exp_chi_BLN = rowtotal(IMPORTER_FE1-IMPORTER_FE$N ) 

		* Compute the variable of bilateral trade costs, i.e. the fitted trade
		* value by omitting the exporter and importer fixed effects		
			generate tij_BLN = tij_bln			

		* Compute the outward and inward multilateral resistances using the 
		* additive property of the PPML estimator that links the exporter and  
		* importer fixed effects with their respective multilateral resistances
		* taking into account the normalisation imposed
			generate OMR_BLN = Y * E_R / exp_pi_BLN
			generate IMR_BLN = E / (exp_chi_BLN * E_R)	
			
		* Compute the estimated level of international trade in the baseline for
		* the given level of ouptput and expenditures			
			generate tempXi_BLN = tradehat_BLN if exporter != importer
				bysort exporter: egen Xi_BLN = sum(tempXi_BLN)
					drop tempXi_BLN
			generate Y_BLN = Y
			generate E_BLN = E

* Step II: Define a conterfactual scenario
generate RTA_CFL = RTA
 replace RTA_CFL = 1 if RCEP == 1
generate tij_CFL = tij_bar * exp(RTA_est  * RTA_CFL) 
generate ln_tij_CFL = log(tij_CFL)
* Re-create the exporters and imports fixed effects
				drop EXPORTER_FE* IMPORTER_FE*
			quietly tabulate exporter, generate(EXPORTER_FE)
			quietly tabulate importer, generate(IMPORTER_FE)

		* Estimate the constrained gravity model and generate predicted trade
		* value
		ppml trade EXPORTER_FE* IMPORTER_FE1-IMPORTER_FE$N_1 ,noconst offset(ln_tij_CFL) iter(40)
			predict tradehat_CDL, mu
        
		* (ii):	Construct conditional general equilibrium multilateral resistances
	
		* Based on the estimated exporter and importer fixed effects, create
		* the actual set of counterfactual fixed effects	
			forvalues i = 1(1)$N_1 {
				quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
				quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
			}
		
		* Create the exporter and importer fixed effects for the country of 
		* reference (Germany)
			quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
			quietly replace IMPORTER_FE$N = IMPORTER_FE$N * exp(0)
			
		* Create the variables stacking all the non-zero exporter and importer 
		* fixed effects, respectively		
			egen exp_pi_CDL = rowtotal( EXPORTER_FE1-EXPORTER_FE$N )
			egen exp_chi_CDL = rowtotal( IMPORTER_FE1-IMPORTER_FE$N )
			
		* Compute the outward and inward multilateral resistances 				
			generate OMR_CDL = Y * E_R / exp_pi_CDL
			generate IMR_CDL = E / (exp_chi_CDL * E_R)
			
		* Compute the estimated level of conditional general equilibrium 
		* international trade for the given level of ouptput and expenditures		
			generate tempXi_CDL = tradehat_CDL if exporter != importer
				bysort exporter: egen Xi_CDL = sum(tempXi_CDL)
					drop tempXi_CDL
					
					* Step III.b: Obtain full endowment general equilibrium effects
* The constant elasticity of substitutin is taken from the literature
*(ps:I have problem in full endowment GE PPML, the research result is still unachieved in this step )

   drop EXPORTER_FE* IMPORTER_FE*
			quietly tabulate exporter, generate(EXPORTER_FE)
			quietly tabulate importer, generate(IMPORTER_FE)
     quietly ds EXPORTER_FE*
		global N = `: word count `r(varlist)'' 
		global N_1 = $N - 1	
		
			scalar sigma = 7
			
			* The parameter phi links the value of output with expenditures
			bysort year: generate phi = E/Y if exporter == importer
			
			* Compute the change in bilateral trade costs resulting from the 
			* counterfactual
			generate change_tij = tij_CFL / tij_BLN	

			* Re-specify the variables in the baseline and conditional scenarios
				* output 
				generate Y_0 = Y
				generate Y_1 = Y
				
				* Expenditures, including with respect to the reference country   
				generate E_0 = E
				generate E_R_0 = E_R
				generate E_1 = E
				generate E_R_1 = E_R			
			
				* Predicted level of trade 
				generate tradehat_1 = tradehat_CDL

        * (i)	Allow for endogenous factory-gate prices
	
			* Re-specify the factory-gate prices under the baseline and 
			* conditional scenarios				
			generate exp_pi_0 = exp_pi_BLN
			generate tempexp_pi_ii_0 = exp_pi_0 if exporter == importer
				bysort importer: egen exp_pi_j_0 = mean(tempexp_pi_ii_0)
			generate exp_pi_1 = exp_pi_CDL
			generate tempexp_pi_ii_1 = exp_pi_1 if exporter == importer
				bysort importer: egen exp_pi_j_1 = mean(tempexp_pi_ii_1)
				drop tempexp_pi_ii_*
			generate exp_chi_0 = exp_chi_BLN	
			generate exp_chi_1 = exp_chi_CDL	
			
			* Compute the first order change in factory-gate prices	in the 
			* baseline and conditional scenarios
			generate change_pricei_0 = 0				
			generate change_pricei_1 = ((exp_pi_1 / exp_pi_0) / (E_R_1 / E_R_0))^(1/(1-sigma))
			generate change_pricej_1 = ((exp_pi_j_1 / exp_pi_j_0) / (E_R_1 / E_R_0))^(1/(1-sigma))
		
			* Re-specify the outward and inward multilateral resistances in the
			* baseline and conditional scenarios
			generate OMR_FULL_0 = Y_0 * E_R_0 / exp_pi_0
			generate IMR_FULL_0 = E_0 / (exp_chi_0 * E_R_0)		
			generate IMR_FULL_1 = E_1 / (exp_chi_1 * E_R_1)
			generate OMR_FULL_1 = Y_1 * E_R_1 / exp_pi_1
			
		* Compute initial change in outward and multilateral resitances, which 
		* are set to zero		
			generate change_IMR_FULL_1 = exp(0)		
			generate change_OMR_FULL_1 = exp(0)
save "D:\RCEP\data\sector_processed_data\before_iter_Service.dta", replace

****************************************************************************
	******************** Start of the Iterative Procedure  *********************
	* Set the criteria of convergence, namely that either the standard errors or
	* maximum of the difference between two iterations of the factory-gate 
	* prices are smaller than 0.01, where s is the number of iterations	
	
use  "D:\RCEP\data\sector_processed_data\before_iter_Service.dta", clear
		local s = 3	
		local sd_dif_change_pi = 1
		local max_dif_change_pi = 1
	  while (`sd_dif_change_pi' > 0.01) | (`max_dif_change_pi' > 0.01) {
		local s_1 = `s' - 1
		local s_2 = `s' - 2
		local s_3 = `s' - 3
* (ii)	Allow for endogenous income, expenditures and trade	
		*	generate trade_`s_1' = change_tij * tradehat_`s_2' * change_pricei_`s_2' * change_pricej_`s_2' / (change_OMR_FULL_`s_2'*change_IMR_FULL_`s_2')
			generate trade_`s_1' =  tradehat_`s_2' * change_pricei_`s_2' * change_pricej_`s_2' / (change_OMR_FULL_`s_2'*change_IMR_FULL_`s_2')

			
		* (iii)	Estimation of the structural gravity model
				drop EXPORTER_FE* IMPORTER_FE*
				quietly tabulate exporter, generate (EXPORTER_FE)
				quietly tabulate importer, generate (IMPORTER_FE)
			   capture glm trade_`s_1' EXPORTER_FE* IMPORTER_FE*, offset(ln_tij_CFL) family(poisson) noconst irls iter(30)
				predict tradehat_`s_1', mu
					
			* Update output & expenditure			
				bysort exporter: egen Y_`s_1' = total(tradehat_`s_1')
				quietly generate tempE_`s_1' = phi * Y_`s_1' if exporter == importer
					bysort importer: egen E_`s_1' = mean(tempE_`s_1')
				quietly generate tempE_R_`s_1' = E_`s_1' if importer == "ZZZ"
					egen E_R_`s_1' = mean(tempE_R_`s_1')
				
			* Update factory-gate prices 
				forvalues i = 1(1)$N_1 {
				 quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
					 quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
				}
				 quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
				egen exp_pi_`s_1' = rowtotal(EXPORTER_FE1-EXPORTER_FE$N ) 
				quietly generate tempvar1 = exp_pi_`s_1' if exporter == importer
					bysort importer: egen exp_pi_j_`s_1' = mean(tempvar1) 		
					
			* Update multilateral resistances
				generate change_pricei_`s_1' = ((exp_pi_`s_1' / exp_pi_`s_2') / (E_R_`s_1' / E_R_`s_2'))^(1/(1-sigma))
				generate change_pricej_`s_1' = ((exp_pi_j_`s_1' / exp_pi_j_`s_2') / (E_R_`s_1' / E_R_`s_2'))^(1/(1-sigma))
				generate OMR_FULL_`s_1' = (Y_`s_1' * E_R_`s_1') / exp_pi_`s_1' 
					generate change_OMR_FULL_`s_1' = OMR_FULL_`s_1' / OMR_FULL_`s_2'					
				egen exp_chi_`s_1' = rowtotal(IMPORTER_FE1-IMPORTER_FE$N )	
				generate IMR_FULL_`s_1' = E_`s_1' / (exp_chi_`s_1' * E_R_`s_1')
					generate change_IMR_FULL_`s_1' = IMR_FULL_`s_1' / IMR_FULL_`s_2'
				
			* Iteration until the change in factory-gate prices converges to zero
				generate dif_change_pi_`s_1' = change_pricei_`s_2' - change_pricei_`s_3'
					display "************************* iteration number " `s_2' " *************************"
						summarize dif_change_pi_`s_1', format
					display "**********************************************************************"
					display " "
						local sd_dif_change_pi = r(sd)
						local max_dif_change_pi = abs(r(max))	
						
			local s = `s' + 1
			drop temp* 
	}
	

	********************* End of the Iterative Procedure  **********************
	****************************************************************************
		
		* (iv)	Construction of the "full endowment general equilibrium" 
		*		effects indexes
			* Use the result of the latest iteration S
			local S = `s' - 2
		*	forvalues i = 1 (1) $N_1 {
		*		quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
		*	}		
		* Compute the full endowment general equilibrium of factory-gate price
			generate change_pricei_FULL = ((exp_pi_`S' / exp_pi_0) / (E_R_`S' / E_R_0))^(1/(1-sigma))		

		* Compute the full endowment general equilibrium of the value output
			generate Y_FULL = change_pricei_FULL  * Y_BLN

		* Compute the full endowment general equilibrium of the value of 
		* aggregate expenditures
			generate tempE_FULL = phi * Y_FULL if exporter == importer
				bysort importer: egen E_FULL = mean(tempE_FULL)
					drop tempE_FULL
			
		* Compute the full endowment general equilibrium of the outward and 
		* inward multilateral resistances 
			generate OMR_FULL = Y_FULL * E_R_`S' / exp_pi_`S'
			generate IMR_FULL = E_`S' / (exp_chi_`S' * E_R_`S')	

		* Compute the full endowment general equilibrium of the value of 
		* bilateral trade 
			generate X_FULL = (Y_FULL * E_FULL * tij_CFL) /(IMR_FULL * OMR_FULL)			
		
		* Compute the full endowment general equilibrium of the value of 
		* total international trade 
			generate tempXi_FULL = X_FULL if exporter != importer
				bysort exporter: egen Xi_FULL = sum(tempXi_FULL)
					drop tempXi_FULL
					
	* Save the conditional and general equilibrium effects results		
	save "D:\RCEP\data\sector_processed_data\FULLGE_Service.dta", replace


* Step IV: Collect, construct, and report indexes of interest
	use "D:\RCEP\data\sector_processed_data\FULLGE_Service.dta", clear
		collapse(mean) OMR_FULL OMR_CDL OMR_BLN change_pricei_FULL Xi_* Y_BLN Y_FULL, by(exporter)
			rename exporter country
			replace country = "DEU" if country == "ZZZ"
			sort country
		
		* Percent change in full endowment general equilibrium of factory-gate prices
			generate change_price_FULL = (1 - change_pricei_FULL) / 1 * 100
			
		* Percent change in full endowment general equilibirum of outward multilateral resistances
			generate change_OMR_CDL = (OMR_CDL^(1/(1-sigma)) - OMR_BLN^(1/(1-sigma))) / OMR_BLN^(1/(1-sigma)) * 100
		
		* Percent change in full endowment general equilibrium of outward multilateral resistances			
			generate change_OMR_FULL = (OMR_FULL^(1/(1-sigma)) - OMR_BLN^(1/(1-sigma))) / OMR_BLN^(1/(1-sigma)) * 100

		* Percent change in conditional general equilibrium of bilateral trade
			generate change_Xi_CDL = (Xi_CDL - Xi_BLN) / Xi_BLN * 100	
			
		* Percent change in full endowment general equilibrium of bilateral trade		
			generate change_Xi_FULL = (Xi_FULL - Xi_BLN) / Xi_BLN * 100
	save "D:\RCEP\data\sector_processed_data\FULL_PROD_Service.dta", replace


	* Construct the percentage changes on import/consumption side
	use "D:\RCEP\data\sector_processed_data\FULLGE_Service.dta", clear
		collapse(mean) IMR_FULL IMR_CDL IMR_BLN, by(importer)
			rename importer country
			replace country = "DEU" if country == "ZZZ"
			sort country		

		* Conditional general equilibrium of inward multilateral resistances
			generate change_IMR_CDL = (IMR_CDL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
			
		* Full endowment general equilibrium of inward multilateral resistances
			generate change_IMR_FULL = (IMR_FULL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
	save "D:\RCEP\data\sector_processed_data\FULL_CONS_Service.dta", replace

	* Merge the general equilibrium results from the production and consumption
	* sides
	use "D:\RCEP\data\sector_processed_data\FULL_PROD_Service.dta", clear
		joinby country using "D:\RCEP\data\sector_processed_data\FULL_CONS_Service.dta"
		
		* Full endowment general equilibrium of real GDP
			generate rGDP_BLN = Y_BLN / (IMR_BLN ^(1 / (1 -sigma)))
			generate rGDP_FULL = Y_FULL / (IMR_FULL ^(1 / (1 -sigma)))
				generate change_rGDP_FULL = (rGDP_FULL - rGDP_BLN) / rGDP_BLN * 100

		* Keep indexes of interest	
			keep country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
			order country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
				
	* Export the results in Excel
	//total result
	save "D:\RCEP\data\sector_processed_data\FULL_result_Service.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_Service.xls", firstrow(variables) keepcellfmt replace
	//RCEP country result
	use  "D:\RCEP\data\sector_processed_data\FULL_result_Service.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP == 1
	rename iso3_d country
	save "D:\RCEP\data\sector_processed_data\FULL_RCEP_Service.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_RCEP_Service.xls", firstrow(variables) keepcellfmt replace
	//NO RCEP country result
	use  "D:\RCEP\data\sector_processed_data\FULL_result_Service.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP!=1
	rename iso3_d country 
	save "D:\RCEP\data\sector_processed_data\FULL_NORCEP_Service.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_NORCEP_Service.xls", firstrow(variables) keepcellfmt replace
	

/*********2.5 Intermediate*********/

****************************** PART (i) *****************************
use "D:\RCEP\data\sector_processed_data\RTAImpacts_INTL.dta",clear
rename Exp_cou exporter
rename Imp_cou importer
rename Year year
rename export_int trade
  
* Estimate the gravity model 
		ppml trade PAIR_FE1-PAIR_FE$NTij_1 EXPORTER_TIME_FE* IMPORTER_TIME_FE1-IMPORTER_TIME_FE$NT_yr RTA , iter(35) noconst
* Save the estimation results 
			estimate store gravity_panel

***************************** PART (ii) *****************************
************************* GENERAL EQUILIBRIUM ANALYSIS *************************
* Step I: Solve the baseline gravity model
* Step I.a. Obtain estimates of trade costs and trade elasticities baseline indexes
                * Stage 1: Obtain the estimates of pair fixed effects and the effects of RTAs
* Alternatively recall the results of the gravity model obtained above 
				estimate restore gravity_panel
				scalar RTA_est = _b[RTA]	
* Construct the trade costs from the pair fixed effects
					forvalues ijt = 1(1)$NTij_8{
						 cap qui replace PAIR_FE`ijt' = PAIR_FE`ijt' * _b[PAIR_FE`ijt']
					}	
					egen gamma_ij = rowtotal(PAIR_FE1-PAIR_FE$NTij )
						replace gamma_ij = . if gamma_ij == 1 & exporter != importer
						replace gamma_ij = 0 if gamma_ij == 1 & exporter == importer
					generate tij_bar = exp(gamma_ij)
					generate tij_bln = exp(gamma_ij + RTA_est*RTA)
                 
				 * Stage 2: Regress the estimates of pair fixed effects on gravity variables and country fixed effects
* Perform the regression for the baseline year
					keep if year == 2018
* Specify the dependent variable as the estimates of pair fixed effects
					generate tij = exp(gamma_ij)
* Create the exporters and importers fixed effects	
					quietly tabulate exporter, gen(EXPORTER_FE)
					quietly tabulate importer, gen(IMPORTER_FE)
* Estimate the standard gravity model 
				ppmlhdfe tij ln_distance contig comlang_off colony comcol comrelig legal if exporter != importer, absorb(exp_time imp_time, savefe) cluster(pair_id) d
					estimates store gravity_est
					
				* Create the predicted values 	
					predict tij_noRTA, mu
						replace tij_noRTA = 1 if exporter == importer
* Replace the missing trade costs with predictions from the
				* standard gravity regression
					replace tij_bar = tij_noRTA if tij_bar == . 
					replace tij_bln = tij_bar * exp(RTA_est*RTA) if tij_bln == .	
				    generate ln_tij_bln = log(tij_bln)	
* Set the number of exporter fixed effects variables
		quietly ds EXPORTER_FE*
		global N = `: word count `r(varlist)'' 
		global N_1 = $N - 1	
	
		* Estimate the gravity model in the "baseline" scenario 
		ppml trade EXPORTER_FE* IMPORTER_FE1-IMPORTER_FE$N_1 , noconst offset(ln_tij_bln) iter(30)
			predict tradehat_BLN, mu


* Step I.b. Construct baseline indexes	
		* Based on the estimated exporter and importer fixed effects, create
		* the actual set of fixed effects
			forvalues i = 1 (1) $N_1 {
				quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
				quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
			}
			
		* Create the exporter and importer fixed effects for the country of 
		* reference (Germany)
			quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
			quietly replace IMPORTER_FE$N = IMPORTER_FE$N * exp(0)
			
		* Create the variables stacking all the non-zero exporter and importer 
		* fixed effects, respectively		
			egen exp_pi_BLN = rowtotal(EXPORTER_FE1-EXPORTER_FE$N )
			egen exp_chi_BLN = rowtotal(IMPORTER_FE1-IMPORTER_FE$N ) 

		* Compute the variable of bilateral trade costs, i.e. the fitted trade
		* value by omitting the exporter and importer fixed effects		
			generate tij_BLN = tij_bln			

		* Compute the outward and inward multilateral resistances using the 
		* additive property of the PPML estimator that links the exporter and  
		* importer fixed effects with their respective multilateral resistances
		* taking into account the normalisation imposed
			generate OMR_BLN = Y * E_R / exp_pi_BLN
			generate IMR_BLN = E / (exp_chi_BLN * E_R)	
			
		* Compute the estimated level of international trade in the baseline for
		* the given level of ouptput and expenditures			
			generate tempXi_BLN = tradehat_BLN if exporter != importer
				bysort exporter: egen Xi_BLN = sum(tempXi_BLN)
					drop tempXi_BLN
			generate Y_BLN = Y
			generate E_BLN = E

* Step II: Define a conterfactual scenario
generate RTA_CFL = RTA
 replace RTA_CFL = 1 if RCEP == 1
generate tij_CFL = tij_bar * exp(RTA_est  * RTA_CFL) 
generate ln_tij_CFL = log(tij_CFL)
* Re-create the exporters and imports fixed effects
				drop EXPORTER_FE* IMPORTER_FE*
			quietly tabulate exporter, generate(EXPORTER_FE)
			quietly tabulate importer, generate(IMPORTER_FE)

		* Estimate the constrained gravity model and generate predicted trade
		* value
		ppml trade EXPORTER_FE* IMPORTER_FE1-IMPORTER_FE$N_1 ,noconst offset(ln_tij_CFL) iter(40)
			predict tradehat_CDL, mu
        
		* (ii):	Construct conditional general equilibrium multilateral resistances
	
		* Based on the estimated exporter and importer fixed effects, create
		* the actual set of counterfactual fixed effects	
			forvalues i = 1(1)$N_1 {
				quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
				quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
			}
		
		* Create the exporter and importer fixed effects for the country of 
		* reference (Germany)
			quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
			quietly replace IMPORTER_FE$N = IMPORTER_FE$N * exp(0)
			
		* Create the variables stacking all the non-zero exporter and importer 
		* fixed effects, respectively		
			egen exp_pi_CDL = rowtotal( EXPORTER_FE1-EXPORTER_FE$N )
			egen exp_chi_CDL = rowtotal( IMPORTER_FE1-IMPORTER_FE$N )
			
		* Compute the outward and inward multilateral resistances 				
			generate OMR_CDL = Y * E_R / exp_pi_CDL
			generate IMR_CDL = E / (exp_chi_CDL * E_R)
			
		* Compute the estimated level of conditional general equilibrium 
		* international trade for the given level of ouptput and expenditures		
			generate tempXi_CDL = tradehat_CDL if exporter != importer
				bysort exporter: egen Xi_CDL = sum(tempXi_CDL)
					drop tempXi_CDL
					
					* Step III.b: Obtain full endowment general equilibrium effects
* The constant elasticity of substitutin is taken from the literature
*(ps:I have problem in full endowment GE PPML, the research result is still unachieved in this step )

   drop EXPORTER_FE* IMPORTER_FE*
			quietly tabulate exporter, generate(EXPORTER_FE)
			quietly tabulate importer, generate(IMPORTER_FE)
     quietly ds EXPORTER_FE*
		global N = `: word count `r(varlist)'' 
		global N_1 = $N - 1	
		
			scalar sigma = 7
			
			* The parameter phi links the value of output with expenditures
			bysort year: generate phi = E/Y if exporter == importer
			
			* Compute the change in bilateral trade costs resulting from the 
			* counterfactual
			generate change_tij = tij_CFL / tij_BLN	

			* Re-specify the variables in the baseline and conditional scenarios
				* output 
				generate Y_0 = Y
				generate Y_1 = Y
				
				* Expenditures, including with respect to the reference country   
				generate E_0 = E
				generate E_R_0 = E_R
				generate E_1 = E
				generate E_R_1 = E_R			
			
				* Predicted level of trade 
				generate tradehat_1 = tradehat_CDL

        * (i)	Allow for endogenous factory-gate prices
	
			* Re-specify the factory-gate prices under the baseline and 
			* conditional scenarios				
			generate exp_pi_0 = exp_pi_BLN
			generate tempexp_pi_ii_0 = exp_pi_0 if exporter == importer
				bysort importer: egen exp_pi_j_0 = mean(tempexp_pi_ii_0)
			generate exp_pi_1 = exp_pi_CDL
			generate tempexp_pi_ii_1 = exp_pi_1 if exporter == importer
				bysort importer: egen exp_pi_j_1 = mean(tempexp_pi_ii_1)
				drop tempexp_pi_ii_*
			generate exp_chi_0 = exp_chi_BLN	
			generate exp_chi_1 = exp_chi_CDL	
			
			* Compute the first order change in factory-gate prices	in the 
			* baseline and conditional scenarios
			generate change_pricei_0 = 0				
			generate change_pricei_1 = ((exp_pi_1 / exp_pi_0) / (E_R_1 / E_R_0))^(1/(1-sigma))
			generate change_pricej_1 = ((exp_pi_j_1 / exp_pi_j_0) / (E_R_1 / E_R_0))^(1/(1-sigma))
		
			* Re-specify the outward and inward multilateral resistances in the
			* baseline and conditional scenarios
			generate OMR_FULL_0 = Y_0 * E_R_0 / exp_pi_0
			generate IMR_FULL_0 = E_0 / (exp_chi_0 * E_R_0)		
			generate IMR_FULL_1 = E_1 / (exp_chi_1 * E_R_1)
			generate OMR_FULL_1 = Y_1 * E_R_1 / exp_pi_1
			
		* Compute initial change in outward and multilateral resitances, which 
		* are set to zero		
			generate change_IMR_FULL_1 = exp(0)		
			generate change_OMR_FULL_1 = exp(0)
save "D:\RCEP\data\sector_processed_data\before_iter_INTL.dta", replace

****************************************************************************
	******************** Start of the Iterative Procedure  *********************
	* Set the criteria of convergence, namely that either the standard errors or
	* maximum of the difference between two iterations of the factory-gate 
	* prices are smaller than 0.01, where s is the number of iterations	
	
use  "D:\RCEP\data\sector_processed_data\before_iter_INTL.dta", clear
		local s = 3	
		local sd_dif_change_pi = 1
		local max_dif_change_pi = 1
	  while (`sd_dif_change_pi' > 0.01) | (`max_dif_change_pi' > 0.01) {
		local s_1 = `s' - 1
		local s_2 = `s' - 2
		local s_3 = `s' - 3
* (ii)	Allow for endogenous income, expenditures and trade	
		*	generate trade_`s_1' = change_tij * tradehat_`s_2' * change_pricei_`s_2' * change_pricej_`s_2' / (change_OMR_FULL_`s_2'*change_IMR_FULL_`s_2')
			generate trade_`s_1' =  tradehat_`s_2' * change_pricei_`s_2' * change_pricej_`s_2' / (change_OMR_FULL_`s_2'*change_IMR_FULL_`s_2')

			
		* (iii)	Estimation of the structural gravity model
				drop EXPORTER_FE* IMPORTER_FE*
				quietly tabulate exporter, generate (EXPORTER_FE)
				quietly tabulate importer, generate (IMPORTER_FE)
			   capture glm trade_`s_1' EXPORTER_FE* IMPORTER_FE*, offset(ln_tij_CFL) family(poisson) noconst irls iter(30)
				predict tradehat_`s_1', mu
					
			* Update output & expenditure			
				bysort exporter: egen Y_`s_1' = total(tradehat_`s_1')
				quietly generate tempE_`s_1' = phi * Y_`s_1' if exporter == importer
					bysort importer: egen E_`s_1' = mean(tempE_`s_1')
				quietly generate tempE_R_`s_1' = E_`s_1' if importer == "ZZZ"
					egen E_R_`s_1' = mean(tempE_R_`s_1')
				
			* Update factory-gate prices 
				forvalues i = 1(1)$N_1 {
				 quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
					 quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
				}
				 quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
				egen exp_pi_`s_1' = rowtotal(EXPORTER_FE1-EXPORTER_FE$N ) 
				quietly generate tempvar1 = exp_pi_`s_1' if exporter == importer
					bysort importer: egen exp_pi_j_`s_1' = mean(tempvar1) 		
					
			* Update multilateral resistances
				generate change_pricei_`s_1' = ((exp_pi_`s_1' / exp_pi_`s_2') / (E_R_`s_1' / E_R_`s_2'))^(1/(1-sigma))
				generate change_pricej_`s_1' = ((exp_pi_j_`s_1' / exp_pi_j_`s_2') / (E_R_`s_1' / E_R_`s_2'))^(1/(1-sigma))
				generate OMR_FULL_`s_1' = (Y_`s_1' * E_R_`s_1') / exp_pi_`s_1' 
					generate change_OMR_FULL_`s_1' = OMR_FULL_`s_1' / OMR_FULL_`s_2'					
				egen exp_chi_`s_1' = rowtotal(IMPORTER_FE1-IMPORTER_FE$N )	
				generate IMR_FULL_`s_1' = E_`s_1' / (exp_chi_`s_1' * E_R_`s_1')
					generate change_IMR_FULL_`s_1' = IMR_FULL_`s_1' / IMR_FULL_`s_2'
				
			* Iteration until the change in factory-gate prices converges to zero
				generate dif_change_pi_`s_1' = change_pricei_`s_2' - change_pricei_`s_3'
					display "************************* iteration number " `s_2' " *************************"
						summarize dif_change_pi_`s_1', format
					display "**********************************************************************"
					display " "
						local sd_dif_change_pi = r(sd)
						local max_dif_change_pi = abs(r(max))	
						
			local s = `s' + 1
			drop temp* 
	}
	

	********************* End of the Iterative Procedure  **********************
	****************************************************************************
		
		* (iv)	Construction of the "full endowment general equilibrium" 
		*		effects indexes
			* Use the result of the latest iteration S
			local S = `s' - 2
		*	forvalues i = 1 (1) $N_1 {
		*		quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
		*	}		
		* Compute the full endowment general equilibrium of factory-gate price
			generate change_pricei_FULL = ((exp_pi_`S' / exp_pi_0) / (E_R_`S' / E_R_0))^(1/(1-sigma))		

		* Compute the full endowment general equilibrium of the value output
			generate Y_FULL = change_pricei_FULL  * Y_BLN

		* Compute the full endowment general equilibrium of the value of 
		* aggregate expenditures
			generate tempE_FULL = phi * Y_FULL if exporter == importer
				bysort importer: egen E_FULL = mean(tempE_FULL)
					drop tempE_FULL
			
		* Compute the full endowment general equilibrium of the outward and 
		* inward multilateral resistances 
			generate OMR_FULL = Y_FULL * E_R_`S' / exp_pi_`S'
			generate IMR_FULL = E_`S' / (exp_chi_`S' * E_R_`S')	

		* Compute the full endowment general equilibrium of the value of 
		* bilateral trade 
			generate X_FULL = (Y_FULL * E_FULL * tij_CFL) /(IMR_FULL * OMR_FULL)			
		
		* Compute the full endowment general equilibrium of the value of 
		* total international trade 
			generate tempXi_FULL = X_FULL if exporter != importer
				bysort exporter: egen Xi_FULL = sum(tempXi_FULL)
					drop tempXi_FULL
					
	* Save the conditional and general equilibrium effects results		
	save "D:\RCEP\data\sector_processed_data\FULLGE_INTL.dta", replace


* Step IV: Collect, construct, and report indexes of interest
	use "D:\RCEP\data\sector_processed_data\FULLGE_INTL.dta", clear
		collapse(mean) OMR_FULL OMR_CDL OMR_BLN change_pricei_FULL Xi_* Y_BLN Y_FULL, by(exporter)
			rename exporter country
			replace country = "DEU" if country == "ZZZ"
			sort country
		
		* Percent change in full endowment general equilibrium of factory-gate prices
			generate change_price_FULL = (1 - change_pricei_FULL) / 1 * 100
			
		* Percent change in full endowment general equilibirum of outward multilateral resistances
			generate change_OMR_CDL = (OMR_CDL^(1/(1-sigma)) - OMR_BLN^(1/(1-sigma))) / OMR_BLN^(1/(1-sigma)) * 100
		
		* Percent change in full endowment general equilibrium of outward multilateral resistances			
			generate change_OMR_FULL = (OMR_FULL^(1/(1-sigma)) - OMR_BLN^(1/(1-sigma))) / OMR_BLN^(1/(1-sigma)) * 100

		* Percent change in conditional general equilibrium of bilateral trade
			generate change_Xi_CDL = (Xi_CDL - Xi_BLN) / Xi_BLN * 100	
			
		* Percent change in full endowment general equilibrium of bilateral trade		
			generate change_Xi_FULL = (Xi_FULL - Xi_BLN) / Xi_BLN * 100
	save "D:\RCEP\data\sector_processed_data\FULL_PROD_INTL.dta", replace


	* Construct the percentage changes on import/consumption side
	use "D:\RCEP\data\sector_processed_data\FULLGE_INTL.dta", clear
		collapse(mean) IMR_FULL IMR_CDL IMR_BLN, by(importer)
			rename importer country
			replace country = "DEU" if country == "ZZZ"
			sort country		

		* Conditional general equilibrium of inward multilateral resistances
			generate change_IMR_CDL = (IMR_CDL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
			
		* Full endowment general equilibrium of inward multilateral resistances
			generate change_IMR_FULL = (IMR_FULL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
	save "D:\RCEP\data\sector_processed_data\FULL_CONS_INTL.dta", replace

	* Merge the general equilibrium results from the production and consumption
	* sides
	use "D:\RCEP\data\sector_processed_data\FULL_PROD_INTL.dta", clear
		joinby country using "D:\RCEP\data\sector_processed_data\FULL_CONS_INTL.dta"
		
		* Full endowment general equilibrium of real GDP
			generate rGDP_BLN = Y_BLN / (IMR_BLN ^(1 / (1 -sigma)))
			generate rGDP_FULL = Y_FULL / (IMR_FULL ^(1 / (1 -sigma)))
				generate change_rGDP_FULL = (rGDP_FULL - rGDP_BLN) / rGDP_BLN * 100

		* Keep indexes of interest	
			keep country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
			order country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
				
	* Export the results in Excel
	//total result
	save "D:\RCEP\data\sector_processed_data\FULL_result_INTL.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_INTL.xls", firstrow(variables) keepcellfmt replace
	//RCEP country result
	use  "D:\RCEP\data\sector_processed_data\FULL_result_INTL.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP == 1
	rename iso3_d country
	save "D:\RCEP\data\sector_processed_data\FULL_RCEP_INTL.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_RCEP_INTL.xls", firstrow(variables) keepcellfmt replace
	//NO RCEP country result
	use  "D:\RCEP\data\sector_processed_data\FULL_result_INTL.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP!=1
	rename iso3_d country 
	save "D:\RCEP\data\sector_processed_data\FULL_NORCEP_INTL.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_NORCEP_INTL.xls", firstrow(variables) keepcellfmt replace

	
	
****************************************************************************************
****************************************************************************************
******************************
*        3 ICT sector        *
******************************
use "D:\RCEP\data\sector_processed_data\export_latest.dta",clear
keep if Year==1995|Year==2000| Year==2005| Year==2010| Year==2015| Year==2018
keep if Exp_ind	=="D26"|Exp_ind ==	"D61"|Exp_ind == "D62T63"
gen ln_distance=ln(dist)
bysort Exp_cou Year: egen Y = sum(export)
bysort Imp_cou Year: egen E = sum(export)
* Chose a country for reference group: GERMANY
		gen E_R_BLN = E if Imp_cou == "DEU"
			replace Exp_cou = "ZZZ" if Exp_cou == "DEU"
			replace Imp_cou = "ZZZ" if Imp_cou == "DEU"
		bysort Year: egen E_R = mean(E_R_BLN)
* Create pair_id
egen pair_id = group(Exp_cou Imp_cou)

* Create Exp_cou time fixed effects
		egen exp_time = group(Exp_cou Year)
		quietly tabulate exp_time, gen(EXPORTER_TIME_FE)

* Create Imp_cou time fixed effects
		egen imp_time = group(Imp_cou Year)
		quietly tabulate imp_time, gen(IMPORTER_TIME_FE)
* Rearrange so that country pairs, which will be dropped due to no export, are last	
		bysort pair_id: egen X = sum(export)
		quietly summarize pair_id
		replace pair_id = pair_id + r(max) + 1 if X == 0 | X == .
		drop X
* Rearrange so that the last country pair is the one for internal export
		quietly sum pair_id
		replace pair_id = r(max) + 1 if Exp_cou == Imp_cou
		quietly tabulate pair_id, gen(PAIR_FE)	

* Set additional exogenous parameters
		quietly ds EXPORTER_TIME_FE*
		global NT = `: word count `r(varlist)'' 
		
		quietly tabulate Year, gen(TIME_FE)		
		quietly ds TIME_FE*
		global Nyr = `: word count `r(varlist)''
		global NT_yr = $NT - $Nyr
		
		quietly ds PAIR_FE*
		global NTij = `: word count `r(varlist)'' 
		global NTij_1 = $NTij - 1
		global NTij_8 = $NTij - 8
* Save data
bysort Year Exp_cou Imp_cou: egen export_ICT= sum(export)
order export_ICT, after(export)
drop Exp_ind export production
duplicates drop
save "D:\RCEP\data\sector_processed_data\RTAImpacts_ICT.dta", replace

*table 4*
*ppml with CONTROL
use "D:\RCEP\data\sector_processed_data\RTAImpacts_ICT.dta", clear
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export_ICT RTA `CONTROL' if Exp_cou != Imp_cou, absorb(exp_time imp_time, savefe) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\ICT_baseline_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*ppml with pair_id
est clear
eststo: ppmlhdfe export_ICT RTA , absorb(exp_time imp_time pair_id) cluster(pair_id) noconst d
esttab using "D:\RCEP\data\sector_output\ICT_baseline_pairID.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*2018 estimation
keep if Year==2018
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export_ICT RTA `CONTROL' if Exp_cou != Imp_cou, absorb(Exp_cou Imp_cou, savefe) noconst d
esttab using "D:\RCEP\data\sector_output\ICT_2018_control.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 	
save "D:\RCEP\data\sector_processed_data\ICT_2018.dta",replace	


/***  ICT counterfactual   ***/


****************************** PART (i) *****************************
use "D:\RCEP\data\sector_processed_data\RTAImpacts_ICT.dta",clear
rename Exp_cou exporter
rename Imp_cou importer
rename Year year
rename export_ICT trade
  
* Estimate the gravity model 
		ppml trade PAIR_FE1-PAIR_FE$NTij_1 EXPORTER_TIME_FE* IMPORTER_TIME_FE1-IMPORTER_TIME_FE$NT_yr RTA , iter(35) noconst
* Save the estimation results 
			estimate store gravity_panel

***************************** PART (ii) *****************************
************************* GENERAL EQUILIBRIUM ANALYSIS *************************
* Step I: Solve the baseline gravity model
* Step I.a. Obtain estimates of trade costs and trade elasticities baseline indexes
                * Stage 1: Obtain the estimates of pair fixed effects and the effects of RTAs
* Alternatively recall the results of the gravity model obtained above 
				estimate restore gravity_panel
				scalar RTA_est = _b[RTA]	
* Construct the trade costs from the pair fixed effects
					forvalues ijt = 1(1)$NTij_8{
						 cap qui replace PAIR_FE`ijt' = PAIR_FE`ijt' * _b[PAIR_FE`ijt']
					}	
					egen gamma_ij = rowtotal(PAIR_FE1-PAIR_FE$NTij )
						replace gamma_ij = . if gamma_ij == 1 & exporter != importer
						replace gamma_ij = 0 if gamma_ij == 1 & exporter == importer
					generate tij_bar = exp(gamma_ij)
					generate tij_bln = exp(gamma_ij + RTA_est*RTA)
                 
				 * Stage 2: Regress the estimates of pair fixed effects on gravity variables and country fixed effects
* Perform the regression for the baseline year
					keep if year == 2018
* Specify the dependent variable as the estimates of pair fixed effects
					generate tij = exp(gamma_ij)
* Create the exporters and importers fixed effects	
					quietly tabulate exporter, gen(EXPORTER_FE)
					quietly tabulate importer, gen(IMPORTER_FE)
* Estimate the standard gravity model 
				ppmlhdfe tij ln_distance contig comlang_off colony comcol comrelig legal if exporter != importer, absorb(exp_time imp_time, savefe) cluster(pair_id) d
					estimates store gravity_est
					
				* Create the predicted values 	
					predict tij_noRTA, mu
						replace tij_noRTA = 1 if exporter == importer
* Replace the missing trade costs with predictions from the
				* standard gravity regression
					replace tij_bar = tij_noRTA if tij_bar == . 
					replace tij_bln = tij_bar * exp(RTA_est*RTA) if tij_bln == .	
				    generate ln_tij_bln = log(tij_bln)	
* Set the number of exporter fixed effects variables
		quietly ds EXPORTER_FE*
		global N = `: word count `r(varlist)'' 
		global N_1 = $N - 1	
	
		* Estimate the gravity model in the "baseline" scenario 
		ppml trade EXPORTER_FE* IMPORTER_FE1-IMPORTER_FE$N_1 , noconst offset(ln_tij_bln) iter(30)
			predict tradehat_BLN, mu


* Step I.b. Construct baseline indexes	
		* Based on the estimated exporter and importer fixed effects, create
		* the actual set of fixed effects
			forvalues i = 1 (1) $N_1 {
				quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
				quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
			}
			
		* Create the exporter and importer fixed effects for the country of 
		* reference (Germany)
			quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
			quietly replace IMPORTER_FE$N = IMPORTER_FE$N * exp(0)
			
		* Create the variables stacking all the non-zero exporter and importer 
		* fixed effects, respectively		
			egen exp_pi_BLN = rowtotal(EXPORTER_FE1-EXPORTER_FE$N )
			egen exp_chi_BLN = rowtotal(IMPORTER_FE1-IMPORTER_FE$N ) 

		* Compute the variable of bilateral trade costs, i.e. the fitted trade
		* value by omitting the exporter and importer fixed effects		
			generate tij_BLN = tij_bln			

		* Compute the outward and inward multilateral resistances using the 
		* additive property of the PPML estimator that links the exporter and  
		* importer fixed effects with their respective multilateral resistances
		* taking into account the normalisation imposed
			generate OMR_BLN = Y * E_R / exp_pi_BLN
			generate IMR_BLN = E / (exp_chi_BLN * E_R)	
			
		* Compute the estimated level of international trade in the baseline for
		* the given level of ouptput and expenditures			
			generate tempXi_BLN = tradehat_BLN if exporter != importer
				bysort exporter: egen Xi_BLN = sum(tempXi_BLN)
					drop tempXi_BLN
			generate Y_BLN = Y
			generate E_BLN = E

* Step II: Define a conterfactual scenario
generate RTA_CFL = RTA
 replace RTA_CFL = 1 if RCEP == 1
generate tij_CFL = tij_bar * exp(RTA_est  * RTA_CFL) 
generate ln_tij_CFL = log(tij_CFL)
* Re-create the exporters and imports fixed effects
				drop EXPORTER_FE* IMPORTER_FE*
			quietly tabulate exporter, generate(EXPORTER_FE)
			quietly tabulate importer, generate(IMPORTER_FE)

		* Estimate the constrained gravity model and generate predicted trade
		* value
		ppml trade EXPORTER_FE* IMPORTER_FE1-IMPORTER_FE$N_1 ,noconst offset(ln_tij_CFL) iter(40)
			predict tradehat_CDL, mu
        
		* (ii):	Construct conditional general equilibrium multilateral resistances
	
		* Based on the estimated exporter and importer fixed effects, create
		* the actual set of counterfactual fixed effects	
			forvalues i = 1(1)$N_1 {
				quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
				quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
			}
		
		* Create the exporter and importer fixed effects for the country of 
		* reference (Germany)
			quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
			quietly replace IMPORTER_FE$N = IMPORTER_FE$N * exp(0)
			
		* Create the variables stacking all the non-zero exporter and importer 
		* fixed effects, respectively		
			egen exp_pi_CDL = rowtotal( EXPORTER_FE1-EXPORTER_FE$N )
			egen exp_chi_CDL = rowtotal( IMPORTER_FE1-IMPORTER_FE$N )
			
		* Compute the outward and inward multilateral resistances 				
			generate OMR_CDL = Y * E_R / exp_pi_CDL
			generate IMR_CDL = E / (exp_chi_CDL * E_R)
			
		* Compute the estimated level of conditional general equilibrium 
		* international trade for the given level of ouptput and expenditures		
			generate tempXi_CDL = tradehat_CDL if exporter != importer
				bysort exporter: egen Xi_CDL = sum(tempXi_CDL)
					drop tempXi_CDL
					
					* Step III.b: Obtain full endowment general equilibrium effects
* The constant elasticity of substitutin is taken from the literature
*(ps:I have problem in full endowment GE PPML, the research result is still unachieved in this step )

   drop EXPORTER_FE* IMPORTER_FE*
			quietly tabulate exporter, generate(EXPORTER_FE)
			quietly tabulate importer, generate(IMPORTER_FE)
     quietly ds EXPORTER_FE*
		global N = `: word count `r(varlist)'' 
		global N_1 = $N - 1	
		
			scalar sigma = 7
			
			* The parameter phi links the value of output with expenditures
			bysort year: generate phi = E/Y if exporter == importer
			
			* Compute the change in bilateral trade costs resulting from the 
			* counterfactual
			generate change_tij = tij_CFL / tij_BLN	

			* Re-specify the variables in the baseline and conditional scenarios
				* output 
				generate Y_0 = Y
				generate Y_1 = Y
				
				* Expenditures, including with respect to the reference country   
				generate E_0 = E
				generate E_R_0 = E_R
				generate E_1 = E
				generate E_R_1 = E_R			
			
				* Predicted level of trade 
				generate tradehat_1 = tradehat_CDL

        * (i)	Allow for endogenous factory-gate prices
	
			* Re-specify the factory-gate prices under the baseline and 
			* conditional scenarios				
			generate exp_pi_0 = exp_pi_BLN
			generate tempexp_pi_ii_0 = exp_pi_0 if exporter == importer
				bysort importer: egen exp_pi_j_0 = mean(tempexp_pi_ii_0)
			generate exp_pi_1 = exp_pi_CDL
			generate tempexp_pi_ii_1 = exp_pi_1 if exporter == importer
				bysort importer: egen exp_pi_j_1 = mean(tempexp_pi_ii_1)
				drop tempexp_pi_ii_*
			generate exp_chi_0 = exp_chi_BLN	
			generate exp_chi_1 = exp_chi_CDL	
			
			* Compute the first order change in factory-gate prices	in the 
			* baseline and conditional scenarios
			generate change_pricei_0 = 0				
			generate change_pricei_1 = ((exp_pi_1 / exp_pi_0) / (E_R_1 / E_R_0))^(1/(1-sigma))
			generate change_pricej_1 = ((exp_pi_j_1 / exp_pi_j_0) / (E_R_1 / E_R_0))^(1/(1-sigma))
		
			* Re-specify the outward and inward multilateral resistances in the
			* baseline and conditional scenarios
			generate OMR_FULL_0 = Y_0 * E_R_0 / exp_pi_0
			generate IMR_FULL_0 = E_0 / (exp_chi_0 * E_R_0)		
			generate IMR_FULL_1 = E_1 / (exp_chi_1 * E_R_1)
			generate OMR_FULL_1 = Y_1 * E_R_1 / exp_pi_1
			
		* Compute initial change in outward and multilateral resitances, which 
		* are set to zero		
			generate change_IMR_FULL_1 = exp(0)		
			generate change_OMR_FULL_1 = exp(0)
save "D:\RCEP\data\sector_processed_data\before_iter_ICT.dta", replace

****************************************************************************
	******************** Start of the Iterative Procedure  *********************
	* Set the criteria of convergence, namely that either the standard errors or
	* maximum of the difference between two iterations of the factory-gate 
	* prices are smaller than 0.01, where s is the number of iterations	
	
use  "D:\RCEP\data\sector_processed_data\before_iter_ICT.dta", clear
		local s = 3	
		local sd_dif_change_pi = 1
		local max_dif_change_pi = 1
	  while (`sd_dif_change_pi' > 0.01) | (`max_dif_change_pi' > 0.01) {
		local s_1 = `s' - 1
		local s_2 = `s' - 2
		local s_3 = `s' - 3
* (ii)	Allow for endogenous income, expenditures and trade	
		*	generate trade_`s_1' = change_tij * tradehat_`s_2' * change_pricei_`s_2' * change_pricej_`s_2' / (change_OMR_FULL_`s_2'*change_IMR_FULL_`s_2')
			generate trade_`s_1' =  tradehat_`s_2' * change_pricei_`s_2' * change_pricej_`s_2' / (change_OMR_FULL_`s_2'*change_IMR_FULL_`s_2')

			
		* (iii)	Estimation of the structural gravity model
				drop EXPORTER_FE* IMPORTER_FE*
				quietly tabulate exporter, generate (EXPORTER_FE)
				quietly tabulate importer, generate (IMPORTER_FE)
			   capture glm trade_`s_1' EXPORTER_FE* IMPORTER_FE*, offset(ln_tij_CFL) family(poisson) noconst irls iter(30)
				predict tradehat_`s_1', mu
					
			* Update output & expenditure			
				bysort exporter: egen Y_`s_1' = total(tradehat_`s_1')
				quietly generate tempE_`s_1' = phi * Y_`s_1' if exporter == importer
					bysort importer: egen E_`s_1' = mean(tempE_`s_1')
				quietly generate tempE_R_`s_1' = E_`s_1' if importer == "ZZZ"
					egen E_R_`s_1' = mean(tempE_R_`s_1')
				
			* Update factory-gate prices 
				forvalues i = 1(1)$N_1 {
				 quietly replace EXPORTER_FE`i' = EXPORTER_FE`i' * exp(_b[EXPORTER_FE`i'])
					 quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
				}
				 quietly replace EXPORTER_FE$N = EXPORTER_FE$N * exp(_b[EXPORTER_FE$N ])
				egen exp_pi_`s_1' = rowtotal(EXPORTER_FE1-EXPORTER_FE$N ) 
				quietly generate tempvar1 = exp_pi_`s_1' if exporter == importer
					bysort importer: egen exp_pi_j_`s_1' = mean(tempvar1) 		
					
			* Update multilateral resistances
				generate change_pricei_`s_1' = ((exp_pi_`s_1' / exp_pi_`s_2') / (E_R_`s_1' / E_R_`s_2'))^(1/(1-sigma))
				generate change_pricej_`s_1' = ((exp_pi_j_`s_1' / exp_pi_j_`s_2') / (E_R_`s_1' / E_R_`s_2'))^(1/(1-sigma))
				generate OMR_FULL_`s_1' = (Y_`s_1' * E_R_`s_1') / exp_pi_`s_1' 
					generate change_OMR_FULL_`s_1' = OMR_FULL_`s_1' / OMR_FULL_`s_2'					
				egen exp_chi_`s_1' = rowtotal(IMPORTER_FE1-IMPORTER_FE$N )	
				generate IMR_FULL_`s_1' = E_`s_1' / (exp_chi_`s_1' * E_R_`s_1')
					generate change_IMR_FULL_`s_1' = IMR_FULL_`s_1' / IMR_FULL_`s_2'
				
			* Iteration until the change in factory-gate prices converges to zero
				generate dif_change_pi_`s_1' = change_pricei_`s_2' - change_pricei_`s_3'
					display "************************* iteration number " `s_2' " *************************"
						summarize dif_change_pi_`s_1', format
					display "**********************************************************************"
					display " "
						local sd_dif_change_pi = r(sd)
						local max_dif_change_pi = abs(r(max))	
						
			local s = `s' + 1
			drop temp* 
	}
	

	********************* End of the Iterative Procedure  **********************
	****************************************************************************
		
		* (iv)	Construction of the "full endowment general equilibrium" 
		*		effects indexes
			* Use the result of the latest iteration S
			local S = `s' - 2
		*	forvalues i = 1 (1) $N_1 {
		*		quietly replace IMPORTER_FE`i' = IMPORTER_FE`i' * exp(_b[IMPORTER_FE`i'])
		*	}		
		* Compute the full endowment general equilibrium of factory-gate price
			generate change_pricei_FULL = ((exp_pi_`S' / exp_pi_0) / (E_R_`S' / E_R_0))^(1/(1-sigma))		

		* Compute the full endowment general equilibrium of the value output
			generate Y_FULL = change_pricei_FULL  * Y_BLN

		* Compute the full endowment general equilibrium of the value of 
		* aggregate expenditures
			generate tempE_FULL = phi * Y_FULL if exporter == importer
				bysort importer: egen E_FULL = mean(tempE_FULL)
					drop tempE_FULL
			
		* Compute the full endowment general equilibrium of the outward and 
		* inward multilateral resistances 
			generate OMR_FULL = Y_FULL * E_R_`S' / exp_pi_`S'
			generate IMR_FULL = E_`S' / (exp_chi_`S' * E_R_`S')	

		* Compute the full endowment general equilibrium of the value of 
		* bilateral trade 
			generate X_FULL = (Y_FULL * E_FULL * tij_CFL) /(IMR_FULL * OMR_FULL)			
		
		* Compute the full endowment general equilibrium of the value of 
		* total international trade 
			generate tempXi_FULL = X_FULL if exporter != importer
				bysort exporter: egen Xi_FULL = sum(tempXi_FULL)
					drop tempXi_FULL
					
	* Save the conditional and general equilibrium effects results		
	save "D:\RCEP\data\sector_processed_data\FULLGE_ICT.dta", replace


* Step IV: Collect, construct, and report indexes of interest
	use "D:\RCEP\data\sector_processed_data\FULLGE_ICT.dta", clear
		collapse(mean) OMR_FULL OMR_CDL OMR_BLN change_pricei_FULL Xi_* Y_BLN Y_FULL, by(exporter)
			rename exporter country
			replace country = "DEU" if country == "ZZZ"
			sort country
		
		* Percent change in full endowment general equilibrium of factory-gate prices
			generate change_price_FULL = (1 - change_pricei_FULL) / 1 * 100
			
		* Percent change in full endowment general equilibirum of outward multilateral resistances
			generate change_OMR_CDL = (OMR_CDL^(1/(1-sigma)) - OMR_BLN^(1/(1-sigma))) / OMR_BLN^(1/(1-sigma)) * 100
		
		* Percent change in full endowment general equilibrium of outward multilateral resistances			
			generate change_OMR_FULL = (OMR_FULL^(1/(1-sigma)) - OMR_BLN^(1/(1-sigma))) / OMR_BLN^(1/(1-sigma)) * 100

		* Percent change in conditional general equilibrium of bilateral trade
			generate change_Xi_CDL = (Xi_CDL - Xi_BLN) / Xi_BLN * 100	
			
		* Percent change in full endowment general equilibrium of bilateral trade		
			generate change_Xi_FULL = (Xi_FULL - Xi_BLN) / Xi_BLN * 100
	save "D:\RCEP\data\sector_processed_data\FULL_PROD_ICT.dta", replace


	* Construct the percentage changes on import/consumption side
	use "D:\RCEP\data\sector_processed_data\FULLGE_ICT.dta", clear
		collapse(mean) IMR_FULL IMR_CDL IMR_BLN, by(importer)
			rename importer country
			replace country = "DEU" if country == "ZZZ"
			sort country		

		* Conditional general equilibrium of inward multilateral resistances
			generate change_IMR_CDL = (IMR_CDL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
			
		* Full endowment general equilibrium of inward multilateral resistances
			generate change_IMR_FULL = (IMR_FULL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
	save "D:\RCEP\data\sector_processed_data\FULL_CONS_ICT.dta", replace

	* Merge the general equilibrium results from the production and consumption
	* sides
	use "D:\RCEP\data\sector_processed_data\FULL_PROD_ICT.dta", clear
		joinby country using "D:\RCEP\data\sector_processed_data\FULL_CONS_ICT.dta"
		
		* Full endowment general equilibrium of real GDP
			generate rGDP_BLN = Y_BLN / (IMR_BLN ^(1 / (1 -sigma)))
			generate rGDP_FULL = Y_FULL / (IMR_FULL ^(1 / (1 -sigma)))
				generate change_rGDP_FULL = (rGDP_FULL - rGDP_BLN) / rGDP_BLN * 100

		* Keep indexes of interest	
			keep country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
			order country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
				
	* Export the results in Excel
	//total result
	save "D:\RCEP\data\sector_processed_data\FULL_result_ICT.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_ICT.xls", firstrow(variables) keepcellfmt replace
	//RCEP country result
	use  "D:\RCEP\data\sector_processed_data\FULL_result_ICT.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP == 1
	rename iso3_d country
	save "D:\RCEP\data\sector_processed_data\FULL_RCEP_ICT.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_RCEP_ICT.xls", firstrow(variables) keepcellfmt replace
	//NO RCEP country result
	use  "D:\RCEP\data\sector_processed_data\FULL_result_ICT.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP!=1
	rename iso3_d country 
	save "D:\RCEP\data\sector_processed_data\FULL_NORCEP_ICT.dta", replace
	export excel using  "D:\RCEP\data\sector_output\FULL_NORCEP_ICT.xls", firstrow(variables) keepcellfmt replace	