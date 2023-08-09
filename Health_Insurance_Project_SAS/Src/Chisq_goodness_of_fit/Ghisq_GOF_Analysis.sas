* author: Tingwei Adeck
* date: created 2022-11-20
* purpose: perform a chi-square analysis on a large insurance data set
* license: public domain
*Goodness of fit test for familysize_expense variables;

options papersize=(6in 4in);

%let path=/home/u40967678/sasuser.v94;
  
libname chisq
	"&path/sas_umkc/input";

ods pdf file=
    "&path/sas_umkc/output/insursas_chisq.pdf";


data chisq.chisq_gof;
  input 
    Category: $6.
    Cat_code
    Freq
    Exp_prop: percent6.
    Exp_Freq;
    
  datalines;
	SFS_AA 1 210.00 1667% 172.1666667
	NFS_AA 2 190.00 1667% 172.1666667
	LFS_AA 3 85.00 1667% 172.1666667
	SFS_BA 4 248.00 1667% 172.1666667
	NFS_BA 5 234.00 1667% 172.1666667
	LFS_BA 6 66.00 1667% 172.1666667
	;

run;

proc format;
picture mypct (round) low-high='009.99%'; 
run;

proc datasets lib=chisq nolist;
modify chisq_gof;
format Exp_prop mypct.;
run;


proc print data= chisq.chisq_gof(obs=6);
title1 "chi-sq goodness of fit Set-up";
run;

/*perform Chi-Square Goodness of Fit test-Equal proportions*/
proc freq data=chisq.chisq_gof;
	tables Category / chisq;
	weight Freq;
title2 "chi-sq goodness of fit analysis-EP proper";
run;

/*perform Chi-Square Goodness of Fit test-Unequal proportions*; LFSA>NFSA>SFSA & LFSB<NFSB<SFSB*/
proc freq data=chisq.chisq_gof;
	tables Category / TestP=(0.30 0.05 0.20 0.10 0.15 0.20) nocum;
	weight Freq;
ods output OneWayFreqs=chisq.FreqOut;
output out=chisq.FreqStats N ChiSq;
title2 "chi-sq goodness of fit analysis-UP proper";
run;

/* create macro variables for sample size and chi-square statistic */
data _NULL_;
   set chisq.FreqStats;
   call symputx("NumObs", N);         
   call symputx("TotalChiSq", _PCHI_);
run;

proc print data=chisq.FreqStats;
title2 "chi-sq GOF Freq statistics";
run;
 
/* compute the proportion of chi-square statistic that is contributed
   by each cell in the one-way table */
data chisq.chisq_debug;
   set chisq.FreqOut;
   ExpectedFreq = &NumObs * TestPercent / 100;
   Deviation = Frequency - ExpectedFreq;
   ChiSqContrib = Deviation**2 / ExpectedFreq;  /* (O - E)^2 / E */
   ChiSqPropor = ChiSqContrib / &TotalChiSq;    /* proportion of chi-square contributed by this cell */
   format ChiSqPropor 5.3;
run;

proc print data=chisq.chisq_debug; 
title2 "chi-sq GOF Debug-All attributes";
run;
 
proc print data=chisq.chisq_debug; 
   var F_Category Category Frequency TestPercent ExpectedFreq Deviation ChiSqContrib ChiSqPropor; 
title2 "chi-sq GOF Debug";
run;


proc sgplot data=chisq.chisq_debug;
   vbar F_Category / response=ChiSqPropor datalabel=ChiSqPropor;
   xaxis discreteorder=data;
   yaxis label="Proportion of Chi-Square Statistic" grid;
title2 "Proportion of Chi-Square Statistic for Each Category";
run;

ods pdf close;
