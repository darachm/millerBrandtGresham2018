#!/bin/bash
#SBATCH --mail-type=BEGIN,END,FAIL 
#SBATCH --mail-user=dhm267@nyu.edu
#SBATCH --job-name=dme209filterEstError
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=60GB
#SBATCH --time=12:00:00
#SBATCH --output=slurmOut/%A_dme209fee.out
#SBATCH  --error=slurmOut/%A_dme209fee.err


# Where are you working?
DIR=$(pwd)

DATA=${DIR}"/rawdata/dme209"
TMP="./tmp/dme209"
mkdir $TMP

# Where is your output GZip'd FASTQ file? the raw one
INPUTFASTQ=${DATA}"/sequencing/dme209.fastq"
# from:
# /data/cgsb/gencore/out/Gresham/2017-04-28_H5J5LBGX2/merged/H5J5LBGX2_n01.fastq.gz

firstFixed=${DATA}"/koAmplicons/firstFixed"
secondFixed=${DATA}"/koAmplicons/secondFixed"
fixedSeq=${DATA}"/koAmplicons/fixedSeq"

module purge
module load bowtie2/intel/2.2.9

echo "> first fixed
GTCCACGAGGTCTCT" > ${firstFixed}.fa
echo "> second fixed
CGTACGCTGCAGGTCGAC" > ${secondFixed}.fa
bowtie2-build ${firstFixed}.fa ${firstFixed}
bowtie2-build ${secondFixed}.fa ${secondFixed}

rm ${fixedSeq}.fa
for i in $(seq 7 25); do
  echo ">fixedLength${i}" >> ${fixedSeq}.fa
  echo -n "NNNNNGTCCACGAGGTCTCT" >> ${fixedSeq}.fa
  for j in $(seq 1 $i); do
    echo -n "N" >> ${fixedSeq}.fa
  done
  echo "CGTACGCTGCAGGTCGAC" >> ${fixedSeq}.fa
done
bowtie2-build ${fixedSeq}.fa ${fixedSeq}

basename=$(echo -n $INPUTFASTQ | sed 's/\.fastq//')  
outbase=${TMP}"/"$(basename ${basename})

echo "bowtieing $INPUTFASTQ"

# 15*4 - 6*5
bowtie2 -p 20 --time -x ${firstFixed}                                \
  --local -U $INPUTFASTQ --no-unal                              \
  --un ${outbase}.firstUnAln.sam                                    \
  -i L,2,0 -L 8 -N 1                                                 \
  --score-min L,30,0 --mp 2,1 --ma 4 --np 1  --rdg L,1,1 --rfg L,10,10\
  --no-hd --no-sq --reorder -S ${outbase}.firstFixed.sam

# (18*4) - 6*5
bowtie2 -p 20 --time -x ${secondFixed}                               \
  --local -U $INPUTFASTQ --no-unal                              \
  --un ${outbase}.secondUnAln.sam                                    \
  -i L,2,0 -L 8 -N 1                                                 \
  --score-min L,40,0 --mp 2,1 --ma 4 --np 1  --rdg L,1,1 --rfg L,10,10\
  --no-hd --no-sq --reorder -S ${outbase}.secondFixed.sam

# (15+18)*4-6*10
bowtie2 -p 20 --time -x ${fixedSeq}                                  \
  --local -U $INPUTFASTQ --no-unal                              \
  --un ${outbase}.fixedSeqUnAln.sam                                    \
  -i L,2,0 -L 8 -N 1                                                 \
  --score-min L,72,0 --mp 2,1 --ma 4 --np 0 --rdg L,1,1 --rfg L,10,10\
  --reorder -S ${outbase}.filtered.sam

cat ${outbase}.filtered.sam | grep -v ^@ | gawk '{print "@"$1"\n"$10"\n+\n"$11}' > ${outbase}filtered.fastq 
cat ${outbase}.filtered.sam | grep -v ^@ | gawk '{print $10\n}' > ${outbase}filtered.fa

echo "now tabulating the matches"

module purge
module load perl/intel/5.24.0
perl scripts/samToErrorStats.pl ${outbase}.firstFixed.sam
perl scripts/samToErrorStats.pl ${outbase}.secondFixed.sam

