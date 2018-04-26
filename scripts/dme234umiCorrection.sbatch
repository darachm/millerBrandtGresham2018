#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

echo
echo "Gonna umi-correct ${i}, assuming 4096 possible UMIs"
echo "==="

BASENAME=$(echo -n $i | sed 's/\.sam$//')  

RUNSTRING="cat ${i} | grep -v '^@' | 
  gawk -F'[_\t]' '{ print \$4\"\t\"toupper(\$2)}'| 
  sort >
  ${BASENAME}.strainUMIcombos"
echo $RUNSTRING
eval $RUNSTRING

RUNSTRING="cat ${BASENAME}.strainUMIcombos | 
  perl -pe \"s/\s*(\S+)\s*(\S+)/\\1/;\" | sort | uniq -c >
  ${BASENAME}.strainObservations"
echo $RUNSTRING
eval $RUNSTRING

RUNSTRING="cat ${BASENAME}.strainUMIcombos | uniq -c |
  perl -pe \"s/\s*(\S+)\s*(\S+)\s*(\S+)/\\2/;\" | sort | uniq -c >
  ${BASENAME}.uniqueStrainObservations"
echo $RUNSTRING
eval $RUNSTRING

RUNSTRING="cat ${BASENAME}.strainUMIcombos | 
  uniq | cut -f 1 | sort | uniq -c | 
  perl -ne '/^\s*(\S+)\s*(\S+)\s*\$/; print -4096*log(1-\$1/4096).\" \".\$2.\"\n\";' > 
  ${BASENAME}.correctedStrainObservations"
echo $RUNSTRING
eval $RUNSTRING

echo "==="
echo "Done umi-ing ${i}"
echo

