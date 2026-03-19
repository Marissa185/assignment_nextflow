#!/usr/bin/env nextflow

nextflow.enable.dsl=2


params.reads = 'data/*_{1,2}.fq.gz'
params.outdir = './outputs'
params.adapters = 'adapters.fa'
params.moduledir = './envs'
params.refdir = 'data/LG12.fasta'


log.info """
      LIST OF PARAMETERS
================================
Reads            : ${params.reads}
Output-folder    : ${params.outdir}
Adapters         : ${params.adapters}
Conda‑env folder : ${params.moduledir}
Reference        : ${params.refdir}
"""


// Create channel
read_pairs_ch = Channel.fromFilePairs(params.reads, checkIfExists: true).map { sample, reads -> tuple(sample, reads.collect { it.toAbsolutePath() }) }

adapter_ch = Channel.fromPath(params.adapters, checkIfExists: true).first()

index_ch      = Channel.fromPath("${params.refdir}*", checkIfExists: true).collect()

ref_prefix    = file(params.refdir).name

    
// Define fastqc process
process fastqc {
    conda "${params.moduledir}/fastqc-env.yml"
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
    conda "${params.moduledir}/trimmomatic-env.yml"
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
    conda "${params.moduledir}/bwamem2-env.yml"
    label "low_ram"
    publishDir "${params.outdir}/aligned-reads-${sample}/", mode: 'copy'

    input:
    tuple val(sample), path(trimmed_reads)  
    path index_files  
    val index_prefix  

    output:
    // Change this to .sam if you aren't using samtools yet
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
