#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

module purge
module load ${PYTHON3}

echo
echo "Gonna SLAPCHOP ${i}";
echo "==="
BASENAME=$(echo -n $i | sed 's/\.base\.fastq//')  

python3 scripts/slapChop.py --processes ${SLURM_NTASKS_PER_NODE}\
   --biteSize 1000 --maxQueueSize 10 --inputFastq ${i} \
   --outputBase ${BASENAME}.chopped \
   --fixed1pattern GTCCACGAGGTCTCT \
   --fixed2pattern CGTACGCTGCAGGTCGAC \
   --umipattern CGTACGCTGCAGGTCGACXGXAXGXGXGXGAT \
   --outputReport ${BASENAME}.chopped.report \
   --logFile ${BASENAME}.chopped.log \
   --filters 'AlignmentStart1==5 and Score1 > 26 and Score2 > 28'

echo "==="
echo "Done SLAPCHOPPING ${i}"
echo

