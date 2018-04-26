#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

module purge
module load ${SAMTOOLS}

BASENAME=$(echo -n $i | sed 's/\.[sb]am$//')  

echo
echo "Gonna pull from ${i}";
echo "==="

RUNSTRING="time samtools view ${i} | grep -v '^@' | gawk -F'[_\t]' '{print \$4\",\"\$2}' | sort > ${i}.pulled"
echo $RUNSTRING
eval $RUNSTRING

echo "==="
echo "done pulling ${i}";

