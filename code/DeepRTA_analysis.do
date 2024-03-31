******************************************
*           1. baseline ppml             * 
******************************************
*CLUSTER4
/*********1.1 total export*********/
use "E:\RCEP\data\sector_processed_data\export_Cluster4.dta",clear
keep if Year==1995|Year==2000| Year==2005| Year==2010| Year==2015| Year==2018
keep if Exp_ind == "DTOTAL"
gen ln_distance=ln(dist)
bysort Exp_cou Year: egen Y = sum(export)
bysort Imp_cou Year: egen E = sum(export)
*description summary*
*table 1
sum contig comlang_off colony comcol comrelig ln_distance legal export RTA
outreg2 using "E:\RCEP\data\sector_output\summary_table1.xls", replace sum(log) keep(contig comlang_off colony comcol comrelig ln_distance legal export RTA) title(Decriptive statistics)
*table 2
correlate contig comlang_off colony comcol comrelig ln_distance legal export RTA
export excel using  "E:\RCEP\data\sector_output\summary_table2.xls", keepcellfmt replace

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
save "E:\RCEP\data\sector_processed_data\RTAImpacts_total_cluster4_2.dta", replace

*table 3*
*ppml with CONTROL
use "E:\RCEP\data\sector_processed_data\RTAImpacts_total_cluster4_2.dta", clear
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export rta1 rta2 rta3 rta4 `CONTROL' if Exp_cou != Imp_cou, absorb(exp_time imp_time, savefe) cluster(pair_id) noconst d
esttab using "E:\RCEP\data\sector_output\baseline_control_cluster4_2.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*ppml with pair_id
est clear
eststo: ppmlhdfe export rta1 rta2 rta3 rta4 , absorb(exp_time imp_time pair_id) cluster(pair_id) noconst d
esttab using "E:\RCEP\data\sector_output\baseline_pairID_cluster4_2.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 
*2018 estimation
keep if Year==2018
local CONTROL ln_distance contig comlang_off colony comcol comrelig legal
macro list
est clear
eststo: ppmlhdfe export rta1 rta2 rta3 rta4  `CONTROL' if Exp_cou != Imp_cou, absorb(Exp_cou Imp_cou, savefe) noconst d
esttab using "E:\RCEP\data\sector_output\2018_control_cluster4.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 	
save "E:\RCEP\data\sector_processed_data\2018.dta_cluster4",replace

/*********1.2 Agriculture*********/
use "E:\RCEP\data\sector_processed_data\export_Cluster4.dta",clear
//keep if Year==1995|Year==2000| Year==2005| Year==2010| Year==2015| Year==2018
keep if Year==1996|Year==2002| Year==2008| Year==2015| Year==2017| Year==2018
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
save "E:\RCEP\data\sector_processed_data\RTAImpacts_Agriculture_k4.dta", replace

*table 4*
*ppml with pair_id
use "E:\RCEP\data\sector_processed_data\RTAImpacts_Agriculture_k4.dta", clear
est clear
eststo: ppmlhdfe export rta1 rta2 rta3 rta4 , absorb(exp_time imp_time pair_id) cluster(pair_id) noconst d
esttab using "E:\RCEP\data\sector_output\Agriculture_baseline_pairID_k4.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 

/*********1.3 Manufacturing*********/
use "E:\RCEP\data\sector_processed_data\export_Cluster4.dta",clear
//keep if Year==1995|Year==2000| Year==2005| Year==2010| Year==2015| Year==2018
keep if Year==1996|Year==2002| Year==2008| Year==2015| Year==2017| Year==2018
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
save "E:\RCEP\data\sector_processed_data\RTAImpacts_Manufacturing_k4.dta", replace

*table 4*
*ppml with pair_id
use "E:\RCEP\data\sector_processed_data\RTAImpacts_Manufacturing_k4.dta", clear
est clear
eststo: ppmlhdfe export rta1 rta2 rta3 rta4 , absorb(exp_time imp_time pair_id) cluster(pair_id) noconst d
esttab using "E:\RCEP\data\sector_output\Manufacturing_baseline_pairID_k4.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 


/*********1.4 Services*********/
use "E:\RCEP\data\sector_processed_data\export_Cluster4.dta",clear
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
save "E:\RCEP\data\sector_processed_data\RTAImpacts_Service_k4.dta", replace

*table 4*
*ppml with pair_id
use "E:\RCEP\data\sector_processed_data\RTAImpacts_Service_k4.dta", clear
est clear
eststo: ppmlhdfe export rta1 rta2 rta3 rta4 , absorb(exp_time imp_time pair_id) cluster(pair_id) noconst d
esttab using "E:\RCEP\data\sector_output\Service_baseline_pairID_k4.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 

