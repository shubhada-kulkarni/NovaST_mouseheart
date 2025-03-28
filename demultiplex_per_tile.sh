#!/bin/bash

# This script demultiplexes a sequencing run into separate fastq files for each tile per lane using bcl2fastq - adapted from https://github.com/aertslab/Nova-ST.

# Usage: demultiplex_per_tile.sh <run_folder> <output_folder> <num_threads> <revcom>
# Example: 
#
mkdir -p ${2} 2> /dev/null

# Get list of tiles from the RTA3 file in the run folder
# This RTA3 file was created using "get_tile_information_from_fasta.py" script. As you already write tile numbers to the cfg file, no need to run following script
## grep "Tile=" ${1}/RTA3.cfg | sed 's/^Tile=//' | sed 's/ /\n/g' > ${2}/tiles_to_process.txt

tile_file=${6}

# Is reverse complementing needed?
if [[ ${4} == "true" ]]; then
    echo "Reverse complementing barcodes"
    REVCOM="--write-fastq-reverse-complement"
else
    echo "Not reverse complementing barcodes"
    REVCOM=""
fi

# Loop over all tiles and create fastqs using parallel
# First make a child folder for each tile
for tile in `cat $tile_file`; do
    mkdir -p ${2}/${tile} 2> /dev/null
done

parallel --jobs ${3} --joblog ${2}/parallel.log --resume-failed "bcl2fastq -R ${1} -o ${2}/{} -r 1 -p 1 -w 1 --tiles s_{} ${REVCOM} --use-bases-mask=y32n* --minimum-trimmed-read-length=32 2> /dev/null" :::: $tile_file

for tile in `cat $tile_file`;
do
    # See if there is at least one fastq file in the tile folder
    if [[ `ls ${2}/${tile}/*.fastq.gz 2> /dev/null | wc -l` == 0 ]]; then
        echo "No fastq files found for tile ${tile}!"
    else
        mv ${2}/${tile}/*.gz ${2}/${tile}.fastq.gz 2> /dev/null
    rm -rf ${2}/${tile} 2> /dev/null
done

