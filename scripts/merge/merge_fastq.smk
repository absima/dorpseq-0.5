from snakemake.shell import shell
from pathlib import Path
import pandas as pd
import os
import re
import glob

#gets the sample names from the samples.csv
#taken from DropSeqPipe snakefile
samples = pd.read_table("/output/samples.csv", header=0, sep=',', index_col=0)

def samplefiles(sample,read):
    r1_files = list(map(
        str,
        (Path("/input")
         .glob(f"""**/{sample}_*_R1_*.fastq.gz"""))
    ))
    r2_files = [re.sub(r'_R1_','_R2_',r1) for r1 in r1_files]

    if read == "1":
        return r1_files
    elif read == "2":
        return r2_files
    else:
        raise Exception("Wrong read id")

rule all:
    input:
        expand('/output/raw_data/{sample}_R1.fastq.gz', sample=samples.index),
        expand('/output/raw_data/{sample}_R2.fastq.gz', sample=samples.index)


rule merge_fastq_R1:
    input:
        lambda wildcards: samplefiles(wildcards.sample,'1')
    log:
        "/output/results/logs/merging/{sample}_R1.log"
    output:
        '/output/raw_data/{sample}_R1.fastq.gz'
    threads: 10
    run:
        shell("echo {input} > {log}")
        if len(input) == 1:
            shell("ln -s {input} {output}")
        else:
            shell("""cat {input} > {output}""")

rule merge_fastq_R2:
    input:
        lambda wildcards: samplefiles(wildcards.sample,'2')
    log:
        "/output/results/logs/merging/{sample}_R2.log"
    output:
        '/output/raw_data/{sample}_R2.fastq.gz'
    threads: 10
    run:
        shell("echo {input} > {log}")
        if len(input) == 1:
            shell("ln -s {input} {output}")
        else:
            shell("""cat {input} > {output}""")
