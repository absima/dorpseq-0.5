from snakemake.shell import shell
from pathlib import Path
import pandas as pd
import os
import re
import glob


samples = pd.read_table("/output/samples.csv", header=0, sep=',', index_col=0)

# create list of fastq files in raw_data folder  
fastq_files=glob.glob("/output/raw_data/*.fastq.gz")

def samplefiles(sample,read):
    read_file = [x for x in fastq_files if sample in x and read in x]
    return(read_file)
    
# define downsampling ratio
ds_ratio = [0.5, 0.25, 0.1]

rule all:
    input:
         expand('/output/downsampled_data/{sample}_{ratio}_R1.fastq.gz', sample=samples.index, ratio=ds_ratio),
         expand('/output/downsampled_data/{sample}_{ratio}_R2.fastq.gz', sample=samples.index, ratio=ds_ratio)
    
rule downsample_fastq_R1:
    input:
        lambda wildcards: samplefiles(wildcards.sample,'R1')
    log:
        "/output/results_ds/logs/downsampling/{sample}_{ratio}_R1.log"
    output:
        "/output/downsampled_data/{sample}_{ratio}_R1.fastq.gz"
    run:
        shell("echo {input} > {log}")
        shell("""seqkit sample {input} -p {wildcards.ratio} -s 11 -o {output}""")

rule downsample_fastq_R2:
    input:
        lambda wildcards: samplefiles(wildcards.sample,'R2')
    log:
        "/output/results_ds/logs/downsampling/{sample}_{ratio}_R2.log"
    output:
        "/output/downsampled_data/{sample}_{ratio}_R2.fastq.gz"
    run:
        shell("echo {input} > {log}")
        shell("""seqkit sample {input} -p {wildcards.ratio} -s 11 -o {output}""")


