#!/bin/bash

# this is extended script from `get_tile_information_from_fasta.py`
# python script to fetch headers from Nova-ST fastq run files and check for tile numbers and write each tile reads into seperate fastq files

# Example command:

import sys, os

import gzip
from Bio import SeqIO

all_seq_dict = {}   # dictionary where all sequences will be stored per tile as a key

in_fasta = sys.argv[1]
file = gzip.open(in_fasta, "rt")
fq = SeqIO.parse(file, "fastq")

print("Reading and storing fastq read per tile")
for read in fq:
    tile_number = read.name.split(":")[4]
    print(read.name, tile_number)

    if tile_number not in all_seq_dict.keys():
        all_seq_dict[tile_number] = []
    
    all_seq_dict[tile_number].append(read)

print("Writing per tile reads into files")
for each_key in all_seq_dict.keys():
    print(each_key)
    outfile = os.path.dirname(in_fasta) + "/per_tile_data/" + os.path.basename(in_fasta).replace(".txt.gz", "").replace(".fastq.gz", "") + "_tile_" + each_key  + ".fastq.gz"
    fout = gzip.open(outfile, "wt")
    #with open(outfile, "w") as fout:
    SeqIO.write(all_seq_dict[each_key], fout, "fastq")
    fout.close()
