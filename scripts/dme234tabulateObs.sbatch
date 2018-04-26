#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

echo
echo "tabulating observations"
echo "==="

RUNSTRING="cat ${i} | sort | uniq -c > ${i}.tabulated"
echo $RUNSTRING
eval $RUNSTRING

echo "==="
echo "tabulated ${i}"
echo

