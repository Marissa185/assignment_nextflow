Note - The commit id #5ad896357b180531cbd1ae23a3441a07d8a7fee5 was commited by #akamsha_ui but was accidentally commited as Marissa185 

# About the Project
The project was performed by akamsha_ui (Akamsha) and Marissa185 (Marissa) as part of the Nextflow Assignment. The provided `main.nf` file had a few initial errors and some commands were missing. The errors were rectified (detailed below) and an alignment process was then modularised which successfully to generate the output files (`.sam`). The proesses included `fastqc` (for quality control of the fastq files), `trimmomatic` (the adapters are trimmed from the fastq files), `bwa-mem2` (the output of trimmomatic is aligned to the reference genome).
