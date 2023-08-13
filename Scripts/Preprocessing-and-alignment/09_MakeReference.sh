#!/bin/bash
# Author: Tamar Feldman
# Project: Feldman et al. Blood Adv. 2023
# Purpose: Retrieve reference genomes and annotations and concatenate

REF_DIR=$1 # path to output directory for reference files
# make directory in files for reference sequences
[[ -d "$REF_DIR" ]] || mkdir -p "$REF_DIR"

# get reference genome
wget -P "$REF_DIR" ftp://ftp.ensemblgenomes.org/pub/protists/\
current/fasta/plasmodium_falciparum/dna/Plasmodium_falciparum.ASM276v2.dna.toplevel.fa.gz

# get reference genome annotations
wget -P "$REF_DIR" ftp://ftp.ensemblgenomes.org/pub/protists/\
current/gtf/plasmodium_falciparum/Plasmodium_falciparum.ASM276v2.52.gtf.gz

# get reference genome
wget -P "$REF_DIR" ftp://ftp.ensembl.org/pub/release-100/fasta/\
homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz

# get reference genome annotations
wget -P "$REF_DIR" ftp://ftp.ensembl.org/pub/current_gtf/\
homo_sapiens/Homo_sapiens.GRCh38.105.gtf.gz

# Prefix chromosome labels with Pf
zcat "$REF_DIR"/Plasmodium_falciparum.ASM276v2.52.gtf.gz | \
	sed 's/^/Pf/' > "$REF_DIR"/Pf_modified.gtf
# Remove header so the file can be concatenated with the Hs file
tail -n +6 "$REF_DIR"/Pf_modified.gtf > "$REF_DIR"/Pf_modified_final.gtf
# Compress file
gzip -c "$REF_DIR"/Pf_modified_final.gtf > "$REF_DIR"/Pf_modified_final.gtf.gz

# Remove header so the file can be concatenated with the Hs file
zcat "$REF_DIR"/Plasmodium_falciparum.ASM276v2.dna.toplevel.fa.gz | \
	 sed 's/^>/>Pf/' > "$REF_DIR"/Pf_modified_final.fa
# Compress file
gzip -c "$REF_DIR"/Pf_modified_final.fa > "$REF_DIR"/Pf_modified_final.fa.gz

# Concatenate
cat "$REF_DIR"/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz \
	"$REF_DIR"/Pf_modified_final.fa.gz > "$REF_DIR"/concatenated_Hs_Pf.fa.gz

cat "$REF_DIR"/Homo_sapiens.GRCh38.105.gtf.gz \
	"$REF_DIR"/Pf_modified_final.gtf.gz > "$REF_DIR"/concatenated_Hs_Pf.gtf.gz