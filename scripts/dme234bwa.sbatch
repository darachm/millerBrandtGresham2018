#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

module purge
module load ${BWA}
module load ${SAMTOOLS}

echo
echo "Gonna bwa ${i}";
echo "==="
BASENAME=$(echo -n $i | sed 's/\.fastq$//')  
GAWKPROGRAM='BEGIN{OFS="SEPERATOR";}{$4=1;print $0}'
RUNSTRING=' for j in ${bwaTparameters}; do 
  echo "Doing $j";
  time bwa mem -t ${SLURM_JOB_CPUS_PER_NODE} -w 3 -r 1.1 -A 2 -T $j -k 5 ${ampRef}.fa $i > ${BASENAME}.bwaraw_${j}.sam ;
  time samtools view -h -F 2048 -F 16 -F 4 -F 256 -F 512 ${BASENAME}.bwaraw_${j}.sam > ${BASENAME}.bwafiltered_${j}.sam ;
  time cat ${BASENAME}.bwafiltered_${j}.sam | grep "^@" > ${BASENAME}.bwa_${j}.sam ;
  time cat ${BASENAME}.bwafiltered_${j}.sam | grep -v "^@" | gawk '"'"${GAWKPROGRAM}"'"' | sed '"'"'s/SEPERATOR/\t/g'"'"' >> ${BASENAME}.bwa_${j}.sam ;
done ; '

echo $RUNSTRING
eval $(echo $RUNSTRING)

echo "==="
echo "Done bwa ${i}"
echo

