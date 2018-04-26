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
  BarNone -f fastq --multiplexfile ${DATA}/sampleBarcodesRobinson2014.txt --multiplexstart 1 --multiplexlength 5 --tagstart 6 --taglength 3 --start 9 --mismatches ${j} --mismatchfile ${BASENAME}.barnone_${j}.mismatches --revisedcatalog ${BASENAME}.barnone_${j}.revised -p 500000 $i ${BASENAME}.barnone_${j}.counts.txt ${DATA}/strainBarcodesNislowRevision.txt ;
  BarNone -f fastq --tagstart 6 --taglength 3 --start 9 --mismatches ${j} --mismatchfile ${BASENAME}.barnoneNoDemux_${j}.mismatches --revisedcatalog ${BASENAME}.barnoneNoDemux_${j}.revised -p 500000 $i ${BASENAME}.barnoneNoDemux_${j}.counts.txt ${DATA}/strainBarcodesNislowRevision.txt ;
done; '

echo $RUNSTRING
eval $(echo "$RUNSTRING")

echo "==="
echo "Done barnone ${i}"
echo


