This is a docker image based on the
[dropSeqPipe](https://github.com/Hoohm/dropSeqPipe).  The image can be
used to process dropSeq or seq-well data sequenced with Illumina (and
possibly other formats).  There is some additional functionality
including merging `fastq.gz` files and automatically creating the
`samples.csv` file required by the dropSeqPipe by extracting them from
the names of the input files.

# Usage

## Environmental variables

Under normal circumstances no

The environmental variables used in this container include

- `SAMPLENAMES`: the names of the samples, that will be used to select
  and merge `fastq.gz` files.  For example
  ```
  SAMPLENAMES=sample1 sample2
  ```

  would merge all the fastq files starting with `sample1` and
  `sample2`.  By default `SAMPLENAMES=""` (i.e. if not specified) and
  sample names will be determined automatically by extracting the
  sample names with the regular expression
  `r"(.*)_S\d+_L\d{3}_R\d_\d{3}.fastq.gz"`.

- `NUMCELLS`: a number of cells/beads to extract from each sample
  (counted after merging the fastq files).  If you don't want to
  discard any barcodes set this to a large number but this may raise
  some errors at the last stages of dropSeqPipe where it tries to
  merge all count tables into one (but you can safely ignore those and
  just use the intermediate count tables).

- `JOBS`: number of processes to be used by snakemake.

- `TARGETS`: the type of analysis to perform, the default is `all`.  If
  you want to perform just a preliminary qc select one of the
  available targets from
  https://github.com/Hoohm/dropSeqPipe/wiki/Running-dropSeqPipe#modes.
  Also for executing additional target rules (for plots, etc.)

## Volumes

The pipeline expects the following volumes to be mounted

- `/input:ro`, the location of the `fastq.gz` files
- `/raw_data:rw`, an empty directory where the merged fastq files will be
  stored
- `/results:rw`, where the results will be stored. This directroy must
  contain the adapter file and the gtf_biotypes.yaml
- `/ref:rw`, the location of the annotation and genome files.  The
  script will look for `genome.fa` and `annotation.gtf`
  files.  Then it will generated STAR index and other files necessary
  for the pipeline, if such files already exist the pipeline will
  reuse them without regenerating them.
- `/samples.csv` (optional), if you want to provide a specific
  `samples.csv` file according to the dropSeqPipe standard.  If not
  present it will be automatically generated based on `SAMPLENAMES` or
  on file names if `SAMPLENAMES` is not provided.
- `/config/config.yaml` (optinal), to provide a customized version of the
  config file.
