#!/bin/bash
# Purpose: Run FASTQC on fastq files in each directory
# Author: Tamar Feldman

#SBATCH --job-name=FastQC1 #Job name
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --mem 32Gb
#SBATCH --time 30:00 # time alloted before quitting
#SBATCH --array=1-93
#SBATCH --output=../slurmout/fastqc1_%A_%a.out
#SBATCH --error=../slurmout/fastqc1_%A_%a.err

DATA_DIR=$1 # path/to/directory/with/input/files
DIR_SHEET=$2 # path/to/list/of/sample/directories
NEW_PATH=$3 # path/to/output/directory
FILE_TYPE=$4 # file/type/to/analyze

START=`date +%s`
date
echo "Host Name: " $HOSTNAME # where task is being run
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID # which sample

# Set up output directory
CURRENT_DIR=`sed -n "$SLURM_ARRAY_TASK_ID"p $DIR_SHEET`
CLEAN_CD=`echo $CURRENT_DIR | tr -dc '[:alnum:]._-'`
echo $CLEAN_CD

[[ -d "$NEW_PATH/$CLEAN_CD" ]] || mkdir -p "$NEW_PATH/$CLEAN_CD"

module load biology
module load fastqc

# Get names of input files
if [[ $FILE_TYPE ]]; then
	MY_FILES=`find $DATA_DIR/$CLEAN_CD -type f -name "*$FILE_TYPE"`
else
	MY_FILES=`find $DATA_DIR/$CLEAN_CD -type f -name
fi

# Run FASTQC
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