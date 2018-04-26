#!/bin/bash
#SBATCH --mail-type=BEGIN,END,FAIL 
#SBATCH --mail-user=dhm267@nyu.edu
#SBATCH --job-name=dme211deduping
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --mem=60GB
#SBATCH --time=36:00:00
#SBATCH --output=tmp/dme211/%A_dme211deduping.out
#SBATCH  --error=tmp/dme211/%A_dme211deduping.err

module purge
module load samtools/intel/1.3.1
module load umi_tools/0.4.2

for i in $(/bin/ls -d tmp/dme211/tophatOut_*); do
  echo `date`
  thisSampleName=$(echo -n $i | gawk -F _ '{print $2}')
  echo $thisSampleName

# First, we only take things with a cigar length of 50 or more. This is because
# if you let it just match tiny bits, you'll get stuff mapping to ecoli 
# erroneously, at least in simulated data. I figure that we want good long
# reads, but we might miss some stuff that is very short. 50 is arbitrary.
# Also, qualities of 20 are arbitrary, but seems like a good cutoff.
runstring1="samtools view -m 50 -q 20 -o tmp/dme211/dme211.${thisSampleName}.alnq20m50.bam $i/accepted_hits.bam"
runstring2="samtools sort -T tmp/dme211/dhm267.aln.sorted -o tmp/dme211/dme211.${thisSampleName}.alnq20m50sort.bam tmp/dme211/dme211.${thisSampleName}.alnq20m50.bam"
runstring3="samtools index tmp/dme211/dme211.${thisSampleName}.alnq20m50sort.bam"
# Here we dedup. If you noticed before, we only allowed tophat to give us the
# 1 best hit. If you feed more into this step, it takes forever, also if you
# ask for umi statistics. So those are disabled. It seems to work fine.
runstring4="umi_tools dedup --umi-separator=: --method=directional -I tmp/dme211/dme211.${thisSampleName}.alnq20m50sort.bam -S tmp/dme211/dme211.${thisSampleName}.alnq20m50sort.dedup.bam -L tmp/dme211/dme211.${thisSampleName}.alnq20m50sort.dedup.log"

  echo $runstring1
eval $runstring1
  echo $runstring2
eval $runstring2
  echo $runstring3
eval $runstring3
  echo $runstring4
eval $runstring4
  echo

done;

mv tmp/dme211/xdedupingJobID tmp/dme211/xdedupingMarker
