#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

module purge
module load ${SAMTOOLS}
module load ${UMITOOLS}

echo
echo "Gonna umi ${i}";
echo "==="

BASENAME=$(echo -n $i | sed 's/\.sam$//')  

RUNSTRING="time samtools view -b ${BASENAME}.sam | samtools sort > ${BASENAME}.bam"
echo $RUNSTRING
eval $RUNSTRING

RUNSTRING="time samtools index ${BASENAME}.bam"
echo $RUNSTRING
eval $RUNSTRING

RUNSTRING="time umi_tools dedup -I ${BASENAME}.bam -S ${BASENAME}.dedup.bam"
echo $RUNSTRING
eval $RUNSTRING

echo "==="
echo "Done umi ${i}"
echo

