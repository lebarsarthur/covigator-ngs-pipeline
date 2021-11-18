#!/bin/bash

##################################################################################
# FASTQ input
# single-end reads
# use --input_fastqs_list
##################################################################################
echo "Running CoVigator pipeline test 7"
source bin/assert.sh
output=output/test7
echo -e "test_data\t"`pwd`"/test_data/test_data_1.minimal.fastq.gz\n" > test_data/test_input.txt
nextflow main.nf -profile test,conda --input_fastqs_list test_data/test_input.txt \
--library single --output $output \
--skip_ivar --skip_bcftools --skip_gatk

test -s $output/test_data.lofreq.normalized.annotated.vcf.gz || { echo "Missing VCF output file!"; exit 1; }
test -s $output/test_data.fastp_stats.json || { echo "Missing VCF output file!"; exit 1; }
test -s $output/test_data.fastp_stats.html || { echo "Missing VCF output file!"; exit 1; }
test -s $output/test_data.coverage.tsv || { echo "Missing coverage output file!"; exit 1; }
test -s $output/test_data.depth.tsv || { echo "Missing depth output file!"; exit 1; }
test -s $output/test_data.depth.tsv || { echo "Missing deduplication metrics file!"; exit 1; }
test -s $output/test_data.lofreq.pangolin.csv || { echo "Missing pangolin output file!"; exit 1; }

assert_eq `zcat $output/test_data.lofreq.normalized.annotated.vcf.gz | grep -v '#' | wc -l` 11 "Wrong number of variants"
assert_eq `zcat $output/test_data.lofreq.normalized.annotated.vcf.gz | grep -v '#' | grep PASS | wc -l` 2 "Wrong number of variants"

assert_eq `cat $output/test_data.lofreq.pangolin.csv |  wc -l` 2 "Wrong number of pangolin results"
