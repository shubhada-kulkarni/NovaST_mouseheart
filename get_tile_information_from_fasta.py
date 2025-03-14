#!/bin/bash

# python script to fetch headers from Nova-ST fastq run files and check for tile numbers

# Example command:
# python get_tile_information_from_fasta.py /prj/NovaST/Dieterich_AAGMTVHM5/data/AAGMTVHM5_NovaST_25s000253-1-1_Dieterich_lane1sample1_1_sequence.txt.gz

# Example command with SLURM:
#

import sys, os

import gzip
from Bio import SeqIO

headers = []

tile_list = []

in_fasta = sys.argv[1]
file = gzip.open(in_fasta, "rt")
fq = SeqIO.parse(file, "fastq")
for read in fq:
    tile_number = read.name.split(":")[4]
    #print(read.name, tile_number)

    if tile_number not in tile_list:
        tile_list.append(tile_number)

outfile = in_fasta.replace(".txt.gz", "").replace(".fastq.gz", "") + "_tiles_RTA3" + ".cfg"

with open(outfile, "w") as fout:
    fout.write("\n".join(tile_list))
