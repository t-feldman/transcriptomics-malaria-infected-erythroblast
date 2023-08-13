#!/bin/bash
# Author: Tamar Feldman
# Project: Feldman et al. Blood Adv. 2023
# Purpose: Remove rRNA, hemoglobin and PhiX reads to speed up alignment

# Requires the list of directories: 2023DEC09_DirectoryList.csv
# Needs to be run separately for L001 and L002 (flowcell lane)

# Slurm parameters
#SBATCH --job-name=Decon2 #Job name
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem 32Gb
#SBATCH --time 2:00:00 # time alloted before quitting
#SBATCH --array=1
#SBATCH --output=../slurmout/decon_%A_%a.out
#SBATCH --error=../slurmout/decon_%A_%a.err

DATA_DIR=$1 # path to parent directory of input file directories
DIR_SHEET=$2 # path to 2023DEC09_DirectoryList.csv
NEW_PATH_DATA=$3 # path to output cleaned fastq files
PATH_FASTA=$4 # path to .fasta containing reference sequences
LANE=$5 # indicate from which sequencing lane the fastq files originate

# Print Slurm task information.
START=`date +%s`
date
echo "Host Name: " $HOSTNAME # where task is being run
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID # which sample

# Set up the output directory for cleaned fastq files.
CURRENT_DIR=`sed -n "$SLURM_ARRAY_TASK_ID"p $DIR_SHEET`
CLEAN_CD=`echo $CURRENT_DIR | tr -dc '[:alnum:]._-'`
echo $CLEAN_CD
[[ -d "$NEW_PATH_DATA/$CLEAN_CD" ]] || mkdir -p "$NEW_PATH_DATA/$CLEAN_CD"

# Function to test if previous command executed successfully
function testSuccess {
	if [ $? -eq 0 ]; then
		echo SUCCESS
	else
		echo FAILED
	fi
}
# Get the names of the matching pairs of fastq.gz files
FASTA1=`find $DATA_DIR/$CLEAN_CD -name "*${LANE}*val_1*"`
echo ${FASTA1}
FASTA2=`find $DATA_DIR/$CLEAN_CD -name "*${LANE}*val_2*"`
echo ${FASTA2}

# Use bbmap tools to align reads against undesirable sequences
module load java
# Align to contaminating sequences
CALL1="java -ea -Xmx32g -cp ~/bbmap/current align2.BBMap in1=$FASTA1 in2=$FASTA2 \
	ref=$PATH_FASTA outm=$NEW_PATH_DATA/$CLEAN_CD/contaminated_${CLEAN_CD}_${LANE}.sam \
	outu=$NEW_PATH_DATA/$CLEAN_CD/clean_${CLEAN_CD}_${LANE}.fq"

# split interleaved file into R1 and R2 fastq files
CALL2="java -ea -Xmx32g -cp ~/bbmap/current jgi.ReformatReads \
	in=$NEW_PATH_DATA/$CLEAN_CD/clean_${CLEAN_CD}_${LANE}.fq \
	out1=$NEW_PATH_DATA/$CLEAN_CD/clean_R1_${CLEAN_CD}_${LANE}.fq \
	out2=$NEW_PATH_DATA/$CLEAN_CD/clean_R2_${CLEAN_CD}_${LANE}.fq"

for i in "$CALL1" "$CALL2"; do
	echo $i
	eval $i
	testSuccess
done

END=`date +%s`
RUNTIME=$((END-START))
echo "Run Time: " $RUNTIME