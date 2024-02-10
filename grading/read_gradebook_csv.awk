  BEGIN{

      version=1.4.4;

      # version 1.4.4, 13 Sep 2023
      #   increment the 'completion' of a student's assignment only if they
      #   obtain a score of COMP_PCT of the total possible score. I did this
      #   because Pearson's calculated completion rate is a lot lower than
      #   mine. ( COMP_PCT * stu[perfect_row_num,i] ) I currently have this
      #   set at 0.40, which should be easily acheivable given the number of
      #   attempts I allow on the Pearson system. 
      # 
      # version 1.4.3, 4 Sep 2023
      #   print integer for ID
      #
      # version 1.4.2, 9 May 2023
      #   change grade scale so .90 is an A- instead of a B+, etc.
      #
      # version 1.4.1, 13 Apr 2023
      #   fix error calculating the standard deviation when skipzeros is set
      #
      # version 1.4, 03 Apr 2023
      #   add calculation of completion percentage for the homeworks/exams.
      #
      # version 1.3, 12 Nov 2022
      #   make the skip_ppl variable a comma separated list so multiple students
      #     can be skippped (for those who dropped, etc.)
      #
      # version 1.2, 05 Sept 2022
      #   make skipping zeros explicit with the variable skipzeros
      #   
      # version 1.1, 01 Sept 2022
      #   added code for truncation (truncate variable) of column names
      #   added code (gensub call) to replace spaces with underscore _ for student names
      #   fixed grade assignment if pct is identically zero.
      # version 1.0, 2021

      # Notes:
      # 1. Pearson's gradebook export only outputs homeworks and exams that are past
      #    their due date. If something is not yet due it won't be in the exported data.
      #    If you use a header for one of these columns that is not yet output it will
      #    choke this program. 
      
      FS=","
      # debug=2
      # This script reads the csv file from the 'gradebook' in Pearson Mastering Physics.
      # To process Canvas gradebook data you must first use the canvas2pearson.awk script
      # to convert it to Pearson's format.

      
      # Set these by hand by looking at the csv file
      # SET THESE ON THE COMMAND LINE 

      # cavnas = 1; pearson = 0;
      # col_names_row = 4
      # frst_head="Ch 01 HW" # where the 1st homework column starts
      # last_head="Ch 15 HW" # location of last data column
      # thru="Ch 06 HW" # stop where assignments haven't been given
      # skip_ppl="Heye,Johnson,Smith,Parker" # names to skip on output (TAs, people who dropped, etc)
      # no_name=1, or 0. If 1, then no_name_col=3, and if 0 no_name_col=1

      skipzeros = 1; # skip scores of 0 when calculating averages
      if ( !truncate ) truncate = 50; # truncate the column names to so many characters
      
      if ( no_name == 1 ) no_name_col=3;
      if ( no_name == 0 ) no_name_col=1;
      if ( !skip_ppl ) skip_ppl=0;
      if ( thru == "" ){ thru = last_head }

      if ( skip_ppl ){
	  num_skips = split(skip_ppl,skip_person,",")
      }
      
      # All data will be read into the array stu[,]
      # We then process the data and add the rows and columns
      # for the statistics.
      add_cols = 3; # for total_points, percentage, final_grade
      add_rows = 3; # for averages, standard deviations, and completion percent
      
      stu_start = col_names_row + 1
      n_stud=0;

      if ( canvas == 1 )  pearson == 0;
      if ( pearson == 1 ) canvas == 0;

      if ( COMP_PCT == "" ) COMP_PCT=0.40;
  }
#------------------------------------------------------------------------
  (NR==col_names_row && NF>0){
      n_cols = NF
      if ( debug > 2 ) {
	  printf("col_names_row= %d is shown below.\n",col_names_row);
	  printf("%s\n",$0);
	  printf("Reading column names.\n");
      }
      for(i=1;i<n_cols+1;i++){
	  # col_name[i] = $i;  # v1.1 change
	  col_name[i] = substr($i,1,truncate);
	  if ( debug ) printf("col_name[%d]= %s\n",i,col_name[i]);
	  stu[NR,i] = $i;
	  if ( $i == frst_head ){ beg_col=i; if (debug) printf("Found beg_col.\n") }
	  if ( $i == last_head ){ end_col=i; if (debug) printf("Found end_col.\n") }
      }
  }
  (NR>col_names_row && NF>0){ # this sections reads in the student data
      n_stud++; # start counting no of students from here
      if ( debug ) printf("Checking for skips (people who dropped etc.) so they are not counted in the stats.\n")
      for ( ss=0; ss<num_skips; ss++ ){
	  if ( $1 ~ skip_person[ss+1] || $2 ~ skip_person[ss+1] ) next;	  
      }
      for(i=1;i<n_cols+1;i++){
	  # stu[NR,i] = $i;
	  stu[NR,i] = gensub(" ","_","g",$i); # replace spaces in names with _ , v1.1 change
      }
      if ( debug ) printf("student number %2d Name %s\n",n_stud, stu[NR,2]);
  }
  (NF>col_names_row && $1!=""){ n_rows = NR }
  ($5 ~ /Assigned/ && pearson==1){stu[NR,1]="perfect"; stu[NR,2]="perfect"; perfect_row_num=NR;}
  ($5 ~ /Average/ && pearson==1){exit} # this is the last line in the file
  ($1 == "perfect" && canvas==1){perfect_row_num=NR;}
