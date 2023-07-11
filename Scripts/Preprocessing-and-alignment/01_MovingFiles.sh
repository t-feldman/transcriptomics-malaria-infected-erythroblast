#!/bin/bash
# Purpose: Move fastq files into sample directories using sample sheet
# Author: Tamar Feldman

DATA_DIR=$1 # Where the data are currently stored
NEW_PATH=$2 # Path to new parent directory
SAMPLE_SHEET=$3 # Path to sample sheet
# use compound function to skip headers with extra read
# need extra variable to contain remaining columns
{
	read
	while IFS=, read -r FLNAME NEW_DIR EXTRA;
	do
		echo "Name : $FLNAME"
		echo "Directory name: $NEW_DIR"
		# remove any non-alnum or punct

		CLEAN_FL=${FLNAME//[^[:graph:]]/}
		CLEAN_ND=${NEW_DIR//[^[:graph:]]/}


		# check if directory exists & make if needed
		[[ -d "$NEW_PATH/$NEW_DIR" ]] || mkdir -p "$NEW_PATH/$NEW_DIR"

		#if the file exists, copy file to new directory
		if test -f "$DATA_DIR/$CLEAN_FL"; then
			cp "$DATA_DIR/$CLEAN_FL" "$NEW_PATH/$NEW_DIR/"
		else
			echo "${CLEAN_FL} does not exist"
		fi
	done
} < $SAMPLE_SHEET

