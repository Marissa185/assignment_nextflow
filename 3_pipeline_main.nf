#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.reads = 'data/*_{1,2}.fq.gz'
params.outdir = './outputs/'
params.adapters = 'adapters.fa'
log.info """
      LIST OF PARAMETERS
================================
Reads            : ${params.reads}
Output-folder    : ${params.outdir}
Adapters         : ${params.adapters}
"""

// Create read channel
read_pairs_ch = Channel.fromFilePairs(params.reads, checkIfExists: true).map { sample, reads -> tuple(sample, reads.collect { it.toAbsolutePath() }) }
adapter_ch = Channel.fromPath(params.adapters, checkIfExists: true).first()


// Run the workflow
workflow {
    read_pairs_ch.view()
    fastqc(read_pairs_ch)
    trimmomatic(read_pairs_ch, adapter_ch)
}