#------------------------------------------------------------------------
  END{
      if ( debug ) printf("frst_head= %s     last_head= %s     thru=%s\n",frst_head,last_head,thru)
      n_stud = n_stud - 1; # row "Average" over counts by 1
      if ( debug ) printf("number of students = %d\n",n_stud);
      if ( debug ) printf("n_rows= %d    n_stud= %d    stu_start= %d\n",n_rows, n_stud, stu_start)
      # Note carefully the staring and stopping numbers
      # stu_start --> n_stud+stu_start
      if ( debug > 2 ) for(j=stu_start;j<stu_start+n_stud+1;j++){printf("Student %d is %s\n",j,stu[j,2])}
      # These three numbers determine the location of the data in the raw
      # input array stu[,]
      if ( debug ) printf("beg_col = %d     end_col=%d\n",beg_col,end_col)
      if ( debug ) printf("perfect_row_number = %d\n",perfect_row_num)
      # Set the names for perfect
      stu[perfect_row_num,1] = "Test"
      stu[perfect_row_num,2] = "Perfect"
      stu[perfect_row_num,3] = "10000000"

      
      # post-process the column headers
      for(i=1;i<n_cols+1;i++){
	  if ( debug > 2 ) printf("col %d has name %s\n",i,col_name[i]);
	  if ( debug > 2 ) printf("replacing spaces with underlines\n");
	  temp = col_name[i];
	  stu[col_names_row,i] = col_name[i] = gensub(" ","","g",temp);
	  if ( debug >2 ) printf("col %d has name %s\n",i,col_name[i]);
      }

      # Calculate the average of the scores, and the completion percentage
      for(i=beg_col;i<end_col+1;i++){
	  ave[i]=0; n0[i]=0;
	  if ( debug ){
	      printf("Averaging col %d, col_name= %s\n",i,col_name[i])
	  }
	  for(j=stu_start;j<stu_start+n_stud;j++){
	      if ( stu[j,i] == 0.0 && skipzeros == 1 ) {n0[i]++;}
	      ave[i] += stu[j,i];
	      # if ( stu[j,i] > 0.0 ) { comp[i]++; }
	      if ( stu[j,i] > COMP_PCT * stu[perfect_row_num,i] ) { comp[i]++; }
	      if ( debug ) printf("-- ave: stu[%3d,%3d]=%4.2f    ave[%3d]=%8.2f   n0[%d]=%4d    comp[%d]=%d\n",
				  j,i,stu[j,i],i,ave[i],i,n0[i],i,comp[i])
	  }
	  if ( skipzeros==1 )  ave[i] = ave[i] / (n_stud - n0[i]); 
	  if ( skipzeros==0 )  ave[i] = ave[i] / n_stud;
	  comp[i] = comp[i]/n_stud;
	  if ( debug ) printf("----- Average col %d : %f   skipzeros=%d    n0[%d]=%d    comp[%d]=%.2f\n",
			      i,ave[i],skipzeros,i,n0[i],i,comp[i]);
      }
      # Calculate the standard deviations of the scores
      for(i=beg_col;i<end_col+1;i++){
	  std[i]=0;
	  if ( col_name[i] ~ /Name/ || col_name[i] ~ /ID/ || col_name[i] ~ /Perfect/ ||
	       col_name[i] ~ /Test/ ) continue;
	  for(j=stu_start;j<n_stud+stu_start;j++){
	      if ( skipzeros==0 || ( skipzeros==1 && stu[j,i]>0.0 ) ){ std[i] += ( stu[j,i] - ave[i] )**2; }
	      if ( debug >2 ) printf("stu[%d,%d]=%f  ave[%d]=%f   std[%d]=%f   n_stud=%d\n",
				     j,i,stu[j,i],i,ave[i],i,std[i], n_stud)
	  }
	  if ( debug >2 ) printf("!!!!!!!!!!!!!!!!!!!!! skipzeros = %d   n_stud-n0 = %d\n",
				 skipzeros,n_stud-n0[i])
	  if ( skipzeros==1 ) std[i] = sqrt( std[i] / (n_stud - n0[i]) );
	  if ( skipzeros==0 ) std[i] = sqrt( std[i] / n_stud );
	  if ( debug ) printf("----- Std dev col %d : %f\n",i,std[i]);
      }

      # add these rows to the stu array
      for(i=beg_col;i<end_col+1;i++){
	  stu[n_stud+stu_start+1,i] = ave[i];
	  stu[n_stud+stu_start+2,i] = std[i];
	  stu[n_stud+stu_start+3,i] = comp[i];
      }
      stu[n_stud+stu_start+1,1] = "---";
      stu[n_stud+stu_start+1,2] = "Average";
      stu[n_stud+stu_start+1,3] = "19999999";
      stu[n_stud+stu_start+2,1] = "---";
      stu[n_stud+stu_start+2,2] = "Stand_Dev";
      stu[n_stud+stu_start+2,3] = "19999999";
      stu[n_stud+stu_start+3,1] = "---";
      stu[n_stud+stu_start+3,2] = "Comp_pct";
      stu[n_stud+stu_start+3,3] = "19999999";
      # printf("n_stud+stu_start+1=%d\n",n_stud+stu_start+1)
      # printf("stu row +1 = %s\n",stu[n_stud+stu_start+1,2])

      # calculate the total number of points earned.
      # The +2 is to include the averages. 
      for(j=stu_start;j<n_stud+stu_start+2;j++){
	  tot=0;
	  for(i=beg_col;i<end_col+1;i++){
	      tot += stu[j,i];
	      if ( thru == col_name[i] ){break;} # don't count past this column
	  }
	  if ( debug ) printf("j=%d, i=%d tot=%f\n",j,i,tot)
	stu[j,end_col+1] = tot;
      }
      # Calculate the percentage, the +2 is to include the averages, so that
      # the average grade for the class can be computed.
      for(j=stu_start;j<n_stud+stu_start+2;j++){
	  stu[j,end_col+2] = stu[j,end_col+1]/stu[perfect_row_num,end_col+1];
      }
      stu[col_names_row,end_col+1] = "Tot_Pts"
      stu[col_names_row,end_col+2] = "Percent"
      stu[col_names_row,end_col+3] = "GRADE"

      col_name[end_col+1] = "Tot_Pts"
      col_name[end_col+2] = "Percent"
      col_name[end_col+3] = "GRADE"

      if ( 0 ) printf("last three columns = %s %s %s\n",stu[col_names_row,end_col+1],
		      stu[col_names_row,end_col+2], stu[col_names_row,end_col+3])

      # Calculate the grade
      for(j=stu_start;j<n_stud+stu_start+2;j++){
	  pct = stu[j,end_col+2];
	  if ( 1.00 >= pct && pct >= 0.97 ) grade = "A+";
	  if ( 0.97  > pct && pct >= 0.93 ) grade = "A";
	  if ( 0.93  > pct && pct >= 0.90 ) grade = "A-";
	  if ( 0.90  > pct && pct >= 0.87 ) grade = "B+";
	  if ( 0.87  > pct && pct >= 0.83 ) grade = "B";
	  if ( 0.83  > pct && pct >= 0.80 ) grade = "B-";
	  if ( 0.80  > pct && pct >= 0.77 ) grade = "C+";
	  if ( 0.77  > pct && pct >= 0.73 ) grade = "C";
	  if ( 0.73  > pct && pct >= 0.70 ) grade = "C-";
	  if ( 0.70  > pct && pct >= 0.67 ) grade = "D+";
	  if ( 0.67  > pct && pct >= 0.63 ) grade = "D";
	  if ( 0.63  > pct && pct >= 0.60 ) grade = "D-";
	  if ( 0.60  > pct && pct >= 0.00 ) grade = "F";
	  stu[j,end_col+3] = grade;
      }

      
      ##################################################
      # final table output
      # start at stu_start-1 to get the column headers
      for(j=stu_start-1;j<n_stud+stu_start+add_rows+1;j++){
	  if (stu[j,3]==""){continue}
	  # printf("j=%d ",j)
	  # printing options to leave out student names:
	  # no_name_col==1 if no_name==0
	  # no_name_col==3 if no_name==1
	  for(i=no_name_col;i<end_col+1+add_cols;i++){
	      a = col_name[i]
	      if ( a~/Name/ || a~/ID/ || a=="GRADE" || a~/HW/ ||
		   a~/Homework/ || a~/Exam/ || a~/Pts/ || a~/Perc/ ) {

		  if ( stu[j,i] == "" ) printf("%s ","--");
		  else if ( i == end_col+2 && j>=stu_start ) printf("%0.03f ",stu[j,i] ) # percentage
		  else if ( a~/ID/ && j>=stu_start ) printf("%d ",stu[j,i]) # print integer for ID
		  else if ( stu[j,i]+0 == stu[j,i] ) printf("%0.02f ",stu[j,i])   # check if stu[j,i] is numeric
		  else printf("%s ",stu[j,i]);
		  #printf("i=%d  a = %s  *match* stu=%s\n",i,a,stu[j,i]);
	      } else {
		  # printf("i=%d  a = %s  *denied* stu=%s\n",i,a,stu[j,i]);
	      } 
	      
	  }
	  printf("\n")
      }

	 
  }


