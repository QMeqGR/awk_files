BEGIN{

# set on command line
    points_tot;
    # straight scale
#    90-100 A
#    80-90  B
#    70-80  C
#    50-70  D
#    0 -50  F
    grd[2] = "D-"
    grd[3] = "D"
    grd[4] = "D+"
    grd[5] = "C-"
    grd[6] = "C"
    grd[7] = "C+"
    grd[8] = "B-"
    grd[9] = "B"
    grd[10] = "B+"
    grd[11] = "A-"
    grd[12] = "A"
    grd[13] = "A+"

    pct[0] =0.0
    pct[1] =0.5
    pct[2] =0.55
    pct[3] =0.65
    pct[4] =0.7
    pct[5] =0.725
    pct[6] =0.775
    pct[7] =0.80
    pct[8] =0.825
    pct[9] =0.875
    pct[10]=0.9
    pct[11]=0.925
    pct[12]=0.975
    pct[13]=1.0

    for(i=13; i>0; i--){
	printf("%6.2f --- %6.2f    %s\n",points_tot*pct[i-1],points_tot*pct[i],grd[i]);
    }
}

