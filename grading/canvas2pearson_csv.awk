BEGIN{

    # version 1.1, 05 Sept 2022
    #   fixed some input issues for feeding into the read_gradebook.awk script
    #   skip the "Perfect, Student" since "Test" or "Points Possible" is already
    #   in the canvas data.
    
    FS=","
    # Canvas uses "Last, First" in one column for student names
    # "Last, First" --> First, Last
    # Canvas uses "SIS User ID" for the student id column
    # Canvas uses "Points Possible" in the name column
}
(NR==1){
    printf("First Name,Last Name");
    
    for(i=2;i<NF+1;i++){
	if ( $i == "ID" || $i == " ID") $i="NNNN";
	if ( $i == "SIS User ID" || $i == " SIS User ID"){
	    $i="StudentID";
	    id_col_num=i;
	}
	if ( $i == "SIS Login ID" || $i == " SIS Login ID") $i="Login";
	printf(",")
	
	# nf=split($i,a,"("); # some column names are e.g. "Homework 2 (1363755)"
	# for(j=1;j<nf;j++) gsub(/\s+/,"",a[j]); # get rid of all spaces
	# if ( debug ) printf("[ i= %d  nf= %d ",i,nf)
	# if ( nf <= 1 ) printf("%s",a[1]);
	# if ( nf > 1 ) for(j=1;j<nf;j++) printf("%s",a[j]);
	# if ( debug ) printf(" string=%s]",$i);

	if ( $i ~ /CH/ || $i ~ /Ch/ || $i ~ /HW/ || $i ~ /Exam/ || $i ~ /EXAM/ ){
	    gsub(/\s+/,"",$i); # get rid of all spaces
	    # just print the first six characters of any other heading
	    # out=substr($i,1,6);
	    # make them upper case for the .org file
	    out=toupper(substr($i,1,6));
	    printf("%s",out);
	} else {
	    printf("%s",$i);
	}
    }
    printf("\n");
}
(NR==2){
    printf("perfect,perfect");
    for(i=2;i<NF+1;i++){
	printf(",");
	if ( i==id_col_num ) printf("10000000");
	else printf("%s",$i);
    }
    printf("\n");
}

(NR>2 && NF>4 && $1 !~ /Student/){
    n0 = gsub(" ","",$0);
    n1 = gsub("\"","",$2);
    n2 = gsub("\"","",$1);
    # ind = index($2,"\""); printf("ind = %d\n",ind)
    printf("%s,%s",$2,$1)
    # printf("%d  %d\n",n1, n2);
    for(i=3;i<NF+1;i++){
	if ( $i == "" || $i == " " ) printf(",0.00");
	else printf(",%s",$i);
    }
    printf("\n");
}
