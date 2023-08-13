#!/bin/bash
# Author: Tamar Feldman
# Project: Feldman et al. Blood Adv. 2023
# Purpose: Align reads to concatenated genome and sum gene counts using STAR

# Requires the list of directories: 2023DEC09_DirectoryList.csv

#Slurm parameters
#SBATCH --job-name=STAR #Job name
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem 64Gb
#SBATCH --time 4:00:00 # time alloted before quitting
#SBATCH --array=1-12
#SBATCH --output=../slurmout/stara_%A_%a.out
#SBATCH --error=../slurmout/stara_%A_%a.err

DIR_SHEET=$1 # path to list of sample directories
GENOME_DIR=$2 # path directory containing genome indices
DATA_DIR=$3 # path to parent directory of sample directories
NEW_PATH=$4 # path to output directory

START=`date +%s`
date
echo "Host Name: " $HOSTNAME # where task is being run
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID # which sample

# Set up the output directory
CURRENT_DIR=`sed -n "$SLURM_ARRAY_TASK_ID"p $DIR_SHEET`
CLEAN_CD=`echo $CURRENT_DIR | tr -dc '[:alnum:]._-'`
echo $CLEAN_CD
[[ -d "$NEW_PATH/$CLEAN_CD" ]] || mkdir -p "$NEW_PATH/$CLEAN_CD"

# Get the appropriate fastq files
READ1=`find $DATA_DIR/$CLEAN_CD -type f -name "*R1*fq"`

echo $READ1

READ2=`find $DATA_DIR/$CLEAN_CD -type f -name "*R2*fq"`

echo $READ2

# Run STAR to align reads and record gene counts
module load biology
module load star

CALL="STAR --runThreadN 8 \
	--genomeDir $GENOME_DIR \
	--readFilesIn ${READ1} ${READ2} \
	--outFilterType BySJout \
	--outFilterMultimapNmax 20 \
	--alignSJoverhangMin 8 \
	--alignSJDBoverhangMin 1 \
	--outFilterMismatchNmax 999 \
	--outFilterMismatchNoverReadLmax 0.04 \
	--alignIntronMin 20 \
	--alignIntronMax 1000000 \
	--alignMatesGapMax 1000000 \
	--outSAMtype BAM SortedByCoordinate \
	--quantMode GeneCounts \
	--outFileNamePrefix $NEW_PATH/$CLEAN_CD/${CLEAN_CD}_aligned"

echo $CALL
eval $CALL

# test for successful execution
if [ $? -eq 0 ]; then
	echo SUCCESS
else
	echo FAILED
fi

END=`date +%s`
RUNTIME=$((END-START))
echo "Run Time: " $RUNTIME
