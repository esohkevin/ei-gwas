#!/usr/bin/awk -f

NR==FNR{

    #  NR==FNR is the current line number of the current file. FNR the current line number.
    #  fid[$1]=$1 saves column 1 of file 1 in array fid with key $1 (FID)
    #  pheno[$1]=$3 saves column 3 of file 1 in array pheno with key $1 (phenotype)
    #  ($1 in fid) tests if column 1 of file 2 is in array fid
    #  (pheno[$1] ~ /NA/) tests if array pheno (phenotype) is NA

  fid[$1]=$1 
  pheno[$1]=$3 
  next
} { 

  # test if IDs in first and third columns of file 2 are in first column of file 1 while saving the respective phenotype
  # values of the file 2 IDs in the apheno and bpheno variables

  if( ($1 in fid) && (pheno[$1] ~ /NA/) ) {

    # if the phenotype of the ID In the first column is 'NA', then save if for exclusion irrespective of whether the
    # third column ID is also 'NA'.

    badfid=$1
    badphen=apheno
  } else if( ($3 in fid) && (pheno[$1] ~ /NA/) ) {

      # same as above for ID in third column

      badfid=$3
      badphen=bpheno
  } else if( (($1 in fid) && !(pheno[$1] ~ /NA/) && (apheno=pheno[$1])) && (( $3 in fid) && !(pheno[$1] ~ /NA/) && (bpheno=pheno[$1])) ) {

    # otherwise, the phenotype of both IDs is not missing. Then use a strategy to exclude one ID

    if(apheno > bpheno) {
      badfid=$1
      badphen=apheno
    } else {
      badfid=$3
      badphen=bpheno
    } 
  }
} { 
    print badfid"\t"badfid"\t"badphen
}
