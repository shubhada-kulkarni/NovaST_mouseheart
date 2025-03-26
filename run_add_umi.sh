#!/bin/bash
#
# script to submit jobs for adding UMIs to R1 file per tile

# this script submits array job

#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=250G
#SBATCH -J "UMI_addition_per_tile"
#SBTACH -o "%j.out"
#SBTACH -e "%j.err"

# SLURM_ARRAY_TASK_ID=15

## Specify the path to the config file
# config="/prj/circtools2/Shasta/data_subset/subset_500_mapping_array.txt"
config=$1

## Extract the tile name for the current $SLURM_ARRAY_TASK_ID which will be used to further process the reads
tileid=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)

outdir="/prj/NovaST/Dieterich_AAGMTVHM5/data/per_tile_data_with_UMI/"

indir="/prj/NovaST/Dieterich_AAGMTVHM5/data/per_tile_data/"

r1_fastq=$indir"/AAGMTVHM5_NovaST_25s000253-1-1_Dieterich_lane1sample1_1_sequence_tile_"$tileid".fastq.gz"
r2_fastq=$indir"/AAGMTVHM5_NovaST_25s000253-1-1_Dieterich_lane1sample1_2_sequence_tile_"$tileid".fastq.gz"
out_r1_umi=$outdir"/AAGMTVHM5_NovaST_25s000253-1-1_UMI_tile_"$tileid".fastq.gz"

echo $SLURM_ARRAY_TASK_ID, $tileid, $r1_fastq, $r2_fastq, $out_r1_umi

echo "Starting UMI addition for tile $tileid"
date

./add_umi_to_r1_32bp.sh $r1_fastq $r2_fastq $out_r1_umi

echo "UMI addition done!"
date
