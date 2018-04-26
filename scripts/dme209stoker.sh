#!/bin/bash

# This function takes arguments (see below) then launches a scheduler
# (or other sbatch) and then starts to log the job ids, 
# also a human-readable log.
arrayLaunch(){
  #ARGUMENTS:
  export STEPNAME=$1
  export DEPENDS_ON=$2
  export FILE_PATTERN=$3
  export TASK_SBATCH=$4
  export TASK_RESOURCES=$5

  if [[ -f ${LOGS}/running_${STEPNAME} ]]; then echo "${STEPNAME}	- it's running ! " && return; fi
  if [ -f ${LOGS}/done_${STEPNAME} ]; then echo "${STEPNAME}	- I've been here before..." && return; fi
  
  for i in ${DEPENDS_ON} ; do
    if [[ -f ${LOGS}/done_${i} ]]; then echo -n ""; else echo "${STEPNAME}	- Dependency ${i} not satisfied, wait and re-run" && return; fi
  done;

  unset FILEZ
  declare -a FILEZ
  j=0
  for i in $(ls $(eval echo ${FILE_PATTERN})); do
    j=$j+1
    FILEZ[$j]=${i}
  done
  if [[ -n "$FILE_PATTERN" ]]; then 
    export FILESTRING="${FILEZ[*]}";
    ARRAY_STRING="--array=1-${#FILEZ[*]}";
  else 
    unset FILEZ;
    ARRAY_STRING="";
  fi

  echo
  echo "Running step \"${STEPNAME}\","
  if [ ${DEPENDS_ON} ]; then echo "	depends on \"${DEPENDS_ON}\","; fi
  echo "	which schedules \"${TASK_SBATCH}\",";
  if [ ${#FILEZ[*]} -ne 0 ]; then for i in ${FILEZ[@]}}; do echo "		for file: $i ";done;fi
  if [ '${TASK_RESOURCES}' ]; then echo "	with resources \"${TASK_RESOURCES}\""; fi
  echo

  RUNSTRING="sbatch ${ARRAY_STRING} --mail-type=BEGIN,END,FAIL --mail-user=dhm267@nyu.edu --job-name=${STEPNAME}_array --output=${LOGS}/%A_${STEPNAME}_%a.out --error=${LOGS}/%A_${STEPNAME}_%a.err ${TASK_RESOURCES} ${TASK_SBATCH};"
  echo "	Running this:"
  echo "	"${RUNSTRING}
  RESPONSE=$(eval ${RUNSTRING} )
  RESPONSE=($RESPONSE)
  echo $SLURM_JOBID > ${LOGS}/running_${STEPNAME}
  sbatch --dependency=afterok:${RESPONSE[-1]} --mail-type=BEGIN,END,FAIL --mail-user=dhm267@nyu.edu --output=${LOGS}/%A_${STEPNAME}_chaser.out --error=${LOGS}/%A_${STEPNAME}_chaser.err --job-name=${STEPNAME}_chaser --time=00:01:00 --wrap="mv ${LOGS}/running_${STEPNAME} ${LOGS}/done_${STEPNAME}" 
  echo
}

### EDIT BELOW

# Directories of interest
export DIR=$(pwd)
export TMP=${DIR}"/tmp/dme209"
export DATA=${DIR}"/data/dme209"
export LOGS=${TMP}"/sl"
mkdir -p $LOGS

# Module names
export PYTHON3="python3/intel/3.5.3"
export SAMTOOLS="samtools/intel/1.3.1"
export R="r/intel/3.3.2"
export BWA="bwa/intel/0.7.15"
export BARNONE="barnone/intel/20170501"
export PERL="perl/intel/5.24.0"
export UMITOOLS="umi_tools/0.4.2"

# Variables for varying
export ampRef=${TMP}"/reference/ampliconReference"

# arrayLaunch "stepName" "dependsOn otherSteps" 'escaped pattern to match \* files' "scriptToRun.sbatch" "resources you want for it"

arrayLaunch "dme209slapChop" "" \
  '${DATA}/dme209.fastq' "scripts/dme209slapChop.sbatch" \
  "--nodes=1 --ntasks-per-node=26 --mem=030GB --time=06:00:00"

arrayLaunch "dme209slapChopQC" "dme209slapChop" \
  '${TMP}/dme209\.chopped\.report' "scripts/dme209slapChopQC.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --mem=060GB --time=00:30:00"

arrayLaunch "dme209reference" "" \
  '' "scripts/ampRef.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --time=00:05:00"

arrayLaunch "dme209demuxer" "dme209slapChop" \
  '${TMP}/dme209.chopped_pass.fastq' "scripts/dme209pickyDemuxer.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --mem=60GB --time=01:00:00"

arrayLaunch "dme209bwa" "dme209demuxer" \
  '${TMP}/dme209\.chopped_pass.demux_[ACTG]\*.fastq' "scripts/dme209bwa.sbatch" \
  "--nodes=1 --ntasks-per-node=14 --mem=30GB --time=01:00:00"

arrayLaunch "dme209umitools" "dme209bwa" \
  '${TMP}/dme209\.chopped_pass\.demux_[ATCG][ACTG]\*\.bwa\.sam' "scripts/dme209umitools.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --mem=30GB --time=02:00:00"

arrayLaunch "dme209countNonDeduped" "dme209bwa" \
  '${TMP}/dme209\.chopped_pass\.demux_[ATCG][ACTG]\*\.bwa\.sam' "scripts/dme209countSBams.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --mem=30GB --time=00:05:00"

arrayLaunch "dme209pullNonDeduped" "dme209bwa" \
  '${TMP}/dme209\.chopped_pass\.demux_[ATCG][ACTG]\*\.bwa\.sam' "scripts/dme209pullStrainUMICombos.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --mem=30GB --time=00:30:00"

arrayLaunch "dme209pullDeduped" "dme209umitools" \
  '${TMP}/dme209\.chopped_pass\.demux_[ATCG][ACTG]\*\.bwa\.dedup\.bam' "scripts/dme209pullStrainUMICombos.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --mem=30GB --time=00:30:00"
