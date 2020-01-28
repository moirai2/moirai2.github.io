#!/bin/sh
# DRA001287 => DRP001358
# GSE90487 => SRP093881

mkdir -p runinfo
mkdir -p rDNA
mkdir -p genome
mkdir -p fastq
mkdir -p STAR

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
  perl rdf.pl -d singlecell.sqlite3 insert 'Homo sapiens' '#assembly' 'hg38'
  perl rdf.pl -d singlecell.sqlite3 insert 'Mus musculus' '#assembly' 'mm10'

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

  perl moirai2.pl -m 1 \
  -d singlecell.sqlite3 \
  -i '$singlecell->#species->Homo sapiens' \
  -o 'Homo sapiens->#genome->$path' \
  https://moirai2.github.io/database/genome/Homo_sapiens_hg38_chr22.json \
  '$path=genome/hg38.fa'

  perl moirai2.pl -m 1 \
  -d singlecell.sqlite3 \
  -i '$singlecell->#species->Mus musculus' \
  -o 'Mus musculus->#genome->$path' \
  https://moirai2.github.io/database/genome/Mus_musculus_mm10_chr19.json \
  '$path=genome/mm10.fa'

  perl moirai2.pl -m 1 \
  -d singlecell.sqlite3 \
  -i '$species->#assembly->$assembly,$assembly->#genome->$reference' \
  https://moirai2.github.io/command/STAR/index_reference.json \
  '$outdir=STAR/$assembly' \
  '$stdout=STAR/$assembly/index.stdout' \
  '$stderr=STAR/$assembly/index.stderr' \
  '$log=STAR/$assembly/index.log'
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

echo "#4 Downloading fastq files"
perl moirai2.pl \
-d singlecell.sqlite3 \
-i '$studyid->#Run->$runid,$runid->#LibraryLayout->PAIRED' \
-o '$runid->#read1->$read1,$runid->#read2->$read2,$runid->#count1->$count1,$runid->#count2->$count2' \
/Users/ah3q/Sites/moirai2.github.io/command/eutils/fastq_dump_paired.json \
'$read1=fastq/$studyid.$runid.read1.fq.gz' \
'$read2=fastq/$studyid.$runid.read2.fq.gz'

perl moirai2.pl \
-d singlecell.sqlite3 \
-i '$studyid->#Run->$runid,$runid->#LibraryLayout->SINGLE' \
-o '$runid->#read1->$read1,$runid->#count1->$count1' \
/Users/ah3q/Sites/moirai2.github.io/command/eutils/fastq_dump_single.json \
'$read1=fastq/$studyid.$runid.read1.fq.gz'