/*********1.5 Intermediate*********/
use "E:\RCEP\data\sector_processed_data\export_INTL_Cluster4.dta",clear
keep if Year==1995|Year==2000| Year==2005| Year==2010| Year==2015| Year==2017
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
save "E:\RCEP\data\sector_processed_data\RTAImpacts_INTL_k4.dta", replace

*table 4*
*ppml with pair_id
use "E:\RCEP\data\sector_processed_data\RTAImpacts_INTL_k4.dta", clear
est clear
eststo: ppmlhdfe export rta1 rta2 rta3 rta4 , absorb(exp_time imp_time pair_id) cluster(pair_id) noconst d
esttab using "E:\RCEP\data\sector_output\INTL_baseline_pairID_k4.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 

/*********1.6 FD*********/
use "E:\RCEP\data\sector_processed_data\export_FD_Cluster4.dta",clear
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
save "E:\RCEP\data\sector_processed_data\RTAImpacts_FD_k4.dta", replace

*table 4*
*ppml with pair_id
use "E:\RCEP\data\sector_processed_data\RTAImpacts_FD_k4.dta", clear
est clear
eststo: ppmlhdfe export rta1 rta2 rta3 rta4 , absorb(exp_time imp_time pair_id) cluster(pair_id) noconst d
esttab using "E:\RCEP\data\sector_output\FD_baseline_pairID_k4.csv",  ///
stats(N r2, fmt(0 2) labels(Obs. R-squared))    /// 
b(3) se(3) star(* .10 ** .05 *** .01) nogaps noconstant n replace 


******************************
* 2  Counterfactual steps    *
******************************


/*********2.1 total export*********/

****************************** PART (i) *****************************
use "E:\RCEP\data\sector_processed_data\RTAImpacts_total_cluster4.dta",clear
rename Exp_cou exporter
rename Imp_cou importer
rename Year year
rename export trade
  
* Estimate the gravity model 
		ppml trade PAIR_FE1-PAIR_FE$NTij_1 EXPORTER_TIME_FE* IMPORTER_TIME_FE1-IMPORTER_TIME_FE$NT_yr rta1 rta2 rta3 rta4 , iter(35) noconst
* Save the estimation results 
			estimate store gravity_panel

***************************** PART (ii) *****************************
************************* GENERAL EQUILIBRIUM ANALYSIS *************************
* Step I: Solve the baseline gravity model
* Step I.a. Obtain estimates of trade costs and trade elasticities baseline indexes
                * Stage 1: Obtain the estimates of pair fixed effects and the effects of RTAs
* Alternatively recall the results of the gravity model obtained above 
				estimate restore gravity_panel
				scalar rta1_est = _b[rta1]
				scalar rta2_est = _b[rta2]
				scalar rta3_est = _b[rta3]
				scalar rta4_est = _b[rta4]
* Construct the trade costs from the pair fixed effects
					forvalues ijt = 1(1)$NTij_8{
						 cap qui replace PAIR_FE`ijt' = PAIR_FE`ijt' * _b[PAIR_FE`ijt']
					}	
					egen gamma_ij = rowtotal(PAIR_FE1-PAIR_FE$NTij )
						replace gamma_ij = . if gamma_ij == 1 & exporter != importer
						replace gamma_ij = 0 if gamma_ij == 1 & exporter == importer
					generate tij_bar = exp(gamma_ij)
					generate tij_bln = exp(gamma_ij + (rta1_est*rta1 + rta2_est*rta2+ rta3_est*rta3 + rta4_est*rta4))
                 
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
					replace tij_bln = tij_bar * exp((rta1_est*rta1 + rta2_est*rta2+ rta3_est*rta3 + rta4_est*rta4)) if tij_bln == .	
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
generate rta1_CFL = rta1
 replace rta1_CFL = 1 if RCEP == 1
generate rta2_CFL = rta2
 replace rta2_CFL = 0 if RCEP == 1
generate rta3_CFL = rta3
 replace rta3_CFL = 0 if RCEP == 1
generate rta4_CFL = rta4
 replace rta4_CFL = 0 if RCEP == 1
generate tij_CFL = tij_bar * exp( (rta1_est*rta1_CFL + rta2_est*rta2_CFL+ rta3_est*rta3_CFL + rta4_est*rta4_CFL)) 
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
save "E:\RCEP\data\sector_processed_data\before_iter_total_cluster4.dta", replace

