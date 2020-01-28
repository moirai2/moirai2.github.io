mkdir -p split
perl rdf.pl -d fantom5.sqlite3 import < dump.txt

perl moirai2.pl -q -m 1 \
-d fantom5.sqlite3 \
-i '$libraryid->#read1->$raw1,$libraryid->#read2->$raw2,$libraryid->#barcodes->$barcodes' \
-o '$libraryid->#split->$output' \
https://moirai2.github.io/command/fantom/splitTrueSeqByBarcode.json \
'$outdir=split'

perl moirai2.pl -q -m 1 \
-d fantom5.sqlite3 \
-i '$libraryid->#read1->$raw,$libraryid->#barcodes->$barcodes' \
-o '$libraryid->#split->$output' \
https://moirai2.github.io/command/fantom/splitByBarcode.json \
'$outdir=split'
