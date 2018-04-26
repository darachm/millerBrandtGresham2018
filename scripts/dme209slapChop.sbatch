#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

module purge
module load ${PYTHON3}

echo
echo "Gonna SLAPCHOP ${i}";
echo "==="
BASENAME=$(echo -n $i | sed 's/\.fastq//')  
BASEBASENAME=$( basename $BASENAME )  

python3 scripts/slapChop.py --processes ${SLURM_NTASKS_PER_NODE}\
   --biteSize 10000 --maxQueueSize 15 --inputFastq ${i} \
   --outputBase ${TMP}/${BASEBASENAME}.chopped \
   --fixed1pattern GTCCACGAGGTCTCT \
   --fixed2pattern CGTACGCTGCAGGTCGAC \
   --umipattern CGTACGCTGCAGGTCGACXGXAXGXGXGXGAT \
   --outputReport ${TMP}/${BASEBASENAME}.chopped.report \
   --logFile ${TMP}/${BASEBASENAME}.chopped.log \
   --filters 'AlignmentStart1==5 and Score1 > 24 and Score2 > 26  and len(umiSeq) > 5'

echo "==="
echo "Done SLAPCHOPPING ${i}"
echo

