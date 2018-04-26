#!/bin/bash
#SBATCH --mail-type=BEGIN,END,FAIL 
#SBATCH --mail-user=dhm267@nyu.edu
#SBATCH --job-name=dme211trimming
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --mem=30GB
#SBATCH --time=12:00:00
#SBATCH --output=tmp/dme211/%A_dme211trimming.out
#SBATCH  --error=tmp/dme211/%A_dme211trimming.err

# I assume this is run from the base repo directory, so there's a tmp
# here.
WORKDIR=$(pwd) 
mkdir -p ${WORKDIR}"/tmp/dme211"
# data directory, obviously, pointing at directory with the fastqs demultiplexed
#   by the core
#DATADIR="/data/cgsb/gencore/out/Gresham/2017-01-06_HGGNWBGX2/new/"
DATADIR="data/dme211/dme211_fastq/"

module purge
module load cutadapt/intel/1.12

# the below reads in an index, parses it into bash arrays, humor me okay?

unset indicies
declare -A indicies
unset adapterName
declare -A adapterName
IFS=$'\n';
for i in $(tail -n +2 data/dme211/dme211barcodeIndex.csv );do 
  thisSampleName=$(echo -n $i | perl -ne '/^(.+?),(.+?),(.+?),(.+?)$/;print $1;' ); 
  thisAdapterName=$(echo -n $i | perl -ne '/^(.+?),(.+?),(.+?),(.+?)$/;print $3;' ); 
  adapterIndex=$(echo -n $i | perl -ne '/^(.+?),(.+?),(.+?),(.+?)$/;print $4;' ); 
  indicies["${thisAdapterName}"]="${adapterIndex}";
  adapterName["${thisSampleName}"]="${thisAdapterName}";
done;
echo "Read in:"
echo ${!adapterName[@]}
echo "as mapping to"
echo ${adapterName[@]}
echo "and"
echo ${!indicies[@]}
echo "as mapping to"
echo "${indicies[@]}"
echo 

unset adaptSeq
declare -A adaptSeq
IFS=$'\n';
for i in $(tail -n +2 data/dme211/trumiseqAdapters.csv );do 
  thisSampleName=$(echo -n $i | perl -ne '/^(DG.+)_P7,(.+?)$/;print $1;' ); 
  if [ "$thisSampleName" != "" ]; then
    thisAdapterSeq=$(echo -n $i | perl -ne '/^(DGseq_.+?)_P7,(.+?)$/;print $2;' ); 
    adaptSeq["$thisSampleName"]="${thisAdapterSeq}";
  fi
done;
echo "Read in:"
echo ${!adaptSeq[@]}
echo "as mapping to"
echo ${adaptSeq[@]}
echo 

for i in $(/bin/ls $DATADIR | grep "_[wq]1\?[0-9]_"); do
  echo `date`
  thisSampleName=$(echo -n $i | gawk -F _ '{print $3}');
  thisAdapterName=${adapterName["$thisSampleName"]}
  echo "doing file $i, which is $thisSampleName, which is $thisAdapterName"
  thisAdaptSeq=${adaptSeq["$thisAdapterName"]}
  thisIndex=${indicies["${adapterName["$thisSampleName"]}"]}
# below we grab the non-empty lines from the fastq, as there was a
# bioinformatics hiccup previously
  runstring="
cat ${DATADIR}$i | grep --regexp ^$ --invert-match > tmp/dme211/fixed$i;
cutadapt -a A${thisAdaptSeq} --cut=0 -o tmp/dme211/dme211.${thisSampleName}.${adapterName["$thisSampleName"]}.$thisIndex.adapterTrimmed.fastq tmp/dme211/fixed$i"
# Then it's cutadapt'd, with a hard 0 base cut to slice off the index
# that argument is in there because in the first run the index was not trimmed
# by upstream work, but now it is, so for completeness
# Then we feed it the right adapter, which is the index and adapter of the other
# side.
  echo $runstring

  eval $runstring

done;

unset runstring

mv tmp/dme211/xtrimmingJobID tmp/dme211/xtrimmingMarker
