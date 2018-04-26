#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

module purge
module load ${PERL}

BASENAME=$(echo -n $i | sed 's/.chopped_pass.fastq//')
indicies=$(cat ${BASENAME}.base.SampleSheet.csv | gawk -F',' '{if (NR > 1) {print $2}}' | tr '\n' ' ')

echo
echo "Gonna demux ${i} with $indicies"
echo "==="

RUNSTRING="time perl scripts/pickyDemuxer.pl $i $indicies"
echo $RUNSTRING
eval $RUNSTRING

echo "==="
echo "Done demuxing ${i}"
echo

