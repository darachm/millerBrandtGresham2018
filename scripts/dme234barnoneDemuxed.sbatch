#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

module purge
module load ${BARNONE}

echo
echo "Gonna barnone ${i}";
echo "==="
BASENAME=$(echo -n $i | sed 's/\.fastq(.[^\.])*$//')  

RUNSTRING=' for j in ${barnoneMMparameters}; do 
  echo "Doing $j";
  BarNone -f fastq --tagstart 1 --taglength 3 --start 4 --mismatches ${j} --mismatchfile ${BASENAME}.barnonePickyDemux_${j}.mismatches --revisedcatalog ${BASENAME}.barnonePickyDemux_${j}.revised -p 500000 $i ${BASENAME}.barnonePickyDemux_${j}.counts.txt ${DATA}/strainBarcodesNislowRevision.txt ;
done; '

echo $RUNSTRING
eval $(echo "$RUNSTRING")

echo "==="
echo "Done barnone ${i}"
echo


