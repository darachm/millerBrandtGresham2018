#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

module purge
module load ${PYTHON3}

# the empirical distribution comes from summing samples 84,93,105 
# uptag counts within strains from dme127 data

echo "making fake reads with ${i} mutations per read"

RUNSTRING="python3 scripts/makingFakeReads.py \
  --firstFixed GTCCACGAGGTCTCT \
  --secondFixed CGTACGCTGCAGGTCGAC \
  --umiEtc NGNANGNGNGNGATGTGACTGGAGTTCAGACATCTCGTATGCCGTCTTCTGCTTG \
  --strainBarcodesFilePath ${DATA}/strainBarcodesNislowRevision.txt \
  --sampleBarcodesFilePath ${DATA}/sampleBarcodesRobinson2014.txt \
  --fakeDataDir ${TMP} \
  --empirical ${DATA}/dme127empiricalDistribution \
  --reps 3 --duprate 5 --samples 32 --totalReads 16000000 \
  --mutationRate ${i} "
echo "Running:
$RUNSTRING"
eval $RUNSTRING


