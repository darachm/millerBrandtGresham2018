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
  if ITERLIST=$(ls $(eval echo ${FILE_PATTERN})) && [[ -n ${FILE_PATTERN} ]] ; then 
#    echo "	running on files: ${ITERLIST}"
    echo -n ""
  else
    ITERLIST=${FILE_PATTERN}
  fi
#  echo "	Passing ${ITERLIST} in as a file pattern"

  for i in ${ITERLIST}; do
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
  if [ '${FILESTRING}' ]; then echo "		with filestring \"${FILESTRING}\""; fi
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
export TMP=${DIR}"/tmp/dme234"
export DATA=${DIR}"/data/dme234"
export LOGS=${TMP}"/sl"
mkdir -p $LOGS

# Module names
export PYTHON3="python3/intel/3.5.3"
export SAMTOOLS="samtools/intel/1.3.1"
export R="r/intel/3.3.2"
export BWA="bwa/intel/0.7.15"
export BARNONE="barnone/intel/20170501"
export PERL="perl/intel/5.24.0"
#export UMITOOLS="umi_tools/0.4.2"

# Variables for varying
export bwaTparameters="55 49 43 37 31 25"
export barnoneMMparameters="5 4 3 2 1 0"
export ampRef=${TMP}"/reference/ampliconReference"

# arrayLaunch "stepName" "dependsOn otherSteps" 'escaped pattern to match \* files' "scriptToRun.sbatch" "resources you want for it"

arrayLaunch "dme234reference" "" \
  '' "scripts/ampRef.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --time=00:05:00"

arrayLaunch "dme234makingFakeData" "" \
  '0.0 1.0 2.0 3.0' "scripts/dme234makingFakeReads.sbatch" \
  "--tasks-per-node=1 --mem=008GB --time=24:00:00"

arrayLaunch "dme234slapChop" "dme234makingFakeData" \
  '${TMP}/\*\\.base\\.fastq' "scripts/dme234slapChop.sbatch" \
  "--nodes=1 --ntasks-per-node=20 --mem=30GB --time=04:00:00"
arrayLaunch "dme234groundTruth" "dme234makingFakeData" \
  '${TMP}/\*.obs' "scripts/dme234tabulateObs.sbatch" \
  "--ntasks-per-node=1 --mem=02GB --time=00:01:00"

arrayLaunch "dme234slapChopQC" "dme234slapChop" \
  '${TMP}/\*\\.chopped\\.report' "scripts/dme234slapChopQC.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --mem=120GB --time=00:30:00"

arrayLaunch "dme234bwaUnDemuxed" "dme234slapChop dme234reference dme234demuxer" \
  '${TMP}/\*\\.demux_all\\.fastq' "scripts/dme234bwa.sbatch" \
  "--ntasks-per-node=14 --mem=60GB --time=01:00:00"
arrayLaunch "dme234umiCorrectUnDemux" "dme234bwaUnDemuxed" \
  '${TMP}/\*\\.demux_all\\.bwa_[0-9]\*\\.sam' "scripts/dme234umiCorrection.sbatch" \
  "--ntasks-per-node=1 --mem=30GB --time=00:15:00"
arrayLaunch "dme234barnoneUnDemuxed" "dme234slapChop" \
  '${TMP}/\*\\.chopped_pass\\.fastq' "scripts/dme234barnoneUnDemux.sbatch"\
  "--ntasks-per-node=1 --mem=60GB --time=36:00:00"

arrayLaunch "dme234demuxer" "dme234slapChop" \
  '${TMP}/\*\\.chopped_pass\\.fastq' "scripts/dme234pickyDemuxer.sbatch" \
  "--ntasks-per-node=1 --mem=60GB --time=00:15:00"

arrayLaunch "dme234bwaDemux" "dme234demuxer" \
  '${TMP}/\*\\.demux_[ACTG]\*\\.fastq' "scripts/dme234bwa.sbatch" \
  "--ntasks-per-node=14 --mem=30GB --time=00:30:00"
arrayLaunch "dme234umiCorrectionDemuxA" "dme234bwaDemux" \
  '${TMP}/\*\\.demux_A\*\\.bwa_[0-9]*\\.sam' "scripts/dme234umiCorrection.sbatch" \
  "--ntasks-per-node=1 --mem=30GB --time=00:05:00"
arrayLaunch "dme234umiCorrectionDemuxT" "dme234bwaDemux dme234umiCorrectionDemuxA" \
  '${TMP}/\*\\.demux_T\*\\.bwa_[0-9]*\\.sam' "scripts/dme234umiCorrection.sbatch" \
  "--ntasks-per-node=1 --mem=30GB --time=00:05:00"
arrayLaunch "dme234umiCorrectionDemuxC" "dme234bwaDemux dme234umiCorrectionDemuxT" \
  '${TMP}/\*\\.demux_C\*\\.bwa_[0-9]*\\.sam' "scripts/dme234umiCorrection.sbatch" \
  "--ntasks-per-node=1 --mem=30GB --time=00:05:00"
arrayLaunch "dme234umiCorrectionDemuxG" "dme234bwaDemux dme234umiCorrectionDemuxC" \
  '${TMP}/\*\\.demux_G\*\\.bwa_[0-9]*\\.sam' "scripts/dme234umiCorrection.sbatch" \
  "--ntasks-per-node=1 --mem=30GB --time=00:05:00"
arrayLaunch "dme234barnoneDemux" "dme234demuxer" \
  '${TMP}/\*\\.demux_[ACTG]\*\\.fastq' "scripts/dme234barnoneDemuxed.sbatch" \
  "--ntasks-per-node=1 --mem=30GB --time=02:00:00"

arrayLaunch "dme234precisionsUnDemuxBwa" "dme234bwaUnDemuxed" \
  '${TMP}/\*\.demux_all\.bwa_[0-9]\*\.sam' "scripts/dme234assessPrecision.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --mem=08GB --time=00:05:00"
arrayLaunch "dme234precisionsDemuxBwaA" "dme234bwaDemux dme234precisionsUnDemuxBwa" \
  '${TMP}/\*\.demux_A\*\.bwa_[0-9]\*\.sam' "scripts/dme234assessPrecision.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --mem=08GB --time=00:05:00"
arrayLaunch "dme234precisionsDemuxBwaC" "dme234bwaDemux dme234precisionsDemuxBwaA" \
  '${TMP}/\*\.demux_C\*\.bwa_[0-9]\*\.sam' "scripts/dme234assessPrecision.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --mem=08GB --time=00:05:00"
arrayLaunch "dme234precisionsDemuxBwaT" "dme234bwaDemux dme234precisionsDemuxBwaC" \
  '${TMP}/\*\.demux_T\*\.bwa_[0-9]\*\.sam' "scripts/dme234assessPrecision.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --mem=08GB --time=00:05:00"
arrayLaunch "dme234precisionsDemuxBwaG" "dme234bwaDemux dme234precisionsDemuxBwaT" \
  '${TMP}/\*\.demux_G\*\.bwa_[0-9]\*\.sam' "scripts/dme234assessPrecision.sbatch" \
  "--nodes=1 --ntasks-per-node=1 --mem=08GB --time=00:05:00"

arrayLaunch "dme234analyze" 'dme234precisionsDemuxBwaG' \
  '' "scripts/dme234analyze.sbatch" "--ntasks-per-node=1 --mem=32GB --time=01:00:00"
