#!/bin/python3

from pathlib import Path
import re
import gzip
import os
import argparse


def getsamples(path):
    """Determines the sample names according to the convention
sample_name_L001_R1_001.fastq.gz"""
    samples = set()
    for f in path.glob("**/*.fastq.gz"):
        f = f.name
        samples.add(re.sub(
            r"_S\d+_L\d{3}_R\d_\d{3}.fastq.gz", "", f))
    if not samples:
        raise Exception("Could not find any fastq.gz files under "+str(path))
    samples = list(samples)
    samples.sort()
    return samples


def guessreadlen(fastqpath, sample):
    """Reads the second line of one of the R2 files associated with the
sample"""
    files = list(fastqpath.glob(f"""**/{sample}*R2*.fastq.gz"""))

    if not files:
        raise Exception(f"""Couldn't find any files for sample [{sample}]""")

    fname = str(files[0])

    with gzip.open(fname, 'r') as r2:
        r2.readline()
        readlen = len(r2.readline())-1
    return readlen


def writesamplescsv(csvpath, fastqpath, samples, ncells, batch):
    """Creates the samples.csv file"""
    with open(csvpath, "w") as csv:
        print("samples,expected_cells,read_length,batch", file=csv)
        for sample in samples:
            try:
                readlen = guessreadlen(fastqpath, sample)
            except Exception as e:
                csvpath.unlink()
                raise e
                return
            print(f"""{sample},{ncells},{readlen},{batch}""", file=csv)


def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("--samplenames", type=str, default="")
    parser.add_argument("--ncells", type=int, default=5000)
    parser.add_argument("--fastqpath", type=Path, default="./")
    parser.add_argument("--csvpath", type=Path, default="./samples.csv")
    args = parser.parse_args()

    csvpath = Path(args.csvpath)
    batch = "Batch1"
    ncells = args.ncells
    fastqpath = args.fastqpath

    if args.samplenames is not "":
        samples = args.samplenames.split(" ")
    else:
        samples = getsamples(fastqpath)

    if not csvpath.exists():
        writesamplescsv(csvpath, fastqpath, samples, ncells, batch)


if __name__ == "__main__":
    # execute only if run as a script
    main()
