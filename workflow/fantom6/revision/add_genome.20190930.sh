mkdir -p rDNA
mkdir -p genome

perl rdf.pl -d fantom6.sqlite3 prompt fantom6 '#species' "Species [default is human] ? " human
species=`perl rdf.pl -d fantom6.sqlite3 object fantom6 '#species'`
echo $species
perl rdf.pl -d fantom6.sqlite3 prompt $species '#rDNA' "Path to $species rDNA [default is download] ? "
perl rdf.pl -d fantom6.sqlite3 prompt $species '#genome' "Path to $species genome [default is download] ? "

perl moirai2.pl -m 10 \
-d fantom6.sqlite3 \
-i '$root->#species->human' \
-o 'human->#rDNA->$output' \
https://moirai2.github.io/database/ncbi/download_human_ribosomal_DNA.json \
'$output=rDNA/human_rDNA.fa'

perl moirai2.pl -m 10 \
-d fantom6.sqlite3 \
-i '$root->#species->human' \
-o 'human->#genome->$output' \
https://moirai2.github.io/database/genome/Homo_sapiens_hg38_chronly.json \
'$outdir=genome'
