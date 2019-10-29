#!/bin/sh
# fantom6->#species->$species
#                    $species->#rDNA->$rDNA
#                    $species->#genome->$genome
#
# fantom6->#userlibid->$userlibid
#                      $userlibid->#studyid->$studyid
#
# fantom6->#studyid->$studyid
#                    $studyid->#species->$species
#                    $studyid->#barcode->$barcode
#                    $studyid->#runinfo->$runinfo
#                    $studyid->#summaryfile->$summaryfile
#                    $studyid->#runinfo_imported->true
#                    $studyid->#Run->$runid
#
# $runid->#ScientificName->$species
# $runid->#raw1->$raw1
# $runid->#raw2->$raw2
#
# DRA001287 => DRP001358
# GSE90487 => SRP093881

if [ "$1" == "submit" ] ; then
perl rdf.pl -d fantom6.sqlite3 input fantom6 '#userid'
exit;
fi

perl moirai2.pl \
-d fantom6.sqlite3 \
-i 'fantom6->#userid->$userdefinedid' \
-o '$userdefinedid->#studyid->$studyid,fantom6->#studyid->$studyid' \
/Users/ah3q/Sites/moirai2.github.io/command/eutils/userdefinedid_to_studyid.json

mkdir -p runinfo

perl moirai2.pl \
-d fantom6.sqlite3 \
-i 'fantom6->#studyid->$studyid' \
-o '$studyid->#runinfo->$runinfo,$studyid->#summaryfile->$summary' \
/Users/ah3q/Sites/moirai2.github.io/command/eutils/studyid_to_sra_info_files.json \
'$runinfo=runinfo/$studyid.runinfo.txt' \
'$summary=runinfo/$studyid.summary.txt'

perl moirai2.pl \
-d fantom6.sqlite3 \
-i '$studyid->#runinfo->$runinfo' \
-o '$studyid->#runinfo_imported->true' \
/Users/ah3q/Sites/moirai2.github.io/command/eutils/import_runinfo_to_database.json \
'$label=ScientificName'

exit;

mkdir -p rDNA
mkdir -p genome
perl rdf.pl -d fantom6.sqlite3 prompt fantom6 '#species' "Species [default is human] ? " human
species=`perl rdf.pl -d fantom6.sqlite3 object fantom6 '#species'`
perl rdf.pl -d fantom6.sqlite3 prompt $species '#rDNA' "Path to $species rDNA [default is download] ? "
perl rdf.pl -d fantom6.sqlite3 prompt $species '#genome' "Path to $species genome [default is download] ? "
perl rdf.pl -d fantom6.sqlite3 install splitByBarcode tagdust STAR samtools bedtools

perl moirai2.pl -m 10 \
-d fantom6.sqlite3 \
-i 'fantom6->#species->human' \
-o 'human->#rDNA->$output' \
https://moirai2.github.io/database/ncbi/download_human_ribosomal_DNA.json \
'$output=rDNA/human_rDNA.fa'

perl moirai2.pl -m 10 \
-d fantom6.sqlite3 \
-i 'fantom6->#species->mouse' \
-o 'mouse->#rDNA->$output' \
https://moirai2.github.io/database/ncbi/download_mouse_ribosomal_DNA.json \
'$output=rDNA/mouse_rDNA.fa'

perl moirai2.pl -m 10 \
-d fantom6.sqlite3 \
-i 'fantom6->#species->human' \
-o 'human->#genome->$output' \
https://moirai2.github.io/database/genome/Homo_sapiens_hg38_chronly.json \
'$output=genome/hg38_chronly.fa'

perl moirai2.pl -m 10 \
-d fantom6.sqlite3 \
-i 'fantom6->#species->mouse' \
-o 'mouse->#genome->$output' \
https://moirai2.github.io/database/genome/Mus_musculus_mm10_chronly.json \
'$output=genome/mm10_chronly.fa'
