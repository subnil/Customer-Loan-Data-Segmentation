proc import datafile='Z:\Assignments\Graded Assignment\Topic 11.2 -Decision Trees\Credit - Data to be used for Clustering.csv'
out=cc
DBMS=csv replace;
GETNAMES=YES;
run;

data cc1;
set cc;
id=_N_;
run;

data cc2;
set cc1;
new_monthly_income=input(Monthlyincome,best12.);
new_noofdependents=input(NumberofDependents,best4.);
run;

Proc means data=cc2 nmiss;
run;

data cc2;
set cc2;
if missing(NPA_STATUS) then delete;
if new_monthly_income=. then new_monthly_income=0;
run;

Proc freq data=cc2;
table  Gender Region  Rented_OwnHouse Occupation Education;
run;

proc contents data=cc2;
run;

data cc2;
set cc2;
drop monthlyincome1 ;
run;

data cc2;
set cc2;
if new_monthly_income>100000 then delete;
run;

/* Data Preparation */

Data cc2;
set cc2;


/*Gende*/

if Gender='Male' then gender1=1;
else Gender1=0;


/* Region */


if Region='East' then east1=1;
else east1=0;
if Region='North' then north1=1;
else north1=0;
if Region='West' then west1=1;
else west1=0;
if region='South' then south1=1;
else south1=0;
if region='Centr' then centr1=1;
else centr1=0;

/* House ownership status */

if Rented_OwnHouse= 'Ownhouse' then house1=1;
else house1=0;

/* Education */

if Education='Matric' then matric_dummy=1;
else matric_dummy=0;
if Education= 'Graduate' then graduate_dummy=1;
else graduate_dummy=0;
if Education='Post-Grad' then pg_dummy=1;
else pg_dummy=0;
if Education='PhD' then phd_dummy=1;
else phd_dummy=0;
if Education='Professional' then prof_dummy=1;
else prof_dummy=0;


/* Occupation */
if Occupation= 'Self_Emp' then self_dummy=1;
else self_dummy=0;
if Occupation='Officer1' then officer1_dummy=1;
else officer1_dummy=0;
if Occupation='Officer2' then officer2_dummy=1;
else officer2_dummy=0;
if Occupation='Officer3' then officer3_dummy=1;
else officer3_dummy=0;
if Occupation='Non-offi' then nonoffi_dummy=1;
else nonoffi_dummy=0;
/* No of Dependent */
if new_noofdependents=. then new_noofdependents=0;
if new_noofdependents>10 then delete;
run;




/* Standererised dataset */

proc standard data= cc2 mean=0 std=1 out=cc3;
var  age new_monthly_income new_noofdependents matric_dummy--prof_dummy;
run;

/* weighting the variable */

data cc3; 
set cc3;
new_noofdependents2=new_noofdependents*2;
run;

proc fastclus data=cc3 maxclusters=8 converge=0 maxiter=50 out=cc4 outstat=cc5;
var age new_monthly_income  new_noofdependents2;
run;

/* Profiling */
data cc4;
set cc4;
keep id cluster;
Proc sort data=cc4;
by id;
proc sort data=cc2;
by id;
run;

data cc6;
merge CC2(in=a) cc4(in=b);
by id;
if (a AND B);
run;

/* Cluster mean */
proc sort data=cc6;
by cluster;
proc means data=cc6 mean;
var age new_monthly_income new_noofdependents;
by cluster;
run;


proc means data=cc6 mean std;
var age new_monthly_income new_noofdependents;
run;

proc freq data=cc6;
table cluster*NPA_Status;
run;




