mkdir -p download
mkdir -p input
mkdir -p filtered
mkdir -p bam

perl rdf.pl -d fantom4.sqlite3 -q insert fantom4 '#species' human
perl rdf.pl -d fantom4.sqlite3 -q insert fantom4 '#species' mouse
perl rdf.pl -d fantom4.sqlite3 prompt human '#rDNA' "Path to human rDNA [default is download] ? "
perl rdf.pl -d fantom4.sqlite3 prompt mouse '#rDNA' "Path to mouse rDNA [default is download] ? "
perl rdf.pl -d fantom4.sqlite3 prompt human '#genome' "Path to human genome [default is download] ? "
perl rdf.pl -d fantom4.sqlite3 prompt mouse '#genome' "Path to mouse genome [default is download] ? "
perl rdf.pl -d fantom4.sqlite3 install tagdust nexalign samtools bedtools
perl rdf.pl -d fantom4.sqlite3 -q rmexec

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$root->#species->human' \
-o 'human->#rDNA->$output' \
https://moirai2.github.io/database/ncbi/getHumanRibosomalDNA.json \
'$output=download/human_rDNA.fa'

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$root->#species->mouse' \
-o 'mouse->#rDNA->$output' \
https://moirai2.github.io/database/ncbi/getMouseRibosomalDNA.json \
'$output=download/mouse_rDNA.fa'

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$root->#species->human' \
-o 'human->#fastq->$output' \
https://moirai2.github.io/database/fantom/fantom4DownloadHumanCAGE.json \
'$output=input/fantom4.humanCAGE.fq.gz'

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$root->#species->mouse' \
-o 'mouse->#fastq->$output' \
https://moirai2.github.io/database/fantom/fantom4DownloadMouseCAGE.json \
'$output=input/fantom4.mouseCAGE.fq.gz'

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
'$log=filtered/fantom4.${species}CAGE.log'

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$species->#filtered->$input,$species->#starindex->$starindex' \
-o '$species->#bam->$bam,$species->#starlog->$log' \
https://moirai2.github.io/command/STAR/align_single.json \
'$bam=bam/fantom4.${species}CAGE.bam' \
'$log=bam/fantom4.${species}CAGE.log'
