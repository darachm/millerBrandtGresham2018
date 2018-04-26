#!/bin/bash

# AmpRef: making the amplicon reference

module load ${PYTHON3}

mkdir -p $(dirname ${ampRef})

python3 scripts/makingAmpliconReference.py \
  --ampliconPrefix TCT\
  --ampliconSuffix CGTACGCTGCAGGTCGAC \
  --strainBarcodesFilePath ${DATA}/strainBarcodesNislowRevision.txt \
  --referenceFilename ${ampRef}.fa

module load ${SAMTOOLS}
samtools faidx ${ampRef}.fa

module load ${BWA}
bwa index ${ampRef}.fa

