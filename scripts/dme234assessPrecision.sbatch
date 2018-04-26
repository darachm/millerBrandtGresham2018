#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

module purge
module load ${SAMTOOLS}
#module load samtools/intel/1.3.1

echo
echo "Gonna bwa ${i}";

BASENAME=$(echo -n $i | sed 's/\.[sb]am$//')  

echo "==="

RUNSTRING='samtools view ${i} > ${BASENAME}.sam.tmp; cat ${BASENAME}.sam.tmp | gawk -F"[\t:]" "{ if (\$2!=\$6) { print \$0 }}" > ${BASENAME}.sam.wrongStrain'

echo $RUNSTRING
eval $RUNSTRING

echo "==="
echo "Done bwa ${i}"
echo

