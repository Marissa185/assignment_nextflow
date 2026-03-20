#!/usr/bin/env nextflow

nextflow.enable.dsl=2


// Parameters
params.reads = 'data/*_{1,2}.fq.gz'
params.outdir = './3_outputs'
params.adapters = 'data/adapters.fa'
params.envdir = './envs'
params.refdir = 'data/LG12.fasta'

log.info """
      LIST OF PARAMETERS
================================
Reads            : ${params.reads}
Output-folder    : ${params.outdir}
Adapters         : ${params.adapters}
Conda‑env folder : ${params.envdir}
Reference        : ${params.refdir}
"""


// Create channels
read_pairs_ch   = Channel.fromFilePairs(params.reads, checkIfExists: true).map { sample, reads -> tuple(sample, reads.collect { it.toAbsolutePath() }) }
adapter_ch      = Channel.fromPath(params.adapters, checkIfExists: true).first()
index_ch        = Channel.fromPath("${params.refdir}*", checkIfExists: true).collect()
ref_prefix      = file(params.refdir).name


// Module pipeline
include { fastqc } from './modules/fastqc.nf' 
include { trimmomatic } from './modules/trimmomatic.nf'
include { bwamem2 } from './modules/bwamem2.nf'


// Run the workflow
workflow {
    read_pairs_ch.view()
    fastqc(read_pairs_ch)
    trimmomatic(read_pairs_ch, adapter_ch)
    bwamem2(trimmomatic.out.trimmed_fq, index_ch, ref_prefix)
}