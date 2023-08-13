#!/bin/bash
# Author: Tamar Feldman
# Project: Feldman et al. Blood Adv. 2023
# Purpose: Create the genome indices used by STAR from .fa and .gtf files

# Slurm parameters
#SBATCH --job-name=star_index
#SBATCH --time=120
#SBATCH --ntasks=8
#SBATCH --nodes=1
#SBATCH --mem=40000
#SBATCH --output=../slurmout/starin_%A_%a.out
#SBATCH --error=../slurmout/starin_%A_%a.err



OUTPUT_DIR=$1 # path to output directory for indices
REF_DIR=$2 # path to directory containing reference files
FASTA=$3 # basename of fa file
GTF=$4 # basename of gtf file
OVERHANG=$5 # STAR parameter based on read length (use 149 for this project)

START=`date +%s`
date
echo $HOSTNAME

[[ -d $OUTPUT_DIR ]] || mkdir -p $OUTPUT_DIR

# Decompress files for STAR input
zcat "$REF_DIR/$FASTA.gz" > "$REF_DIR/$FASTA"
zcat "$REF_DIR/$GTF.gz" > "$REF_DIR/$GTF"

# Test that the previous command executed successfully
if [ $? -eq 0 ]; then
	echo SUCCESS
else
	echo FAILED
fi

# Run STAR in genomeGenerate mode to make indices
module load biology
module load star
CALL="STAR --runThreadN 8 \
	--runMode genomeGenerate \
	--genomeDir $OUTPUT_DIR \
	--genomeFastaFiles $REF_DIR/$FASTA \
	--sjdbGTFfile $REF_DIR/$GTF \
	--sjdbOverhang ${OVERHANG}"

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
