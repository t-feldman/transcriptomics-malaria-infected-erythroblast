#!/bin/bash
# Author: Tamar Feldman
# Project: Feldman et al. Blood Adv. 2023
# Purpose: Run FASTQC on the files contained in listed directories

# Requires the list of directories: 2023DEC09_DirectoryList.csv
# Slurm task IDs are used to index the list of directories

# Slurm parameters
#SBATCH --job-name=FastQC1 #Job name
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --mem 32Gb
#SBATCH --time 30:00 # time alloted before quitting
#SBATCH --array=1-93
#SBATCH --output=../slurmout/fastqc1_%A_%a.out
#SBATCH --error=../slurmout/fastqc1_%A_%a.err

DATA_DIR=$1 # path to parent directory of input file directories
DIR_SHEET=$2 # path to 2023DEC09_DirectoryList.csv
NEW_PATH=$3 # path to output directory
FILE_TYPE=$4 # file type to search for in directories ie .fastq.gz

# Print info about the Slurm task.
START=`date +%s`
date
echo "Host Name: " $HOSTNAME
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID

# Make the output directory for FASTQC
CURRENT_DIR=`sed -n "$SLURM_ARRAY_TASK_ID"p $DIR_SHEET`
CLEAN_CD=`echo $CURRENT_DIR | tr -dc '[:alnum:]._-'`
echo $CLEAN_CD
[[ -d "$NEW_PATH/$CLEAN_CD" ]] || mkdir -p "$NEW_PATH/$CLEAN_CD"

module load biology
module load fastqc

# Get the names of the input files for FASTQC.
if [[ $FILE_TYPE ]]; then
	MY_FILES=`find $DATA_DIR/$CLEAN_CD -type f -name "*$FILE_TYPE"`
else
	MY_FILES=`find $DATA_DIR/$CLEAN_CD -type f -name`
fi

# Run FASTQC on the files.
CALL="fastqc $MY_FILES --outdir $NEW_PATH/$CLEAN_CD --threads 6"

echo $CALL
eval $CALL

# Test if previous command executed successfully
if [ $? -eq 0 ]; then
	echo SUCCESS
else
	echo FAILED
fi

END=`date +%s`
RUNTIME=$((END-START))
echo "Run Time: " $RUNTIME