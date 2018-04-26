#!/bin/bash
#SBATCH --mail-type=BEGIN,END,FAIL 
#SBATCH --mail-user=dhm267@nyu.edu
#SBATCH --job-name=dme211counting
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --mem=30GB
#SBATCH --time=12:00:00
#SBATCH --output=tmp/dme211/%A_dme211counting.out
#SBATCH  --error=tmp/dme211/%A_dme211counting.err

module purge
module load htseq/intel/0.6.1p1
module load samtools/intel/1.3.1

# reference basedir
ANNO="/home/dhm267/ref/bnspk4ecolMG1655saccerR64/"

for i in $(/bin/ls tmp/dme211/*dedup.bam); do
  echo `date`
  thisSampleName=$(echo -n $i | gawk -F . '{print $2}')
  echo $thisSampleName

# So we reconvert the deduped to sam
runstring1="samtools view $i > tmp/dme211/dme211.${thisSampleName}.alnq20m50sort.dedup.sam"
# Here we count by features, looking for any gene features. I'm using a custom
# GFF where I took all things that had "gene" in the type and reprinted those as
# "gene", so "tRNA_gene" became "gene". There might be a more elegant way to go
# up the hierarchy, but this works.
runstring2="htseq-count --mode=intersection-nonempty --idattr=ID --format=bam --stranded=reverse --type=gene $i ${ANNO}BEScountingAllGenes.gff > data/dme211/${thisSampleName}.htseqcounts.txt"
# Again countingAllGenes has anything with a /_gene\t/ matching third column
# reprinted but with a "gene" third column, so it can be counted

  echo $runstring1
eval $runstring1
  echo $runstring2
eval $runstring2
  echo $runstring3
eval $runstring3
  echo

done;

mv tmp/dme211/xcountingJobID tmp/dme211/xcountingMarker
