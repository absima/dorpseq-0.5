#!/bin/bash

set -e

python /scripts/samplescsv.py \
       --samplenames "$SAMPLENAMES" \
       --ncells $NUMCELLS \
       --fastqpath /input \
       --csvpath /output/samples.csv

#source activate dropSeqPipe

snakemake \
      --snakefile scripts/merge/merge_fastq.smk \
      --jobs $JOBS

if [ "$DOWNSAMPLING" -eq 1 ]; then
    echo "Entering downsampling mode"

    # perform dropseq preprocessing on full data
    cp /config/config.yaml /output/results/config.yaml
    cp /output/samples.csv /output/results/samples.csv
    snakemake \
        --jobs $JOBS \
        --snakefile /dropSeqPipe/Snakefile \
       --directory /output/results/ \
        $TARGETS \
    > >(tee -a /output/results/stdout.log) \
    2> >(tee -a /output/results/stderr.log >&2)


    # create folder
    if [ ! -d "/output/results_ds/" ]; then
    mkdir /output/results_ds
    mkdir /output/downsampled_data
    fi
    # copy config file
    cp /config/config_ds.yaml /output/results_ds/config.yaml
    cp /output/results/gtf_biotypes.yaml /output/results_ds/gtf_biotypes.yaml
    cp /output/results/NexteraPE-PE.fa /output/results_ds/NexteraPE-PE.fa

    # perform downsampling
    snakemake \
        --snakefile scripts/downsample/downsample_fastq.smk \
        --jobs $JOBS

    python /scripts/samplescsv_ds.py \
        --samplenames "$SAMPLENAMES" \
        --ncells $NUMCELLS \
        --fastqpath /output/downsampled_data \
        --csvpath /output/results_ds/samples.csv

    # perform dropseq preprocessing on downsampled data
    snakemake \
        --jobs $JOBS \
        --snakefile /dropSeqPipe/Snakefile \
        --directory /output/results_ds \
        $TARGETS \
        > >(tee -a /output/results_ds/stdout.log) \
        2> >(tee -a /output/results_ds/stderr.log >&2)

else
    echo "Entering full processing mode"
python /scripts/samplescsv.py \
       --samplenames "$SAMPLENAMES" \
       --ncells $NUMCELLS \
       --fastqpath /output/raw_data \
       --csvpath /output/results/samples.csv

# snakemake only merged data
    cp /config/config.yaml /output/results/config.yaml
    snakemake \
        --jobs $JOBS \
        --snakefile /dropSeqPipe/Snakefile \
        --directory /output/results \
        $TARGETS \
    > >(tee -a /output/results/stdout.log) \
    2> >(tee -a /output/results/stderr.log >&2)
fi


chmod -R a+w /output
chown -R nobody /output
