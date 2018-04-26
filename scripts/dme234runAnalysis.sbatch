#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

module purge
module load ${R}

echo
echo "Gonna analyze" 
echo "==="

RUNSTRING='Rscript --vanilla -e "source(\"scripts/dme234analyze.R\")"' 

echo $RUNSTRING
eval $RUNSTRING

echo "==="
echo

