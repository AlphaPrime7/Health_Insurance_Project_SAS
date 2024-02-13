/******************
Input: famsize_expense_final.csv
Output: Famsize_Exp_Anova-KW_Analysis.pdf
Written by:Tingwei Adeck
Date: Dec 29 2022
Description: Analysis of the effect of family size on health expenses
Dataset description: Insurance data set obtained from kaggle. The data_dic will be provided.
Results: Seminal paper in data analysis
******************/

%let path=/home/u40967678/sasuser.v94;


libname healthi
    "&path/sas_umkc/input";
    
filename famexp
    "&path/sas_umkc/input/famsize_exp.csv";   
    
ods pdf file=
    "&path/sas_umkc/output/Famsize_Exp_Anova-KW_Analysis.pdf";
    
options papersize=(8in 11in) nonumber nodate;

proc import file= famexp
	out=healthi.famexp
	dbms=csv
	replace;
	delimiter=",";
run;

*A quick look at the data following some corrections on recoding SFS into SFS_AA and SFS_BA;
proc univariate data=healthi.famexp;
	class Fam_size_exp;
    var expenses;
    histogram expenses;
run;

*A quick look at the data following some corrections on recoding SFS into SFS_AA and SFS_BA;
proc univariate data=healthi.famexp;
	class Fam_size_exp;
    var expenses;
    histogram expenses / overlay;
run;

*A way to print out the first five obs;
title 'first 5 observations using _N_';
data healthi.first_five;
set healthi.famexp;
	if _N_ le 5 then output;
run;


*Anova-All assumptions have been checked;
title "Anova using PROC ANOVA (Family_size-Expense)";
proc ANOVA data=healthi.famexp;
class Fam_size_exp;
model expenses = Fam_size_exp;
means Fam_size_exp / scheffe cldiff; 
run;

*Kruskal_Wallis-Non-parametric unpaired Anova;
*statistically significant difference between mean ranks of LFS vs NFS or SFS_BA
the only exception seen is SFS_AA being significantly higher than LFS and NFS
interpreted as SFS can be devided into a health-centric group and non-health centric group while the NFS and LFS behave normally and are associated
as seen with the Chi-sq test;
title "Kruskal-Wallis (Family_size-Expense)";
proc npar1way data=healthi.famexp wilcoxon dscf;
    class Fam_size_exp;
    var expenses;
run;

ods pdf close;


