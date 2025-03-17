#!/bin/bash
#
# shell script to submit python script get_tile_information_from_fasta.py as a SLURM jobs
#
#
date

readfile=$1

echo "Job started"
# running tile separation
python get_tiles_from_fasta.py $readfile


# command line for getting tile information
# python get_tile_information_from_fasta.py /prj/NovaST/Dieterich_AAGMTVHM5/data/AAGMTVHM5_NovaST_25s000253-1-1_Dieterich_lane1sample1_1_sequence.txt.gz
echo "Job ended!"

date
