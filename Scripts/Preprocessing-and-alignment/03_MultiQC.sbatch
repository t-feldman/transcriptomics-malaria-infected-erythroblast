#!/bin/bash
# Purpose: Run multiQC to aggregate results
# Author: Tamar Feldman

#SBATCH --job-name=MultiQC #Job name
#SBATCH --nodes=1
#SBATCH --mem 32Gb
#SBATCH --time 2:00:00 # time alloted before quitting
#SBATCH --output=../slurmout/multiqc_%A.out
#SBATCH --error=../slurmout/multiqc_%A.err

DATA_DIR=$1 # path/to/directory/with/input/files
NEW_PATH=$2 # path/to/output/directory
FILE_PATTERN=$3 # pattern to search for correct files

START=`date +%s`
date

echo "Host Name: " $HOSTNAME # where task is being run

# make output directory
 [[ -d "$NEW_PATH" ]] || mkdir "$NEW_PATH"

echo "output directory: $NEW_PATH"
echo "input directory: $DATA_DIR"

module load biology
module load py-multiqc

# Relic from outdated code "Get files to analyze" - commented out
#MY_FILES=`find $DATA_DIR/$CLEAN_CD -name "*$FILE_PATTERN*"`

# Run multiqc
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
