#!/bin/bash
# Author: Tamar Feldman
# Project: Feldman et al. Blood Adv. 2023
# Purpose: Run FASTQC on the files contained in listed directories

# Requires the list of directories: 2023DEC09_DirectoryList.csv

DIR_SHEET=$1 # path to list of sample directories
NEW_PATH=$2 # path to output directory for tabulated counts
DATA_DIR=$3 # path to parent directory of input file directories
OUTPUT_NAME=$4 # name for output file with tabulated gene counts
SUFFIX=$5 # use if suffix was added to the file names for alignment

[[ -d $NEW_PATH ]] || mkdir -p $NEW_PATH/tmp

# Move relevant count col from each sample to temp dir
for SAMPLE in `cut -f1 -d ',' $DIR_SHEET`; do
	SAMPLE_CLEAN=`echo $SAMPLE | tr -dc '[:alnum:]._-'`
	echo "$SAMPLE_CLEAN"
	cat "$DATA_DIR/$SAMPLE_CLEAN/${SAMPLE_CLEAN}_${SUFFIX}ReadsPerGene.out.tab" | \
	tail -n +5 | \
	cut -f2 > "$NEW_PATH/tmp/$SAMPLE_CLEAN.count"
done

# Get the first column of gene ids from a sample
tail -n +5 "$DATA_DIR/$SAMPLE_CLEAN/${SAMPLE_CLEAN}_${SUFFIX}ReadsPerGene.out.tab" | \
cut -f1 > "$NEW_PATH/tmp/geneids.txt"

paste "$NEW_PATH/tmp/geneids.txt" $NEW_PATH/tmp/*.count > "$NEW_PATH/tmp/tmp.out"

for x in $DATA_DIR/*; do
	s=`basename $x`
	echo $s
done | paste -s > header.txt
cat <( echo -ne 'Gene.ID\t'; cat header.txt ) > header_final.txt
cat header_final.txt "$NEW_PATH/tmp/tmp.out" > "$NEW_PATH/$OUTPUT_NAME.txt"
