#!/bin/bash
# Author: Tamar Feldman
# Project: Feldman et al. Blood Adv. 2023
# Purpose: Move fastq files into sample directories

# Requires the sample sheet file: 2021DEC06_SampleSheet.csv
# The sample sheet associates fastq files with biological samples

# Inputs
DATA_DIR=$1 # Path to where the data are currently stored
NEW_PATH=$2 # Path to dsetination parent directory
SAMPLE_SHEET=$3 # Path to sample sheet

# Skip the header row in the sample sheet and
# use the sample sheet to get the file name and destination.
# Copy the file to the destination directory.
{
	read
	while IFS=, read -r FLNAME NEW_DIR EXTRA;
	do
		echo "Name : $FLNAME"
		echo "Directory name: $NEW_DIR"
		
		# Clean up the file name extracted from the sample sheet
		# by removing anything that is not alphanumeric or punctuation
		CLEAN_FL=${FLNAME//[^[:graph:]]/}
		CLEAN_ND=${NEW_DIR//[^[:graph:]]/}


		# check if destination directory exists & make one if needed
		[[ -d "$NEW_PATH/$NEW_DIR" ]] || mkdir -p "$NEW_PATH/$NEW_DIR"

		#if the file exists, copy file to new directory
		if test -f "$DATA_DIR/$CLEAN_FL"; then
			cp "$DATA_DIR/$CLEAN_FL" "$NEW_PATH/$NEW_DIR/"
		else
			echo "${CLEAN_FL} does not exist"
		fi
	done
} < $SAMPLE_SHEET

