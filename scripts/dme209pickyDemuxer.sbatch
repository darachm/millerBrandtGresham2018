#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

module purge
module load ${PERL}

BASENAME=$(echo -n $i | sed 's/.chopped_pass.fastq//')
indicies=$(for i in $(tail -n +2 data/dme209/dme209.SampleSheet.csv | sed "s/,.*$//");do grep "Sample$i\s" data/dme209/sampleBarcodesRobinson2014.txt | sed "s/^.*\s//" ; done)

echo
echo "Gonna demux ${i} with $indicies"
echo "==="

RUNSTRING="time perl scripts/pickyDemuxer.pl $i $indicies"
echo $RUNSTRING
eval $RUNSTRING

echo "==="
echo "Done demuxing ${i}"
echo

