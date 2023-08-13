#!/bin/bash
# Author: Tamar Feldman
# Project: Feldman et al. Blood Adv. 2023
# Purpose: Run MultiQC on the files contained in listed directories

# Slurm parameters
#SBATCH --job-name=MultiQC #Job name
#SBATCH --nodes=1
#SBATCH --mem 32Gb
#SBATCH --time 2:00:00 # time alloted before quitting
#SBATCH --output=../slurmout/multiqc_%A.out
#SBATCH --error=../slurmout/multiqc_%A.err


DATA_DIR=$1 # path to parent directory of input files for MultiQC
NEW_PATH=$2 # path to output directory for MultiQC
FILE_PATTERN=$3 # pattern to search for correct files

# Print info about the Slurm task.
START=`date +%s`
date
echo "Host Name: " $HOSTNAME

# make output directory for MultiQC results
 [[ -d "$NEW_PATH" ]] || mkdir "$NEW_PATH"
echo "output directory: $NEW_PATH"
echo "input directory: $DATA_DIR"


# Run MultiQC on files in the subdirectories of DATA_DIR
module load biology
module load py-multiqc
CALL="multiqc "$DATA_DIR" \
	--ignore ".bam" \
	--outdir "$NEW_PATH" \
	--filename "multiqc_$DATA_DIR" \
	--dirs \
	--dirs-depth 1"

echo $CALL
eval $CALL

# test that previous command executed successfully
if [ $? -eq 0 ]; then
	echo SUCCESS
else
	echo FAILED
fi

END=`date +%s`
RUNTIME=$((END-START))
echo "Run Time: " $RUNTIME