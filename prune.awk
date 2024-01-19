BEGIN{
  # prune.awk
  #
  # version 2.0  21 April 2015
  #
  # prunes data points out of a file when grad students
  # and postdocs take data at the maximum rate
  # and generate gigabyte data files
  #

  # assumes input is "x y" file and calculates the arc length of
  # the data (S) and then sets two variables to prune the data
  #
  # print every 'prune' points, but only if dS < pct*S.
  #

  # COMMAND LINE
  # prune = 10; # prints every tenth line
  # pct = 0.01; # 0.01 one percent change in S or DX or DY
  # debug

    if ( prune == 0 ) prune = 10;
    if ( pct == 0 ) pct = 0.01;

    MAXDATA=100000;
    X[MAXDATA];
    Y[MAXDATA];
    dX[MAXDATA];
    dY[MAXDATA];
    DS[MAXDATA];
    count=1;
    prtcount=0;

    xmin= 1e99; xmax= -1e99;
    ymin= 1e99; ymax= -1e99;

}

(NF==2){
    X[count]=$1; Y[count]=$2;
    count++;
}

END{

    if ( debug ) printf("Found %d data points\n",count-1);

    for(i=1;i<count;i++){
	if ( X[i] > xmax ) xmax=X[i];
	if ( Y[i] > ymax ) ymax=Y[i];
	if ( X[i] < xmin ) xmin=X[i];
	if ( Y[i] < ymin ) ymin=Y[i];
    }
    DX = xmax - xmin;
    DY = ymax - ymin;
    pctDX = pct*DX;
    pctDY = pct*DY;
    if ( debug ) {
	printf("xmin  = %12.4e    ymin = %12.4e\n",xmin,ymin);
	printf("xmax  = %12.4e    ymax = %12.4e\n",xmax,ymax);
	printf("DX    = %12.4e      DY = %12.4e\n",DX,DY);
	printf("pctDX = %12.4e   pctDY = %12.4e\n",pctDX,pctDY);
    }
    
    # calculate the approx arc length
    S = 0;
    for(i=2;i<count;i++){
	dx = X[i] - X[i-1];
	dy = Y[i] - Y[i-1];
	dX[i] = dx;
	dY[i] = dy;
	DS[i] = sqrt( dx^2 + dy^2 );
	S += DS[i];
    }
    pctS  = pct*S;
    dS_ave = S / count;
    if ( debug ) printf("S      = %12.4e\n",S);
    if ( debug ) printf("pct*S  = %12.4e\n",pctS);
    if ( debug ) printf("dS_ave = %12.4e\n",dS_ave);
    
    # print out points
    # always print the first point
    printf("%12.4e %12.4e\n",X[1],Y[1]);
    # START FROM 2 ON PURPOSE HERE!!
    for(i=2;i<count;i++){
	if ( i%prune==0 || DS[i] > pctS ||
	     dX[i] > pctDX || dY[i] > pctDY ) {
	    prtcount++;
	    if ( debug ) printf("%12.4e %12.4e %12.4e %12.4e %12.4e\n",X[i],Y[i],dX[i],dY[i],DS[i]);
	    else printf("%12.4e %12.4e\n",X[i],Y[i]);
	}
    }
    if ( debug ) printf("print count = %d\n",prtcount);
}
