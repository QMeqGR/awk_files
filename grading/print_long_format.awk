#
# Print the scores for students in long format. This script takes as input
# the output from 'read_gradebook_csv.awk' and depends on that file format.
#
# E.H. Majzoub, University of Missouri (STL)
#
# version 1.0 28 Sept 2023
#
#
BEGIN{
    if ( !debug ){ debug=0; }
    if ( !split_on ){ split_on=3; }
    if ( !max_cols ){ max_cols=4; }
    if ( !include_names ){ include_names=0; }
    if ( !print_pct ){ print_pct=0; } # print % of score instead of points
    r=1; # row counter
}
(NR==1){
    for(i=1;i<NF+1;i++){ header[i]=$i; }
    cols=NF;
}
(NR>1){
    # the first row read here (r==1) will be 'Test Perfect'
    for(i=1;i<NF+1;i++){ dat[r,i]=$i; }
    r++;
}
END{
    if ( debug ) printf("Found %d rows of data (not including header)\n",r-1);
    for(j=1;j<r;j++){
	if ( include_names ) printf("\n[%-s:  %s, %s]\n",dat[j,3],toupper(dat[j,2]),dat[j,1]);
	else printf("\n[%s]\n",dat[j,split_on]);
	col_count=0;
	for(i=split_on+1;i<cols+1;i++){
	    if ( i == cols ) {
		printf("%9s: %7s  ",header[i],dat[j,i]); col_count++;
	    }
	    else {
		if ( print_pct ) {
		    printf("%9s: %7.1f%%  ",header[i],100*dat[j,i]/dat[1,i]); col_count++;
		}
		else {
		    printf("%9s: %7.3f  ",header[i],dat[j,i]); col_count++;
		}
	    }
	    if ( col_count == max_cols ){ printf("\n"); col_count=0; }
	}
	printf("\n");
    }
}
