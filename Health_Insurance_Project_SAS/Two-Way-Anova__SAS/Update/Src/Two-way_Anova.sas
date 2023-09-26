/******************
Input: famsize_exp.csv
Output: Famsize_Exp_Two-way_Anova.pdf
Written by:Tingwei Adeck
Date: Sep 25th 2023
Description: Two-way Anova to see if there is any other variable associated with family size in determining 
health expenses
Dataset description: Insurance data set obtained from kaggle. The data_dic will be provided.
Results: See that region and family size interact significantly at the 0.05 level. It is interesting.
******************/

%let path=/home/u40967678/sasuser.v94;


libname healthi
    "&path/sas_umkc/input";
    
filename famexp
    "&path/sas_umkc/input/famsize_exp.csv";   
    
ods pdf file=
    "&path/sas_umkc/output/Famsize_Exp_Two-way-Anova.pdf";
    
options papersize=(8in 11in) nonumber nodate;

proc import file= famexp
	out=healthi.famexp
	dbms=csv
	replace;
	delimiter=",";
run;

*Two way Anova to uncover any interactions between fam size and BMI;
proc anova data=healthi.famexp;
class Fam_size_exp BMI_codeverbose;
model expenses = Fam_size_exp BMI_codeverbose Fam_size_exp*BMI_codeverbose;
means Fam_size_exp BMI_codeverbose / tukey cldiff;
run;

*Two way Anova to uncover any interactions between;
*significant association between family size and region at the 0.05 level;
proc anova data=healthi.famexp;
class Fam_size_exp region;
model expenses = Fam_size_exp region Fam_size_exp*region;
means Fam_size_exp region / tukey cldiff;
run;

*Two way Anova to uncover any interactions between fam size and sex;
proc anova data=healthi.famexp;
class Fam_size_exp sex;
model expenses = Fam_size_exp sex Fam_size_exp*sex;
means Fam_size_exp sex / tukey cldiff;
run;
ods pdf close;


