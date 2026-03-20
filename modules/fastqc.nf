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