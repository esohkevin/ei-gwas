#!/usr/bin/env python3

import pandas as pd
import argparse

"""
This script reads KING Relatedness report file and pheno file,
update phenotypes for both pairs of related samples using their
first ID columns (1 and 3 as FIDa and FIDb) respectively, then 
selects the most appropriate samples to exclude from the data 
based on whether phenotype is missing or would underpower 
association tests. 
"""

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process KING related file.")
    parser.add_argument("king_report")
    parser.add_argument("pheno_file")
    parser.add_argument("imiss_file")
    parser.add_argument("out")
    args = parser.parse_args()

    samplefile = args.king_report
    phenofile = args.pheno_file
    imissfile = args.imiss_file
    outfile = args.out


# read the king report of first IDs for the pair of related samples
sample = pd.read_table(samplefile, header=None, names=["FIDa","FIDb"], sep=" ")

# read individual missing data file
imiss = pd.read_table(imissfile, header=None, names=["FIDa","FIDb","FMISS"], sep=" ")

# read phenotype and update the header
pheno = pd.read_table(phenofile, sep=" ")
pheno.columns = ["FIDa","FIDb", "PHENO"]

# add phenotype for FIDa and FIDb
sample['PHENOa'] = sample['FIDa'].map(pheno.set_index('FIDa')['PHENO'])
sample['PHENOb'] = sample['FIDb'].map(pheno.set_index('FIDb')['PHENO'])

# add missing fraction for FIDa and FIDb
sample['FMISSa'] = sample['FIDa'].map(imiss.set_index('FIDa')['FMISS'])
sample['FMISSb'] = sample['FIDb'].map(imiss.set_index('FIDb')['FMISS'])


# compare the phenotype columns and highlight IDs for removal as described above
# if phenotypes are both NULL, then use missing data fraction to choose
badids = []
for fida, fidb, phenoa, phenob, fmissa, fmissb in zip(sample.FIDa, sample.FIDb, sample.PHENOa, sample.PHENOb, sample.FMISSa, sample.FMISSb):
    if pd.isnull(phenoa) and pd.isnull(phenob):
        if fmissa > fmissb:
            badids.append(fida)
        else:
            badids.append(fidb)
            #print(f"Bad ID: {fida}, {phenoa}")
    elif pd.isnull(phenoa) and pd.notnull(phenob):
        badids.append(fida)
        #print(f"Bad ID: {fida}, {phenoa}")
    elif pd.notnull(phenoa) and pd.isnull(phenob):
        badids.append(fidb)
        #print(f"Bad ID: {fidb}, {phenob}")
    elif pd.notnull(phenoa) and pd.notnull(phenob):
        if phenoa < phenob:
            badids.append(fida)
            #print(f"Bad ID: {fida}, {phenoa}")
        else:
            badids.append(fidb)
            #print(f"Bad ID: {fidb}, {phenob}")


# save the file for user to see the choice of samples excluded
sample['Removed'] = badids
ids_pheno = outfile.replace(".txt", "_with_pheno.txt")
sample.to_csv(ids_pheno, sep="\t", index=False, na_rep="NA")

# get badids unique list
badids_uniq = list(set(badids))

# save list of bad IDs as double column tab delimited text file
with open(outfile, 'w') as file:
	for badid in badids_uniq:
		file.write(badid + "\t" + badid + '\n')
