# ==> par.PED.PACKEDPED <==
echo -e """
genotypename:    ${ped}
snpname:         ${map} # or example.map, either works
indivname:       ${ped} # or example.ped, either works
outputformat:    EIGENSTRAT
genotypeoutname: ${ped.baseName}.eigenstratgeno
snpoutname:      ${ped.baseName}.snp
indivoutname:    ${ped.baseName}.ind
xregionname:	 ${projectDir}/includes/high-ld-regions.b37
pordercheck:	 YES
strandcheck:     YES
phasedmode:      false
familynames:     NO
numthreads:      ${task.cpus}
""" > par.PED.PACKEDPED.${bedName}