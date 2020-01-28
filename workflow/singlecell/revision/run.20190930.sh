#!/bin/sh
# singlecell->#species->$species
#                    $species->#rDNA->$rDNA
#                    $species->#genome->$genome
#
# singlecell->#userlibid->$userlibid
#                      $userlibid->#studyid->$studyid
#
# singlecell->#studyid->$studyid
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

mkdir -p runinfo
mkdir -p rDNA
mkdir -p genome

perl rdf.pl -d fantom4.sqlite3 -q rmexec
if [ "$1" == "submit" ] ; then
  perl rdf.pl -d singlecell.sqlite3 input singlecell '#userid'
  exit
elif [ "$1" == "setup" ] ; then
  perl rdf.pl -d singlecell.sqlite3 prompt 'Homo sapiens' '#rDNA' "Path to Homo sapiens rDNA [default is download] ? "
  perl rdf.pl -d singlecell.sqlite3 prompt 'Homo sapiens' '#genome' "Path to Homo sapiens genome [default is download] ? "
  perl rdf.pl -d singlecell.sqlite3 prompt 'Mus musculus' '#rDNA' "Path to Mus musculus rDNA [default is download] ? "
  perl rdf.pl -d singlecell.sqlite3 prompt 'Mus musculus' '#genome' "Path to Mus musculus genome [default is download] ? "
  perl rdf.pl -d singlecell.sqlite3 insert singlecell '#species' 'Homo sapiens'
  perl rdf.pl -d singlecell.sqlite3 insert singlecell '#species' 'Mus musculus'

  echo "#0 Installing softwares"
  perl rdf.pl -d singlecell.sqlite3 install splitByBarcode tagdust STAR samtools bedtools
  echo "#1 Downloading genomes"

  perl moirai2.pl -m 10 \
  -d singlecell.sqlite3 \
  -i '$singlecell->#species->Homo sapiens' \
  -o 'Homo sapiens->#rDNA->$output' \
  https://moirai2.github.io/database/ncbi/rDNA/Homo_sapiens_rDNA.json \
  '$output=rDNA/human_rDNA.fa'

  perl moirai2.pl -m 10 \
  -d singlecell.sqlite3 \
  -i '$singlecell->#species->Mus musculus' \
  -o 'Mus musculus->#rDNA->$output' \
  https://moirai2.github.io/database/ncbi/rDNA/Mus_musculus_rDNA.json \
  '$output=rDNA/mouse_rDNA.fa'

  perl moirai2.pl -m 10 \
  -d singlecell.sqlite3 \
  -i '$singlecell->#species->Homo sapiens' \
  -o 'Homo sapiens->#genome->$output' \
  https://moirai2.github.io/database/genome/Homo_sapiens_hg38_chronly.json \
  '$path=genome/hg38_chronly.fa'

  perl moirai2.pl -m 10 \
  -d singlecell.sqlite3 \
  -i '$singlecell->#species->Mus musculus' \
  -o 'Mus musculus->#genome->$output' \
  https://moirai2.github.io/database/genome/Mus_musculus_mm10_chronly.json \
  '$path=genome/mm10_chronly.fa'
  exit
fi

echo "#1 converting userdefinedid to studyid"
perl moirai2.pl \
-d singlecell.sqlite3 \
-i 'singlecell->#userid->$userdefinedid' \
-o '$userdefinedid->#studyid->$studyid,singlecell->#studyid->$studyid' \
/Users/ah3q/Sites/moirai2.github.io/command/eutils/userdefinedid_to_studyid.json

echo "#2 Retrieving runinfo and summary files"
perl moirai2.pl \
-d singlecell.sqlite3 \
-i 'singlecell->#studyid->$studyid' \
-o '$studyid->#runinfo->$runinfo,$studyid->#summaryfile->$summary' \
/Users/ah3q/Sites/moirai2.github.io/command/eutils/studyid_to_sra_info_files.json \
'$runinfo=runinfo/$studyid.runinfo.txt' \
'$summary=runinfo/$studyid.summary.txt'

echo "#3 Importing species and runinfo to database"
perl moirai2.pl \
-d singlecell.sqlite3 \
-i '$studyid->#runinfo->$runinfo' \
-o '$studyid->#runinfo_imported->true' \
/Users/ah3q/Sites/moirai2.github.io/command/eutils/import_runinfo_to_database.json \
'$label=ScientificName,LibraryLayout'

echo "#3 Downloading fastq files"
perl moirai2.pl \
-d singlecell.sqlite3 \
-i '$runid->#LibraryLayout->PAIRED' \
-o '$runid->#read1->$read1,$runid->#read2->$read2,$runid->#count2->$count1,$runid->#count2->$count2' \
/Users/ah3q/Sites/moirai2.github.io/command/eutils/fastq-dump_paired.json \
