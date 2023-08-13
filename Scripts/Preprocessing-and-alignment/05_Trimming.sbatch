#!/bin/bash
# Author: Tamar Feldman
# Project: Feldman et al. Blood Adv. 2023
# Purpose: Perform quality and adapter trimming on raw .fastq files

# Requires a list of sample directories: 2023DEC09_DirectoryList.csv

# Slurm parameters
#SBATCH --job-name=TRIMGL1 #Job name
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem 32Gb
#SBATCH --time 4:00:00 # time alloted before quitting
#SBATCH --array=1-93
#SBATCH --output=../slurmout/trimgl_%A_%a.out
#SBATCH --error=../slurmout/trimgl_%A_%a.err


DATA_DIR=$1 # path to parent directory of input file directories
DIR_SHEET=$2 # path to 2023DEC09_DirectoryList.csv
NEW_PATH_DATA=$3  # path to parent output directory for trimmed fastq files
NEW_PATH_FASTQC=$4 # path to parent output directory for FastQC

# Print information about slurm task.
START=`date +%s`
date
echo "Host Name: " $HOSTNAME # where task is being run
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID # which sample

# Set up the output directory for the current sample
CURRENT_DIR=`sed -n "$SLURM_ARRAY_TASK_ID"p $DIR_SHEET`
CLEAN_CD=`echo $CURRENT_DIR | tr -dc '[:alnum:]._-'`
echo $CLEAN_CD

[[ -d "$NEW_PATH_DATA/$CLEAN_CD" ]] || mkdir -p "$NEW_PATH_DATA/$CLEAN_CD"
[[ -d "$NEW_PATH_FASTQC/$CLEAN_CD" ]] || mkdir -p "$NEW_PATH_FASTQC/$CLEAN_CD"

# Run TrimGalore with FastQC on fastq files
module load biology
module load trim_galore
for i in L001 L002; do
	# Get fastq files
	FASTA1=`find $DATA_DIR/$CLEAN_CD -type f -name "*${i}_R1*"`
	FASTA2=`find $DATA_DIR/$CLEAN_CD -type f -name "*${i}_R2*"`
	echo $FASTA1
	echo $FASTA2
	# Run trim galore
	CALL="trim_galore $FASTA1 $FASTA2 \
		-q 20 \
		--paired \
		-a2 AGATCGGAAGAGC \
		--stringency 5 \
		--length 20 \
		--output_dir $NEW_PATH_DATA/$CLEAN_CD \
		--fastqc_args \"-o $NEW_PATH_FASTQC/$CLEAN_CD --threads 4\""
	echo $CALL
	eval $CALL

	# Test if previous command executed successfully
	if [ $? -eq 0 ]; then
		echo SUCCESS
	else
		echo FAILED
	fi
done

END=`date +%s`
RUNTIME=$((END-START))
echo "Run Time: " $RUNTIME