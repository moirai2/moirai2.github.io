#!/bin/sh
# human single DRA001287 => DRP001358
# mouse paired GSE90487 => SRP093881
# mouse single E-MTAB-3543 =>
# human single PRJEB8994 =>
# umap clustering
# gene coverage
# kraken crona
# expression table TPM
mkdir -p data
mkdir -p data/fasta

perl rdf.pl -d singlecell.sqlite3 -q rmexec
esearch -db nucleotide -query 'complete genome & Wuhan & corona & virus'|efetch -format fasta > data/fasta/wuhan_corona.fa
esearch -db nucleotide -query 'complete genome & corona & virus'|efetch -format fasta > data/fasta/corona_virus.fa
