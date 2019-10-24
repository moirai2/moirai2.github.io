# pathogen
# Madurella mycetomatis (ascomycetes)
# https://www.ncbi.nlm.nih.gov/assembly/GCA_001275765.2/
# ASM127576v2 GCA_001275765.2

# host
# Galleria mellonella (greater wax moth)
# https://www.ncbi.nlm.nih.gov/assembly/GCF_003640425.1/
# ASM364042v1 GCF_003640425.1

if [ "$1" == "submit" ] ; then
runid=$2;
read1=$3;
read2=$3;
perl rdf.pl -d larvae.sqlite3 insert larvae '#run' $runid
perl rdf.pl -d larvae.sqlite3 insert $runid '#read1' $read1
perl rdf.pl -d larvae.sqlite3 insert $runid '#read2' $read2
exit
fi

mkdir -p download
mkdir -p STAR
mkdir -p host
mkdir -p pathogen
perl rdf.pl -d larvae.sqlite3 install STAR samtools bedtools
perl rdf.pl -d larvae.sqlite3 insert larvae '#species' 'Galleria_mellonella'
perl rdf.pl -d larvae.sqlite3 insert larvae '#species' 'Madurella_mycetomatis'
perl rdf.pl -d larvae.sqlite3 insert larvae '#host' 'Galleria_mellonella'
perl rdf.pl -d larvae.sqlite3 insert larvae '#pathogen' 'Madurella_mycetomatis'
perl rdf.pl -d larvae.sqlite3 rmexec

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i 'larvae->#species->Galleria_mellonella' \
-o 'Galleria_mellonella->#genome->$path' \
https://moirai2.github.io/database/genome/Galleria_mellonella.json \
'$output=download/Galleria_mellonella.fa'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i 'larvae->#species->Madurella_mycetomatis' \
-o 'Madurella_mycetomatis->#genome->$path' \
https://moirai2.github.io/database/genome/Madurella_mycetomatis.json \
'$output=download/Madurella_mycetomatis.fa'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i 'larvae->#species->Galleria_mellonella' \
-o 'Galleria_mellonella->#gff->$path' \
https://moirai2.github.io/database/gff/Galleria_mellonella.json \
'$output=download/Galleria_mellonella.gff'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i 'larvae->#species->Madurella_mycetomatis' \
-o 'Madurella_mycetomatis->#gff->$path' \
https://moirai2.github.io/database/gff/Madurella_mycetomatis.json \
'$output=download/Madurella_mycetomatis.gff'

perl moirai2.pl -m 10 \
-d fantom4.sqlite3 \
-i '$species->#genome->$reference' \
-o '$species->#starindex->$outdir' \
https://moirai2.github.io/command/STAR/index_reference.json \
'$outdir=STAR/$species/' \
'$stdout=STAR/$species.stdout.txt' \
'$stderr=STAR/$species.stderr.txt' \
'$log=STAR/$species/log.txt'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#read1->$fastq' \
-o '$fastq->#seqcount->$count' \
https://moirai2.github.io/command/fastq/countseq.json

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#read2->$fastq' \
-o '$fastq->#seqcount->$count' \
https://moirai2.github.io/command/fastq/countseq.json

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#read1->$input1,$id->#read2->$input2,larvae->#host->$species,$species->#starindex->$starindex' \
-o '$id->#hostbam->$bam,$id->#hostlog->$log,$id->#hostgenecounts->$genecounts' \
https://moirai2.github.io/command/STAR/align_paired_genecounts.json \
'$bam=host/$id.bam' \
'$log=host/$id.log' \
'$genecounts=host/$id.genecounts.txt'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#read1->$input1,$id->#read2->$input2,larvae->#pathogen->$species,$species->#starindex->$starindex' \
-o '$id->#pathogenbam->$bam,$id->#pathogenlog->$log,$id->#pathogengenecounts->$genecounts' \
https://moirai2.github.io/command/STAR/align_paired_genecounts.json \
'$bam=pathogen/$id.bam' \
'$log=pathogen/$id.log' \
'$genecounts=pathogen/$id.genecounts.txt'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#hostbam->$bam' \
-o '$id->#hosthtml->$html' \
https://moirai2.github.io/command/sam/samstats.json \
'$html=host/$id.html'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#pathogenbam->$bam' \
-o '$id->#pathogenhtml->$html' \
https://moirai2.github.io/command/sam/samstats.json \
'$html=pathogen/$id.html'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#hostbam->$input' \
-o '$id->#hostmulticount->$multicount,$id->#hostunmap1->$unmap1,$id->#hostunmap2->$unmap2' \
https://moirai2.github.io/command/STAR/remove_multimap_paired.json \
'$unmap1=host/$id.unmap1.fq.gz' \
'$unmap2=host/$id.unmap2.fq.gz'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#pathogenbam->$input' \
-o '$id->#pathogenmulticount->$multicount,$id->#pathogenunmap1->$unmap1,$id->#pathogenunmap2->$unmap2' \
https://moirai2.github.io/command/STAR/remove_multimap_paired.json \
'$unmap1=pathogen/$id.unmap1.fq.gz' \
'$unmap2=pathogen/$id.unmap2.fq.gz'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#hostbam->$input' \
-o '$id->#hostsorted->$output' \
https://moirai2.github.io/command/samtools/sortmappedbam.json \
'$output=host/$id.sorted.bam'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#pathogenbam->$input' \
-o '$id->#pathogensorted->$output' \
https://moirai2.github.io/command/samtools/sortmappedbam.json \
'$output=pathogen/$id.sorted.bam'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#hostsorted->$input' \
-o '$id->#hostbed->$output' \
https://moirai2.github.io/command/bedtools/bam2gbedgzip.json \
'$output=host/$id.bed'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#pathogensorted->$input' \
-o '$id->#pathogenbed->$output' \
https://moirai2.github.io/command/bedtools/bam2bedgzip.json \
'$output=pathogen/$id.bed'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#hostsorted->$bam1,$id->#pathogensorted->$bam2' \
-o '$id->#both_mapped->$mapped_mapped,$id->#host_only->$mapped_unmapped,$id->#pathogen_only->$unmapped_mapped,$id->#both_unmapped->$unmapped_unmapped' \
https://moirai2.github.io/command/bam/compare_bams.json
