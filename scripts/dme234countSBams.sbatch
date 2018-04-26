#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

module purge
module load ${SAMTOOLS}

BASENAME=$(echo -n $i | sed 's/\.[sb]am$//')  

echo
echo "Gonna countup ${i}";
echo "==="

RUNSTRING="time samtools view ${i} | gawk '{print \$3}' | sort | uniq -c > ${BASENAME}.counted"
echo $RUNSTRING
eval $RUNSTRING

