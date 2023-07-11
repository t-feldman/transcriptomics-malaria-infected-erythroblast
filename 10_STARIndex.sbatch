#!/bin/bash
# This script creates the genome indices used by STAR from .fa and .gtf files

#SBATCH --job-name=star_index
#SBATCH --time=120
#SBATCH --ntasks=8
#SBATCH --nodes=1
#SBATCH --mem=40000
#SBATCH --output=../slurmout/starin_%A_%a.out
#SBATCH --error=../slurmout/starin_%A_%a.err

START=`date +%s`
date
echo $HOSTNAME

module load biology
module load star

OUTPUT_DIR=$1 # path/to/put/indices
REF_DIR=$2 # path/to/directory/with/reference
FASTA=$3 # basename of fa file
GTF=$4 # basename of gtf file
OVERHANG=$5 # based on read length (149)

[[ -d $OUTPUT_DIR ]] || mkdir -p $OUTPUT_DIR

zcat "$REF_DIR/$FASTA.gz" > "$REF_DIR/$FASTA"
zcat "$REF_DIR/$GTF.gz" > "$REF_DIR/$GTF"

# test that previous command executed successfully
if [ $? -eq 0 ]; then
	echo SUCCESS
else
	echo FAILED
fi

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