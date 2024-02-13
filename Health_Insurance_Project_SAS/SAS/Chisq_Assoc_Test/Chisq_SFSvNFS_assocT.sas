* author: Tingwei Adeck
* date: created 2022-11-20
* purpose: perform a chi-square analysis on a large insurance data set
*SFS vs NFS;

%let path=/home/u40967678/sasuser.v94;


libname chisq
	"&path/sas_umkc/input";
    
filename chisqtoa
    "&path/sas_umkc/input/sfs_nfs.txt";   
    
ods pdf file=
    "&path/sas_umkc/output/Chisq_SFSVNFS_analysis.pdf";
    
options papersize=(8in 11in) nodate nonotes;


data chisq.chisqtoa;
  infile chisqtoa dlm=',';
  input 
   Expense_code $
   Expense_code_num	
   Group $
   group_code	
   Freq;

label
   Expense_code="above or below average health expense"
   Expense_code_num="1=above vs 0=below"
   Group="family size levels"
   group_code="code for famsize: 1=small,2=normal,3=large"
   Freq="count or frequency by famsize level";
   
run;

data chisq.chisqtoa_clean;
	set chisq.chisqtoa;
		if Group EQ 'Group' then delete;
run;

title "Print the SFS vs NFS data";
proc print
  data=chisq.chisqtoa_clean;
run;

*SFS vs LFS;
title "SFS vs NFS";
proc freq data = chisq.chisqtoa_clean;
	tables Group*Expense_code /chisq;
	weight Freq;
run;

ods pdf close;
