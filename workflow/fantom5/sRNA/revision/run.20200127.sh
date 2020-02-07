mkdir -p data/split
mkdir -p data/filtered

echo "#3 Split single by barcode"

perl moirai2.pl -q -m 1 \
-d fantom5.sqlite3 \
-i '$libraryid->#read1->$raw1,$libraryid->#read2->$raw2,$libraryid->#barcodes->$barcodes' \
-o '$libraryid->#split->$output' \
https://moirai2.github.io/command/fantom/splitTrueSeqByBarcode.json \
'$outdir=data/split'
exit

echo "#4 Split paired by barcode"

perl moirai2.pl -q -m 1 \
-d fantom5.sqlite3 \
-i '$libraryid->#read1->$raw,$libraryid->#barcodes->$barcodes' \
-o '$libraryid->#split->$output' \
https://moirai2.github.io/command/fantom/splitByBarcode.json \
'$outdir=data/split'

echo "#5 Filter ribosomalRNA"

perl moirai2.pl \
-d singlecell.sqlite3 \
-i '$libraryid->#Run->$runid,$libraryid->#sampleid->$sampleid,$sampleid->#ScientificName->$species,$species->#rDNA->$reference' \
-o '$libraryid->#tagdustlog->$log,$libraryid->#filtered->$filtered,$libraryid->#artifact->$artifact' \
https://github.com/moirai2/moirai2.github.io/command/tagdust/tagdust_single.json \
'$log=data/filtered/$libraryid.log' \
'$filtered=data/filtered/$libraryid.filtered.fq.gz' \
'$artifact=data/filtered/$libraryid.artifact.fq.gz'

echo "#6 Align to Male Genome"
perl moirai2.pl \
-d singlecell.sqlite3 \
-i '$libraryid->#filtered->$input,$libraryid->#revisedsex->male,$libraryid->#ScientificName->$species,$species->#male_genome->$assembly' \
-o '$libraryid->#bam->$bam,$libraryid->#bamlog->$log' \
https://github.com/moirai2/moirai2.github.io/command/STAR/align_single.json \
'$bam=data/bam/$libraryid.$runid.bam' \
'$log=data/bam/$libraryid.$runid.log'

echo "#7 Align to Feale Genome"
perl moirai2.pl \
-d singlecell.sqlite3 \
-i '$libraryid->#filtered->$input,$libraryid->#revisedsex->female,$libraryid->#ScientificName->$species,$species->#female_genome->$assembly' \
-o '$libraryid->#bam->$bam,$libraryid->#bamlog->$log' \
https://github.com/moirai2/moirai2.github.io/command/STAR/align_single.json \
'$bam=data/bam/$libraryid.$runid.bam' \
'$log=data/bam/$libraryid.$runid.log'
