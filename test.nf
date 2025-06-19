#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

workflow {
  println "\n        IDAT to VCF: TEST"
  println ""
  println "idat_dir        = ${params.idat_dir}"
  println "manifest_bpm    = ${params.manifest_bpm}"
  println "manifest_csv    = ${params.manifest_csv}"
  println "cluster_file    = ${params.cluster_file}"

  if(params.build_ver == 'hg19') {
    println "fasta_ref      = ${params.fasta_ref}"
  }
  else {
    println "fasta_ref      = ${params.fasta_ref}"
    println "bam_alignment  = ${params.bam_alignment}"
  }

  println "output_prefix   = ${params.output_prefix}"
  println "output_dir      = ${params.output_dir}"
  println "containers_dir  = PATH WHERE CONTAINERS ARE STORED"
  println "account         = ${params.account}        # CHANGE TO YOURS"
  println "partition       = ${params.queue}      # CHANGE TO YOURS"
  println ""
  
  //call_genotypes()
  plink();
	
}

workflow.onComplete { 
  println "Workflow completed at: ${workflow.complete}"
  println "     Execution status: ${ workflow.success ? 'OK' : 'failed'}"
}

workflow.onError{
  println "workflow execution stopped with the following message: ${workflow.errorMessage}"
}

process call_genotypes() {
  tag "processing ... ${params.idat_dir}"
  label 'gencall'
  publishDir path: "${params.output_dir}/test"
  debug true
  //echo true
  
  script:
    """		
    iaap-cli \
      gencall \
      --help
    """
}

process plink() {

  // directives
  tag "processing ... ${params.idat_dir}"
  label 'plink2'
  label 'idat_to_gtc'
  publishDir path: "${params.output_dir}/output"
  debug true
  //echo true
  
  script:
    """
    plink2 \
    --help \
    --file
    """
}
