#!/bin/bash
#SBATCH --mail-type=BEGIN,END,FAIL 
#SBATCH --mail-user=dhm267@nyu.edu
#SBATCH --job-name=dme211aligning
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=60GB
#SBATCH --time=12:00:00
#SBATCH --output=tmp/dme211/%A_dme211aligning.out
#SBATCH  --error=tmp/dme211/%A_dme211aligning.err

module purge
module load bowtie2/intel/2.2.9
module load tophat/intel/2.1.1

# Reference directory. The BES is for Benjy Ecoli Saccharo, and is the 
# conacatenation of Benjy's spikeins with the ecoli genome with the R64 
# saccharomyces genome
ANNO="/home/dhm267/ref/bnspk4ecolMG1655saccerR64/"

for i in $(/bin/ls tmp/dme211/dme211.[wq]*.adapterTrimmed.fastq); do
  echo `date`
  thisSampleName=$(echo -n $i | gawk -F . '{print $2}')
  echo "aligning $thisSampleName, so $i against ${ANNO}"
# note parameters are tweaked a bit. These were found to get a little better
# sensitivity with synthetic data (with Flux simulator) against the BES 
# reference
runstring="tophat --no-coverage-search --b2-very-sensitive --read-mismatches 5 --read-gap-length 5 --read-edit-dist 10 --max-multihits 1 --library-type fr-firststrand --num-threads 20 --keep-fasta-order --output-dir tmp/dme211/tophatOut_${thisSampleName} ${ANNO}BES $i"
  echo $runstring
  echo
 
eval $runstring
 
done;

unset runstring

mv tmp/dme211/xaligningJobID tmp/dme211/xaligningMarker
