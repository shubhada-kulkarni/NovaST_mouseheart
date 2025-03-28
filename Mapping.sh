#!/bin/bash
#
# shell script to submit mapping job for Nova-ST pilot sample data
#
#
#
#SBATCH --mem=500G
#SBATCH -J "NovaST_mapping"
#SBATCH --mail-type=END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user=shubhada.kulkarni@uni-heidelberg.de
#SBTACH -o "%j.out"
#SBTACH -e "%j.err"

GENOME_DIR="/biodb/genomes/mus_musculus/GRCm38_102/star"

# output="/prj/NovaST/Dieterich_AAGMTVHM5/data/mapping_output/"
output="/prj/NovaST/Dieterich_AAGMTVHM5/data/mapping_output_noN/"
if [ ! -d "$output" ]; then
  echo "$output does not exist. Creating one!"
  mkdir $output
fi

# BARCODE_WHITELIST_FILE="/prj/NovaST/Dieterich_AAGMTVHM5/data/whitelist_AAGMTVHM5_NovaST_25s000253-1-1_Dieterich_lane1sample1_1_1_tiles_3_to_9_31bp.tsv"
BARCODE_WHITELIST_FILE="/prj/NovaST/Dieterich_AAGMTVHM5/data/whitelist_AAGMTVHM5_NovaST_25s000253-1-1_Dieterich_lane1sample1_1_1_tiles_3_to_9_31bp_noN.tsv"
r1="/prj/NovaST/Dieterich_AAGMTVHM5/data/AAGMTVHM5_NovaST_25s000253-1-1_Dieterich_lane1sample1_1_sequence.txt.gz"
r1_umi="/prj/NovaST/Dieterich_AAGMTVHM5/data/AAGMTVHM5_NovaST_25s000253_R1_UMIs.fastq.gz"

echo $r1, $r1_umi

cd /prj/NovaST/Dieterich_AAGMTVHM5/data/

pwd

module unload star
module load star/2.7.10a
#module load star/2.7.7a

echo "First genome load command"

ulimit -n 10000

STAR --genomeLoad Remove --genomeDir ${GENOME_DIR}
STAR --genomeLoad LoadAndExit --genomeDir ${GENOME_DIR}
rm -r _STARtmp Log.out Log.progress.out Aligned.out.sam

echo "Starting to map!"
date
STAR \
    --soloType CB_UMI_Simple \
    --sjdbGTFfile "/biodb/genomes/mus_musculus/GRCm38_102/GRCm38.102.gtf" \
    --soloCBwhitelist ${BARCODE_WHITELIST_FILE} \
    --soloCBstart 1 \
    --soloCBlen 31 \
    --soloUMIstart 32 \
    --soloUMIlen 9 \
    --soloBarcodeMate 0 \
    --soloBarcodeReadLength 0 \
    --soloFeatures Gene GeneFull \
    --soloCBmatchWLtype 1MM \
    --soloUMIdedup 1MM_All \
    --soloCellFilter None \
    --outSAMtype BAM SortedByCoordinate \
    --outSAMattributes NH HI AS nM CR CY UR UY CB UB sS \
    --runThreadN 36 \
    --genomeDir ${GENOME_DIR} \
    --genomeLoad NoSharedMemory \
    --limitBAMsortRAM 50000000000 \
    --readFilesIn $r1 $r1_umi \
    --readFilesCommand zcat \
    --outFileNamePrefix $output/"output_" \
    --outReadsUnmapped Fastx

echo "Mapping finished!"
date
# readFilesIn should be two lists of comma seperated values. The first should be Read 2 files and the second should be read 1 files
# STARsolo can only do error corretion with 31 bases, so we ignore the last base.
