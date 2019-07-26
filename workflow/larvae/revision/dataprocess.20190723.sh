if [ $# -gt 0 ] ; then
nodeid=`perl rdf.pl -d larvae.sqlite3 newnode`
perl rdf.pl -d larvae.sqlite3 insert larvae '#run' $nodeid
perl rdf.pl -d larvae.sqlite3 insert $nodeid '#read1' $1
perl rdf.pl -d larvae.sqlite3 insert $nodeid '#read2' $2
perl rdf.pl -d larvae.sqlite3 insert larvae '#host' $3
perl rdf.pl -d larvae.sqlite3 insert larvae '#pathogen' $4
#perl rdf.pl -d larvae.sqlite3 install STAR samtools bedtools
fi

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#read1->$input1,$id->#read2->$input2,larvae->#host->$starindex' \
-o '$id->#hostbam->$bam,$id->#hostlog->$log' \
https://moirai2.github.io/command/STAR/align_paired.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#read1->$input1,$id->#read2->$input2,larvae->#pathogen->$starindex' \
-o '$id->#pathogenbam->$bam,$id->#pathogenlog->$log' \
https://moirai2.github.io/command/STAR/align_paired.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#read1->$fastq' \
-o '$fastq->#seqcount->$count' \
https://moirai2.github.io/command/fastq/countseq.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#read2->$fastq' \
-o '$fastq->#seqcount->$count' \
https://moirai2.github.io/command/fastq/countseq.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#hostbam->$bam' \
-o '$id->#html->$html' \
https://moirai2.github.io/command/sam/samstats.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#hostbam->$input' \
-o '$id->#hostmulticount->$multicount,$id->#hostunmap1->$unmap1,$id->#hostunmap2->$unmap2' \
https://moirai2.github.io/command/STAR/remove_multimap_paired.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#hostbam->$input' \
-o '$id->#hostsorted->$output' \
https://moirai2.github.io/command/samtools/sortbam.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#hostsorted->$input' \
-o '$id->#hostbed->$output' \
https://moirai2.github.io/command/bedtools/bam2bed.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#pathogenbam->$bam' \
-o '$id->#html->$html' \
https://moirai2.github.io/command/sam/samstats.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#pathogenbam->$input' \
-o '$id->#pathogenmulticount->$multicount,$id->#pathogenunmap1->$unmap1,$id->#pathogenunmap2->$unmap2' \
https://moirai2.github.io/command/STAR/remove_multimap_paired.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#pathogenbam->$input' \
-o '$id->#pathogensorted->$output' \
https://moirai2.github.io/command/samtools/sortbam.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#pathogensorted->$input' \
-o '$id->#pathogenbed->$output' \
https://moirai2.github.io/command/bedtools/bam2bed.json
