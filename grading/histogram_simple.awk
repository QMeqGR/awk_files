#!/bin/gawk

BEGIN{

# set on command line
# col=3; take histogram on column 3
# nbins=11
# xmin=0, xmax=100. (e.g. grades)

if ( !col ) col=1;
if ( !debug ) debug=0;
if ( !xmin ) xmin=0;
if ( !xmax ) xmax=100;
if ( !nbins ) nbins=11;
    
MAXDATA=50000;
c[MAXDATA];
n[MAXDATA];
cmin=100;
cmax=0;
col=1;
count=0;
ctot=0;

if ( !col ){
	printf("!! must set col on command line. Exiting.\n");
	exit;
  }
}

( NF>=col && $col>0 ){ c[count++]=$col; ctot=ctot+$col; }

END{
    if(debug>0){
	printf("###########################################\n");
	printf("# file created with histogram_simple.awk  #\n");
	printf("###########################################\n");
	printf("# Found %d data points\n",count);
	printf("# debug = %f\n",debug);
	printf("# xmin = %f\n",xmin);
	printf("# xmax = %f\n",xmax);
    }
    for(i=0;i<count;i++){
	if ( c[i] > cmax ) cmax=c[i];
	if ( c[i] < cmin ) cmin=c[i];
    }

    xdomain = xmax-xmin;
    width = xdomain/nbins;
    crange = cmax-cmin;
    if (debug){
	printf("# using bin width= %f\n",width);
	printf("# xdomain= %f   (plot domain)\n",xdomain);
	printf("# cmin= %f   cmax=%f\n",cmin,cmax);
	printf("# spread= %f. Using nbins= %d\n",crange,nbins);
	printf("# Using %d data bins\n",nbins);
    }
    
    for(i=0;i<count;i++){
	n[ int( c[i]/width ) ]++;
    }

    printf("# average: %f\n", ctot/count);
    printf("# score      num_ppl   cumul    %%cum \n");
    cum=count;
    for(i=0;i<nbins;i++){
	if (i>0) cum=cum-n[i-1];
	printf("%10.2f%7d%10d%10.1f\n",width*i+width/2,n[i],cum,100*cum/count);
    }

}
