#!/bin/bash
#SBATCH --mail-type=BEGIN,END,FAIL 
#SBATCH --mail-user=dhm267@nyu.edu
#SBATCH --job-name=dme209demuxer
#SBATCH --nodes=1 --tasks-per-node=1
#SBATCH --mem=50GB
#SBATCH --time=00:30:00
#SBATCH --output=slurmOut/%A_dme209demuxer.out
#SBATCH  --error=slurmOut/%A_dme209demuxer.err

# Where are you working?
DIR=$(pwd)
# Where is your Data
DATA=${DIR}"/tmp/dme209"

module purge
module load r/intel/3.3.2
module load perl/intel/5.24.0

threshold="160000"

i=${TMP}"/dme209filtered.fastq"

thatBase=$(echo -n $i | sed 's/.fastq$//')

echo "working on "$i
echo "splitting $thatBase on greater than $threshold"

echo "cat ${thatBase}.indicies.starcoded | gawk '{if ($2 > '${threshold}') print $1}' > ${thatBase}.myindicies"
cat ${thatBase}.indicies.starcoded | gawk '{if ($2 > '${threshold}') print $1}' > ${thatBase}.myindicies

echo "time perl scripts/demuxer.pl ${thatBase}.sam ${thatBase}.indicies.starcoded ${thatBase}.myindicies ${thatBase}"
time perl scripts/demuxer.pl ${thatBase}.fastq ${thatBase}.indicies.starcoded ${thatBase}.myindicies ${thatBase}
