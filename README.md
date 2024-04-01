# RCEP-research
This is the Code and data for the essay "General equilibrium analysis of the effect of RCEP on trade flow and welfare". The structure of this file consisits of three parts: the essay, code and processed data. 

*1. RCEP_essay*  
You can view the essay first. We conduct counterfactual simulation analysis based on the structural gravity model, to explore the effect of RCEP on trade flow and welfare between member countries and non-member countries.

*2. code*   
This file provides the stata and R code for this essay. The file structure is as follows:  
  "TIVA_data_cleaning.do" & "TiVA_analysis.do": stata code for the first type of counterfactual.  
  "TIVA_data_cleaning.do" & "TiVA_analysis.do": stata code for the second type of counterfactual.  
  "kmean++_cluster.Rmd" : R code for kmean++ algorithm, to divide RTAs into 4 clusters.  

*3. Processed Data*   
This file provides the data for this essay:
  "export_latest.dta" : final dataset for the first type of counterfactual.  
  "export_Cluster4.dta": final dataset for the second type of counterfactual.  
