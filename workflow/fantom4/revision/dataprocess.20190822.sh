mkdir -p download
mkdir -p filtered
mkdir -p STAR
mkdir -p log
mkdir -p bam

perl rdf.pl -d fantom4.sqlite3 prompt fantom4 '#species' "Species [default is human] ? " human
species=`perl rdf.pl -d fantom4.sqlite3 object fantom4 '#species'`
perl rdf.pl -d fantom4.sqlite3 prompt $species '#rDNA' "Path to $species rDNA [default is download] ? "
perl rdf.pl -d fantom4.sqlite3 prompt $species '#genome' "Path to $species genome [default is download] ? "
perl rdf.pl -d fantom4.sqlite3 install tagdust STAR samtools bedtools
perl rdf.pl -d fantom4.sqlite3 -q rmexec

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$root->#species->human' \
-o 'human->#rDNA->$output' \
https://moirai2.github.io/database/ncbi/download_human_ribosomal_DNA.json \
'$output=download/human_rDNA.fa'

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$root->#species->mouse' \
-o 'mouse->#rDNA->$output' \
https://moirai2.github.io/database/ncbi/download_mouse_ribosomal_DNA.json \
'$output=download/mouse_rDNA.fa'

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$root->#species->human' \
-o 'human->#genome->$path' \
https://moirai2.github.io/database/genome/Homo_sapiens_hg38_chronly.json \
'$output=download/hg38.fa'

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$root->#species->mouse' \
-o 'human->#genome->$path' \
https://moirai2.github.io/database/genome/Mus_musculus_mm10_chronly.json \
'$output=download/mm10.fa'

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$root->#species->human' \
-o 'human->#fastq->$output' \
https://moirai2.github.io/database/fantom/fantom4_download_human_CAGE_FASTQ.json \
'$output=download/fantom4.humanCAGE.fq.gz'

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$root->#species->mouse' \
-o 'mouse->#fastq->$output' \
https://moirai2.github.io/database/fantom/fantom4_download_mouse_CAGE_FASTQ.json \
'$output=download/fantom4.mouseCAGE.fq.gz'

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$species->#fastq->$fastq' \
-o '$fastq->#seqcount->$count' \
https://moirai2.github.io/command/fastq/countseq.json

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$species->#fastq->$input,$species->#rDNA->$reference' \
-o '$species->#filtered->$filtered,$species->#tagdustlog->$log' \
https://moirai2.github.io/command/tagdust/tagdust_single.json \
'$filtered=filtered/fantom4.${species}CAGE.fq.gz' \
'$log=filtered/fantom4.${species}CAGE.log' \
'$artifact=filtered/fantom4.${species}CAGE.artifact.fq.gz'

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$species->#genome->$reference' \
-o '$species->#starindex->$outdir' \
https://moirai2.github.io/command/STAR/index_reference.json \
'$outdir=STAR/${species}' \
'$stdout=STAR/${species}/stdout.txt' \
'$stderr=STAR/${species}/stderr.txt' \
'$log=STAR/${species}/log.txt'

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$species->#filtered->$input,$species->#starindex->$starindex' \
-o '$species->#bam->$bam,$species->#starlog->$log' \
https://moirai2.github.io/command/STAR/align_single.json \
'$bam=bam/fantom4.${species}CAGE.bam' \
'$log=bam/fantom4.${species}CAGE.log'
