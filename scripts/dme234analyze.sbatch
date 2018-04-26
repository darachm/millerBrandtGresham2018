#!/bin/bash

module purge
module load ${R}

# the empirical distribution comes from summing samples 84,93,105 
# uptag counts within strains from dme127 data

echo "analyzing this sucka"

RUNSTRING="Rscript ./scripts/dme234analyze.R"
echo "Running:
$RUNSTRING"
eval $RUNSTRING


