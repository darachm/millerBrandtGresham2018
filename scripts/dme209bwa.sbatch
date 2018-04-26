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
RUNSTRING=' 
time bwa mem -t ${SLURM_JOB_CPUS_PER_NODE} -w 3 -r 1.1 -A 2 -T 44 -k 5 ${ampRef}.fa $i > ${BASENAME}.bwaraw.sam ;
  time samtools view -h -F 2048 -F 16 -F 4 -F 256 -F 512 ${BASENAME}.bwaraw.sam > ${BASENAME}.bwafiltered.sam ;
  time cat ${BASENAME}.bwafiltered.sam | grep "^@" > ${BASENAME}.bwa.sam ;
  time cat ${BASENAME}.bwafiltered.sam | grep -v "^@" | gawk '"'"${GAWKPROGRAM}"'"' | sed '"'"'s/SEPERATOR/\t/g'"'"' >> ${BASENAME}.bwa.sam ;'

echo $RUNSTRING
eval $(echo $RUNSTRING)

echo "==="
echo "Done bwa ${i}"
echo