****************************************************************************
	******************** Start of the Iterative Procedure  *********************
	* Set the criteria of convergence, namely that either the standard errors or
	* maximum of the difference between two iterations of the factory-gate 
	* prices are smaller than 0.01, where s is the number of iterations	
	
use  "E:\RCEP\data\sector_processed_data\before_iter_total_cluster4.dta", clear
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
	save "E:\RCEP\data\sector_processed_data\FULLGE_total_k4.dta", replace


* Step IV: Collect, construct, and report indexes of interest
	use "E:\RCEP\data\sector_processed_data\FULLGE_total_k4.dta", clear
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
	save "E:\RCEP\data\sector_processed_data\FULL_PROD_total_k4.dta", replace


	* Construct the percentage changes on import/consumption side
	use "E:\RCEP\data\sector_processed_data\FULLGE_total_k4.dta", clear
		collapse(mean) IMR_FULL IMR_CDL IMR_BLN, by(importer)
			rename importer country
			replace country = "DEU" if country == "ZZZ"
			sort country		

		* Conditional general equilibrium of inward multilateral resistances
			generate change_IMR_CDL = (IMR_CDL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
			
		* Full endowment general equilibrium of inward multilateral resistances
			generate change_IMR_FULL = (IMR_FULL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
	save "E:\RCEP\data\sector_processed_data\FULL_CONS_total_k4.dta", replace

	* Merge the general equilibrium results from the production and consumption
	* sides
	use "E:\RCEP\data\sector_processed_data\FULL_PROD_total_k4.dta", clear
		joinby country using "E:\RCEP\data\sector_processed_data\FULL_CONS_total_k4.dta"
		
		* Full endowment general equilibrium of real GDP
			generate rGDP_BLN = Y_BLN / (IMR_BLN ^(1 / (1 -sigma)))
			generate rGDP_FULL = Y_FULL / (IMR_FULL ^(1 / (1 -sigma)))
				generate change_rGDP_FULL = (rGDP_FULL - rGDP_BLN) / rGDP_BLN * 100

		* Keep indexes of interest	
			keep country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
			order country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
				
	* Export the results in Excel
	//total result
	save "E:\RCEP\data\sector_processed_data\FULL_result_total_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_total_k4.xls", firstrow(variables) keepcellfmt replace
	//RCEP country result
	use  "E:\RCEP\data\sector_processed_data\FULL_result_total_k4.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP == 1
	rename iso3_d country
	save "E:\RCEP\data\sector_processed_data\FULL_RCEP_total_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_RCEP_total_k4.xls", firstrow(variables) keepcellfmt replace
	//NO RCEP country result
	use  "E:\RCEP\data\sector_processed_data\FULL_result_total_k4.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP!=1
	rename iso3_d country 
	save "E:\RCEP\data\sector_processed_data\FULL_NORCEP_total_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_NORCEP_total_k4.xls", firstrow(variables) keepcellfmt replace
	

/*********2.2 Agriculture*********/

****************************** PART (i) *****************************
use "E:\RCEP\data\sector_processed_data\RTAImpacts_Agriculture_k4.dta",clear
rename Exp_cou exporter
rename Imp_cou importer
rename Year year
rename export trade
  
* Estimate the gravity model 
		ppml trade PAIR_FE1-PAIR_FE$NTij_1 EXPORTER_TIME_FE* IMPORTER_TIME_FE1-IMPORTER_TIME_FE$NT_yr rta1 rta2 rta3 rta4 , iter(35) noconst
* Save the estimation results 
			estimate store gravity_panel

***************************** PART (ii) *****************************
************************* GENERAL EQUILIBRIUM ANALYSIS *************************
* Step I: Solve the baseline gravity model
* Step I.a. Obtain estimates of trade costs and trade elasticities baseline indexes
                * Stage 1: Obtain the estimates of pair fixed effects and the effects of RTAs
* Alternatively recall the results of the gravity model obtained above 
				estimate restore gravity_panel
				scalar rta1_est = _b[rta1]
				scalar rta2_est = _b[rta2]
				scalar rta3_est = _b[rta3]
				scalar rta4_est = _b[rta4]
* Construct the trade costs from the pair fixed effects
					forvalues ijt = 1(1)$NTij_8{
						 cap qui replace PAIR_FE`ijt' = PAIR_FE`ijt' * _b[PAIR_FE`ijt']
					}	
					egen gamma_ij = rowtotal(PAIR_FE1-PAIR_FE$NTij )
						replace gamma_ij = . if gamma_ij == 1 & exporter != importer
						replace gamma_ij = 0 if gamma_ij == 1 & exporter == importer
					generate tij_bar = exp(gamma_ij)
					generate tij_bln = exp(gamma_ij + (rta1_est*rta1 + rta2_est*rta2+ rta3_est*rta3 + rta4_est*rta4))
                 
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
					replace tij_bln = tij_bar * exp((rta1_est*rta1 + rta2_est*rta2+ rta3_est*rta3 + rta4_est*rta4)) if tij_bln == .	
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
generate rta1_CFL = rta1
 replace rta1_CFL = 1 if RCEP == 1
generate rta2_CFL = rta2
 replace rta2_CFL = 0 if RCEP == 1
generate rta3_CFL = rta3
 replace rta3_CFL = 0 if RCEP == 1
generate rta4_CFL = rta4
 replace rta4_CFL = 0 if RCEP == 1
generate tij_CFL = tij_bar * exp( (rta1_est*rta1_CFL + rta2_est*rta2_CFL+ rta3_est*rta3_CFL + rta4_est*rta4_CFL)) 
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
save "E:\RCEP\data\sector_processed_data\before_iter_Agri_cluster4.dta", replace

****************************************************************************
	******************** Start of the Iterative Procedure  *********************
	* Set the criteria of convergence, namely that either the standard errors or
	* maximum of the difference between two iterations of the factory-gate 
	* prices are smaller than 0.01, where s is the number of iterations	
	
use  "E:\RCEP\data\sector_processed_data\before_iter_Agri_cluster4.dta", clear
		local s = 3	
		local sd_dif_change_pi = 1
		local max_dif_change_pi = 1
	  while (`sd_dif_change_pi' > 0.02) | (`max_dif_change_pi' > 0.04) {
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
	save "E:\RCEP\data\sector_processed_data\FULLGE_Agri_k4.dta", replace


* Step IV: Collect, construct, and report indexes of interest
	use "E:\RCEP\data\sector_processed_data\FULLGE_Agri_k4.dta", clear
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
	save "E:\RCEP\data\sector_processed_data\FULL_PROD_Agri_k4.dta", replace


	* Construct the percentage changes on import/consumption side
	use "E:\RCEP\data\sector_processed_data\FULLGE_Agri_k4.dta", clear
		collapse(mean) IMR_FULL IMR_CDL IMR_BLN, by(importer)
			rename importer country
			replace country = "DEU" if country == "ZZZ"
			sort country		

		* Conditional general equilibrium of inward multilateral resistances
			generate change_IMR_CDL = (IMR_CDL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
			
		* Full endowment general equilibrium of inward multilateral resistances
			generate change_IMR_FULL = (IMR_FULL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
	save "E:\RCEP\data\sector_processed_data\FULL_CONS_Agri_k4.dta", replace

	* Merge the general equilibrium results from the production and consumption
	* sides
	use "E:\RCEP\data\sector_processed_data\FULL_PROD_Agri_k4.dta", clear
		joinby country using "E:\RCEP\data\sector_processed_data\FULL_CONS_Agri_k4.dta"
		
		* Full endowment general equilibrium of real GDP
			generate rGDP_BLN = Y_BLN / (IMR_BLN ^(1 / (1 -sigma)))
			generate rGDP_FULL = Y_FULL / (IMR_FULL ^(1 / (1 -sigma)))
				generate change_rGDP_FULL = (rGDP_FULL - rGDP_BLN) / rGDP_BLN * 100

		* Keep indexes of interest	
			keep country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
			order country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
				
	* Export the results in Excel
	//total result
	save "E:\RCEP\data\sector_processed_data\FULL_result_Agri_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_Agri_k4.xls", firstrow(variables) keepcellfmt replace
	//RCEP country result
	use  "E:\RCEP\data\sector_processed_data\FULL_result_Agri_k4.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP == 1
	rename iso3_d country
	save "E:\RCEP\data\sector_processed_data\FULL_RCEP_Agri_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_RCEP_Agri_k4.xls", firstrow(variables) keepcellfmt replace
	//NO RCEP country result
	use  "E:\RCEP\data\sector_processed_data\FULL_result_Agri_k4.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP!=1
	rename iso3_d country 
	save "E:\RCEP\data\sector_processed_data\FULL_NORCEP_Agri_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_NORCEP_Agri_k4.xls", firstrow(variables) keepcellfmt replace
	
	
/*********2.3 Manufacturing*********/

****************************** PART (i) *****************************
use "E:\RCEP\data\sector_processed_data\RTAImpacts_Manufacturing_k4.dta",clear
rename Exp_cou exporter
rename Imp_cou importer
rename Year year
rename export trade
  
* Estimate the gravity model 
		ppml trade PAIR_FE1-PAIR_FE$NTij_1 EXPORTER_TIME_FE* IMPORTER_TIME_FE1-IMPORTER_TIME_FE$NT_yr rta1 rta2 rta3 rta4 , iter(35) noconst
* Save the estimation results 
			estimate store gravity_panel

***************************** PART (ii) *****************************
************************* GENERAL EQUILIBRIUM ANALYSIS *************************
* Step I: Solve the baseline gravity model
* Step I.a. Obtain estimates of trade costs and trade elasticities baseline indexes
                * Stage 1: Obtain the estimates of pair fixed effects and the effects of RTAs
* Alternatively recall the results of the gravity model obtained above 
				estimate restore gravity_panel
				scalar rta1_est = _b[rta1]
				scalar rta2_est = _b[rta2]
				scalar rta3_est = _b[rta3]
				scalar rta4_est = _b[rta4]
* Construct the trade costs from the pair fixed effects
					forvalues ijt = 1(1)$NTij_8{
						 cap qui replace PAIR_FE`ijt' = PAIR_FE`ijt' * _b[PAIR_FE`ijt']
					}	
					egen gamma_ij = rowtotal(PAIR_FE1-PAIR_FE$NTij )
						replace gamma_ij = . if gamma_ij == 1 & exporter != importer
						replace gamma_ij = 0 if gamma_ij == 1 & exporter == importer
					generate tij_bar = exp(gamma_ij)
					generate tij_bln = exp(gamma_ij + (rta1_est*rta1 + rta2_est*rta2+ rta3_est*rta3 + rta4_est*rta4))
                 
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
					replace tij_bln = tij_bar * exp((rta1_est*rta1 + rta2_est*rta2+ rta3_est*rta3 + rta4_est*rta4)) if tij_bln == .	
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
generate rta1_CFL = rta1
 replace rta1_CFL = 1 if RCEP == 1
generate rta2_CFL = rta2
 replace rta2_CFL = 0 if RCEP == 1
generate rta3_CFL = rta3
 replace rta3_CFL = 0 if RCEP == 1
generate rta4_CFL = rta4
 replace rta4_CFL = 0 if RCEP == 1
generate tij_CFL = tij_bar * exp( (rta1_est*rta1_CFL + rta2_est*rta2_CFL+ rta3_est*rta3_CFL + rta4_est*rta4_CFL)) 
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
save "E:\RCEP\data\sector_processed_data\before_iter_Manu_cluster4.dta", replace

****************************************************************************
	******************** Start of the Iterative Procedure  *********************
	* Set the criteria of convergence, namely that either the standard errors or
	* maximum of the difference between two iterations of the factory-gate 
	* prices are smaller than 0.01, where s is the number of iterations	
	
use  "E:\RCEP\data\sector_processed_data\before_iter_Manu_cluster4.dta", clear
		local s = 3	
		local sd_dif_change_pi = 1
		local max_dif_change_pi = 1
	  while (`sd_dif_change_pi' > 0.01) | (`max_dif_change_pi' > 0.02) {
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
	save "E:\RCEP\data\sector_processed_data\FULLGE_Manu_k4.dta", replace


* Step IV: Collect, construct, and report indexes of interest
	use "E:\RCEP\data\sector_processed_data\FULLGE_Manu_k4.dta", clear
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
	save "E:\RCEP\data\sector_processed_data\FULL_PROD_Manu_k4.dta", replace


	* Construct the percentage changes on import/consumption side
	use "E:\RCEP\data\sector_processed_data\FULLGE_Manu_k4.dta", clear
		collapse(mean) IMR_FULL IMR_CDL IMR_BLN, by(importer)
			rename importer country
			replace country = "DEU" if country == "ZZZ"
			sort country		

		* Conditional general equilibrium of inward multilateral resistances
			generate change_IMR_CDL = (IMR_CDL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
			
		* Full endowment general equilibrium of inward multilateral resistances
			generate change_IMR_FULL = (IMR_FULL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
	save "E:\RCEP\data\sector_processed_data\FULL_CONS_Manu_k4.dta", replace

	* Merge the general equilibrium results from the production and consumption
	* sides
	use "E:\RCEP\data\sector_processed_data\FULL_PROD_Manu_k4.dta", clear
		joinby country using "E:\RCEP\data\sector_processed_data\FULL_CONS_Manu_k4.dta"
		
		* Full endowment general equilibrium of real GDP
			generate rGDP_BLN = Y_BLN / (IMR_BLN ^(1 / (1 -sigma)))
			generate rGDP_FULL = Y_FULL / (IMR_FULL ^(1 / (1 -sigma)))
				generate change_rGDP_FULL = (rGDP_FULL - rGDP_BLN) / rGDP_BLN * 100

		* Keep indexes of interest	
			keep country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
			order country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
				
	* Export the results in Excel
	//total result
	save "E:\RCEP\data\sector_processed_data\FULL_result_Manu_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_Manu_k4.xls", firstrow(variables) keepcellfmt replace
	//RCEP country result
	use  "E:\RCEP\data\sector_processed_data\FULL_result_Manu_k4.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP == 1
	rename iso3_d country
	save "E:\RCEP\data\sector_processed_data\FULL_RCEP_Manu_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_RCEP_Manu_k4.xls", firstrow(variables) keepcellfmt replace
	//NO RCEP country result
	use  "E:\RCEP\data\sector_processed_data\FULL_result_Manu_k4.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP!=1
	rename iso3_d country 
	save "E:\RCEP\data\sector_processed_data\FULL_NORCEP_Manu_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_NORCEP_Manu_k4.xls", firstrow(variables) keepcellfmt replace
	

/*********2.4 Services*********/

****************************** PART (i) *****************************
use "E:\RCEP\data\sector_processed_data\RTAImpacts_Service_k4.dta",clear
rename Exp_cou exporter
rename Imp_cou importer
rename Year year
rename export trade
  
* Estimate the gravity model 
		ppml trade PAIR_FE1-PAIR_FE$NTij_1 EXPORTER_TIME_FE* IMPORTER_TIME_FE1-IMPORTER_TIME_FE$NT_yr rta1 rta2 rta3 rta4 , iter(35) noconst
* Save the estimation results 
			estimate store gravity_panel

***************************** PART (ii) *****************************
************************* GENERAL EQUILIBRIUM ANALYSIS *************************
* Step I: Solve the baseline gravity model
* Step I.a. Obtain estimates of trade costs and trade elasticities baseline indexes
                * Stage 1: Obtain the estimates of pair fixed effects and the effects of RTAs
* Alternatively recall the results of the gravity model obtained above 
				estimate restore gravity_panel
				scalar rta1_est = _b[rta1]
				scalar rta2_est = _b[rta2]
				scalar rta3_est = _b[rta3]
				scalar rta4_est = _b[rta4]
* Construct the trade costs from the pair fixed effects
					forvalues ijt = 1(1)$NTij_8{
						 cap qui replace PAIR_FE`ijt' = PAIR_FE`ijt' * _b[PAIR_FE`ijt']
					}	
					egen gamma_ij = rowtotal(PAIR_FE1-PAIR_FE$NTij )
						replace gamma_ij = . if gamma_ij == 1 & exporter != importer
						replace gamma_ij = 0 if gamma_ij == 1 & exporter == importer
					generate tij_bar = exp(gamma_ij)
					generate tij_bln = exp(gamma_ij + (rta1_est*rta1 + rta2_est*rta2+ rta3_est*rta3 + rta4_est*rta4))
                 
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
					replace tij_bln = tij_bar * exp((rta1_est*rta1 + rta2_est*rta2+ rta3_est*rta3 + rta4_est*rta4)) if tij_bln == .	
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
generate rta1_CFL = rta1
 replace rta1_CFL = 1 if RCEP == 1
generate rta2_CFL = rta2
 replace rta2_CFL = 0 if RCEP == 1
generate rta3_CFL = rta3
 replace rta3_CFL = 0 if RCEP == 1
generate rta4_CFL = rta4
 replace rta4_CFL = 0 if RCEP == 1
generate tij_CFL = tij_bar * exp( (rta1_est*rta1_CFL + rta2_est*rta2_CFL+ rta3_est*rta3_CFL + rta4_est*rta4_CFL)) 
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
save "E:\RCEP\data\sector_processed_data\before_iter_Service_cluster4.dta", replace

****************************************************************************
	******************** Start of the Iterative Procedure  *********************
	* Set the criteria of convergence, namely that either the standard errors or
	* maximum of the difference between two iterations of the factory-gate 
	* prices are smaller than 0.01, where s is the number of iterations	
	
use  "E:\RCEP\data\sector_processed_data\before_iter_Service_cluster4.dta", clear
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
	save "E:\RCEP\data\sector_processed_data\FULLGE_Service_k4.dta", replace


* Step IV: Collect, construct, and report indexes of interest
	use "E:\RCEP\data\sector_processed_data\FULLGE_Service_k4.dta", clear
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
	save "E:\RCEP\data\sector_processed_data\FULL_PROD_Service_k4.dta", replace


	* Construct the percentage changes on import/consumption side
	use "E:\RCEP\data\sector_processed_data\FULLGE_Service_k4.dta", clear
		collapse(mean) IMR_FULL IMR_CDL IMR_BLN, by(importer)
			rename importer country
			replace country = "DEU" if country == "ZZZ"
			sort country		

		* Conditional general equilibrium of inward multilateral resistances
			generate change_IMR_CDL = (IMR_CDL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
			
		* Full endowment general equilibrium of inward multilateral resistances
			generate change_IMR_FULL = (IMR_FULL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
	save "E:\RCEP\data\sector_processed_data\FULL_CONS_Service_k4.dta", replace

	* Merge the general equilibrium results from the production and consumption
	* sides
	use "E:\RCEP\data\sector_processed_data\FULL_PROD_Service_k4.dta", clear
		joinby country using "E:\RCEP\data\sector_processed_data\FULL_CONS_Service_k4.dta"
		
		* Full endowment general equilibrium of real GDP
			generate rGDP_BLN = Y_BLN / (IMR_BLN ^(1 / (1 -sigma)))
			generate rGDP_FULL = Y_FULL / (IMR_FULL ^(1 / (1 -sigma)))
				generate change_rGDP_FULL = (rGDP_FULL - rGDP_BLN) / rGDP_BLN * 100

		* Keep indexes of interest	
			keep country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
			order country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
				
	* Export the results in Excel
	//total result
	save "E:\RCEP\data\sector_processed_data\FULL_result_Service_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_Service_k4.xls", firstrow(variables) keepcellfmt replace
	//RCEP country result
	use  "E:\RCEP\data\sector_processed_data\FULL_result_Service_k4.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP == 1
	rename iso3_d country
	save "E:\RCEP\data\sector_processed_data\FULL_RCEP_Service_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_RCEP_Service_k4.xls", firstrow(variables) keepcellfmt replace
	//NO RCEP country result
	use  "E:\RCEP\data\sector_processed_data\FULL_result_Service_k4.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP!=1
	rename iso3_d country 
	save "E:\RCEP\data\sector_processed_data\FULL_NORCEP_Service_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_NORCEP_Service_k4.xls", firstrow(variables) keepcellfmt replace
	
/*********2.5 Intermediate*********/

****************************** PART (i) *****************************
use "E:\RCEP\data\sector_processed_data\RTAImpacts_INTL_k4.dta", clear
rename Exp_cou exporter
rename Imp_cou importer
rename Year year
rename export_int trade
  
* Estimate the gravity model 
		ppml trade PAIR_FE1-PAIR_FE$NTij_1 EXPORTER_TIME_FE* IMPORTER_TIME_FE1-IMPORTER_TIME_FE$NT_yr rta1 rta2 rta3 rta4 , iter(35) noconst
* Save the estimation results 
			estimate store gravity_panel

***************************** PART (ii) *****************************
************************* GENERAL EQUILIBRIUM ANALYSIS *************************
* Step I: Solve the baseline gravity model
* Step I.a. Obtain estimates of trade costs and trade elasticities baseline indexes
                * Stage 1: Obtain the estimates of pair fixed effects and the effects of RTAs
* Alternatively recall the results of the gravity model obtained above 
				estimate restore gravity_panel
				scalar rta1_est = _b[rta1]
				scalar rta2_est = _b[rta2]
				scalar rta3_est = _b[rta3]
				scalar rta4_est = _b[rta4]
* Construct the trade costs from the pair fixed effects
					forvalues ijt = 1(1)$NTij_8{
						 cap qui replace PAIR_FE`ijt' = PAIR_FE`ijt' * _b[PAIR_FE`ijt']
					}	
					egen gamma_ij = rowtotal(PAIR_FE1-PAIR_FE$NTij )
						replace gamma_ij = . if gamma_ij == 1 & exporter != importer
						replace gamma_ij = 0 if gamma_ij == 1 & exporter == importer
					generate tij_bar = exp(gamma_ij)
					generate tij_bln = exp(gamma_ij + (rta1_est*rta1 + rta2_est*rta2+ rta3_est*rta3 + rta4_est*rta4))
                 
				 * Stage 2: Regress the estimates of pair fixed effects on gravity variables and country fixed effects
* Perform the regression for the baseline year
					keep if year == 2017
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
					replace tij_bln = tij_bar * exp((rta1_est*rta1 + rta2_est*rta2+ rta3_est*rta3 + rta4_est*rta4)) if tij_bln == .	
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
generate rta1_CFL = rta1
 replace rta1_CFL = 1 if RCEP == 1
generate rta2_CFL = rta2
 replace rta2_CFL = 0 if RCEP == 1
generate rta3_CFL = rta3
 replace rta3_CFL = 0 if RCEP == 1
generate rta4_CFL = rta4
 replace rta4_CFL = 0 if RCEP == 1
generate tij_CFL = tij_bar * exp( (rta1_est*rta1_CFL + rta2_est*rta2_CFL+ rta3_est*rta3_CFL + rta4_est*rta4_CFL)) 
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
save "E:\RCEP\data\sector_processed_data\before_iter_INTL_cluster4.dta", replace

****************************************************************************
	******************** Start of the Iterative Procedure  *********************
	* Set the criteria of convergence, namely that either the standard errors or
	* maximum of the difference between two iterations of the factory-gate 
	* prices are smaller than 0.01, where s is the number of iterations	
	
use  "E:\RCEP\data\sector_processed_data\before_iter_INTL_cluster4.dta", clear
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
	save "E:\RCEP\data\sector_processed_data\FULLGE_INTL_k4.dta", replace


* Step IV: Collect, construct, and report indexes of interest
	use "E:\RCEP\data\sector_processed_data\FULLGE_INTL_k4.dta", clear
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
	save "E:\RCEP\data\sector_processed_data\FULL_PROD_INTL_k4.dta", replace


	* Construct the percentage changes on import/consumption side
	use "E:\RCEP\data\sector_processed_data\FULLGE_INTL_k4.dta", clear
		collapse(mean) IMR_FULL IMR_CDL IMR_BLN, by(importer)
			rename importer country
			replace country = "DEU" if country == "ZZZ"
			sort country		

		* Conditional general equilibrium of inward multilateral resistances
			generate change_IMR_CDL = (IMR_CDL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
			
		* Full endowment general equilibrium of inward multilateral resistances
			generate change_IMR_FULL = (IMR_FULL^(1/(1-sigma)) - IMR_BLN^(1/(1-sigma))) / IMR_BLN^(1/(1-sigma)) * 100
	save "E:\RCEP\data\sector_processed_data\FULL_CONS_INTL_k4.dta", replace

	* Merge the general equilibrium results from the production and consumption
	* sides
	use "E:\RCEP\data\sector_processed_data\FULL_PROD_INTL_k4.dta", clear
		joinby country using "E:\RCEP\data\sector_processed_data\FULL_CONS_INTL_k4.dta"
		
		* Full endowment general equilibrium of real GDP
			generate rGDP_BLN = Y_BLN / (IMR_BLN ^(1 / (1 -sigma)))
			generate rGDP_FULL = Y_FULL / (IMR_FULL ^(1 / (1 -sigma)))
				generate change_rGDP_FULL = (rGDP_FULL - rGDP_BLN) / rGDP_BLN * 100

		* Keep indexes of interest	
			keep country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
			order country Y_BLN change_Xi_CDL change_Xi_FULL change_price_FULL change_IMR_FULL change_OMR_FULL change_rGDP_FULL 
				
	* Export the results in Excel
	//total result
	save "E:\RCEP\data\sector_processed_data\FULL_result_INTL_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_INTL_k4.xls", firstrow(variables) keepcellfmt replace
	//RCEP country result
	use  "E:\RCEP\data\sector_processed_data\FULL_result_INTL_k4.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP == 1
	rename iso3_d country
	save "E:\RCEP\data\sector_processed_data\FULL_RCEP_INTL_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_RCEP_INTL_k4.xls", firstrow(variables) keepcellfmt replace
	//NO RCEP country result
	use  "E:\RCEP\data\sector_processed_data\FULL_result_INTL_k4.dta", replace
	rename country iso3_d
    gen RCEP=0 
    replace RCEP=1 if iso3_d == "JPN"|iso3_d == "KOR"|iso3_d == "AUS"|iso3_d == "NZL"|iso3_d == "BRN"|iso3_d == "KHM"|iso3_d == "IDN"|iso3_d == "LAO"|iso3_d == "MYS"|iso3_d == "PHL"|iso3_d == "SGP"| iso3_d == "MMR"|iso3_d == "THA"|iso3_d == "VNM"|iso3_d	==	"CHN"
	keep if RCEP!=1
	rename iso3_d country 
	save "E:\RCEP\data\sector_processed_data\FULL_NORCEP_INTL_k4.dta", replace
	export excel using  "E:\RCEP\data\sector_output\FULL_NORCEP_INTL_k4.xls", firstrow(variables) keepcellfmt replace
	


