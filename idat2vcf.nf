#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {
  get_manisfest_bpm;
  get_manisfest_csv;
  get_cluster_file;
  get_intensities;
  getGtc;
  get_gtc_list;
  gtcToVcf;
  gtcToVcfHg38
} from "${projectDir}/modules/gtcalls.mdl"


workflow {

  println "\nILLUMINA GENOTYPE CALLING\n"

  manifest_bpm = get_manisfest_bpm()
  cluster = get_cluster_file()
  intensity = get_intensities()
  manifest_bpm
    .combine(cluster)
    .combine(intensity)
    .map { manifest, clustfile, idat -> tuple(manifest, clustfile, idat) }
    .set { idats }

  getGtc( idats )
    .collect()
    .set { gtcs }

  get_gtc_list( gtcs )
    .set { gtc_file_list }

  if(params.build_ver == 'hg38') {
    gtcToVcfHg38(gtc_file_list)
  }
  else {
    gtcToVcf(gtc_file_list)
  }

}
