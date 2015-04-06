#!/bin/bash

##########################################
##
## Texas Advanced Computing Center
## Antonio Gomez (agomez@tacc.utexas.edu)
## 2015
##
##########################################

# Retrieve my rank
rank=$(( ${PMI_RANK-0} + ${PMI_ID-0} + ${MPIRUN_RANK-0} + ${OMPI_COMM_WORLD_RANK-0} + ${OMPI_MCA_ns_nds_vpid-0} ))
echo $rank

# Create a folder in the local disk
mkdir /tmp/DATABASE

# Copy database files to local disk
lfs cp DATABASE/* /tmp/DATABASE

# Run BLAST program
blastp -query input_seq.part-$rank.fasta -db uniref90.fasta \
-num_threads 16  -outfmt 6 > blast_results.$rank

#if you need to move some of your files back
# cp /tmp/$rank/output_file output_file.$rank