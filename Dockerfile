#FROM pwlb/rna-seq-pipeline-base:v0.1.1
FROM continuumio/miniconda:4.7.12

#Gets miniconda
#RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
#    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.3.27-Linux-x86_64.sh -O ~/miniconda.sh && \
#    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
#    rm ~/miniconda.sh
#ENV PATH /opt/conda/bin:$PATH

#Gets the DropSeqPipe v0.5 from github
#RUN git clone https://github.com/Hoohm/dropSeqPipe.git && \
#    cd dropSeqPipe && \
#    git checkout -b temp 4fc0de4b73588c22e2df78c9e0eae8b928d70e76
COPY dropSeqPipe /dropSeqPipe

#Creates environment
#COPY environment.yaml .
#RUN conda env create -v --name dropSeqPipe --file environment.yaml


COPY ./binaries/gtfToGenePred /usr/bin/gtfToGenePred

#Defines environment variables
ENV TARGETS "all"
ENV SAMPLENAMES ""

#Copies needed files and directories into container
COPY example/config.yaml /config/
COPY scripts /scripts
COPY /templates /templates

RUN echo "" >> /dropSeqPipe/Snakefile

RUN conda config --add channels r
RUN conda config --add channels defaults
RUN conda config --add channels conda-forge
RUN conda config --add channels bioconda

RUN conda install -y bbmap=38.22 biopython=1.72 click cutadapt=1.16 cython dropseq_tools=2.0.0 fastqc fontconfig=2.13.1 font-ttf-dejavu-sans-mono=2.37 h5py icu matplotlib multiqc ncurses=6.1 numba numpy pandas=0.25.1 picard=2.14.1.0 pigz=2.4 pysam=0.15.1 python>=3.6 r=3.4.1 r-devtools r-dplyr=0.7.6 r-ggplot2=2.2.1 r-ggpubr r-gridextra r-hmisc r-matrix=1.2_14 r-mvtnorm r-rcolorbrewer r-reshape2 r-seurat=2 r-stringdist r-tidyverse r-viridis samtools=1.9 scikit-learn scipy=1.1.0 seqkit=0.10.2-0 snakemake=5.10.0-0 star=2.6.1b trimmomatic umi_tools=0.5.5
RUN pip install pandas
RUN pip install ftputil

COPY dropSeqPipe /dropSeqPipe

ENTRYPOINT ["/bin/bash"]

#Executes run-all.sh
CMD ["/scripts/run-all.sh"]
