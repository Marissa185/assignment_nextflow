Note - The commit id #5ad896357b180531cbd1ae23a3441a07d8a7fee5 was commited by #akamsha_ui but was accidentally commited as Marissa185 

# About the Project
The project was performed by akamsha_ui (Akamsha) and Marissa185 (Marissa) as part of the Nextflow Assignment. The provided `main.nf` file had a few initial errors and some commands were missing. The errors were rectified (detailed below) and an alignment process was then modularised which successfully to generate the output files (`.sam`). The proesses included `fastqc` (for quality control of the fastq files), `trimmomatic` (the adapters are trimmed from the fastq files), `bwa-mem2` (the output of trimmomatic is aligned to the reference genome).


## About the *.nf files and the dependent files and folders created

### .gitignore
This was created to ignore log and intermediatry files and work folder.

### Nextflow.config
- In the `nextflow.config file`, CPU and memory resources were reduced to match the available system capacity and Conda was enabled by setting `conda.enabled as TRUE`. 
- A `withLabel: "low_ram"` profile was defined and applied to all processes in `2_mod_main.nf` to ensure the pipeline runs efficiently under limited resources. 
- A `withLabel: "bwamem2"` profile was defined and can be applied to the `bwamem2` processes in `2_mod_main.nf` and `3_pipeline_main.nf`, but was not utilised due to available system capacity. 

### 1_ori_main.nf
The original file had few initial errors and some commands were missing to connect it with the nextflow.config file in order to run the pipeline.
#### Errors found within 
- In the 1_ori_main.nf file `param.outDir` was changed to `param.dir`.
- In the workflow block `adapter_ch` was added to resolve the error status  `'Process `trimmomatic` declares 2 inputs but was called with 1 argument'`.
- Additionally, an extra space between `ILLUMINACLIP` and the adapter sample was removed in the `timmomatic process` script block to command formating.
