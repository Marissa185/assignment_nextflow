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