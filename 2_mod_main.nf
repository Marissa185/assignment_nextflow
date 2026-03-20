#!/usr/bin/env nextflow

nextflow.enable.dsl=2


// Parameters
params.reads = 'data/*_{1,2}.fq.gz'
params.outdir = './2_outputs'
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

    
// Process fastqc
process fastqc {
    conda "${params.envdir}/fastqc-env.yml"
    label "low_ram"	
    publishDir "${params.outdir}/quality-control-${sample}/", mode: 'copy', overwrite: true

    input:
    tuple val(sample), path(reads)

    output:
    path("*_fastqc.{zip,html}")

    script:
    """
    fastqc ${reads}
    """
}


// Process trimmomatic
process trimmomatic {
    conda "${params.envdir}/trimmomatic-env.yml"
    label "low_ram"
    publishDir "${params.outdir}/trimmed-reads-${sample}/", mode: 'copy'

    input:
    tuple val(sample), path(reads)
    path adapters_file

    output:
    tuple val("${sample}"), path("${sample}*.trimmed.fq.gz"), emit: trimmed_fq
    tuple val("${sample}"), path("${sample}*.discarded.fq.gz"), emit: discarded_fq

    script:
    """
    trimmomatic PE -phred33 ${reads[0]} ${reads[1]} ${sample}_1.trimmed.fq.gz ${sample}_1.discarded.fq.gz ${sample}_2.trimmed.fq.gz ${sample}_2.discarded.fq.gz ILLUMINACLIP:${adapters_file}:2:30:10
    """
}


// Process bwamem2
process bwamem2 {
    conda "${params.envdir}/bwamem2-env.yml"
    label "low_ram"
    publishDir "${params.outdir}/aligned-reads-${sample}/", mode: 'copy'

    input:
    tuple val(sample), path(trimmed_reads)  
    path index_files  
    val index_prefix  

    output:
    tuple val(sample), path("${sample}.sam") 

    script:
    """
    bwa-mem2 mem -t 2 ${index_prefix} ${trimmed_reads[0]} ${trimmed_reads[1]} > ${sample}.sam
    """
}


// Run the workflow
workflow {
    read_pairs_ch.view()
    fastqc(read_pairs_ch)
    trimmomatic(read_pairs_ch, adapter_ch)
    bwamem2(trimmomatic.out.trimmed_fq, index_ch, ref_prefix)
}