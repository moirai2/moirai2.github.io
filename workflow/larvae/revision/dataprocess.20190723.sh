if [ $# -gt 0 ] ; then
nodeid=`perl rdf.pl -d larvae.sqlite3 newnode`
perl rdf.pl -d larvae.sqlite3 insert $nodeid '#read1' $1
perl rdf.pl -d larvae.sqlite3 insert $nodeid '#read2' $2
perl rdf.pl -d larvae.sqlite3 insert root '#starindex' $3
perl rdf.pl -d larvae.sqlite3 insert root '#star' STAR
perl rdf.pl -d larvae.sqlite3 insert root '#samtools' samtools
fi

perl moirai2.pl \
-d larvae.sqlite3 \
-i 'root->#star->$starbin,root->#starindex->$starindex,root->#samtools->$samtoolsbin,$id->#read1->$input1,$id->#read2->$input2' \
-o '$id->#bam->$bam,$id->#log->$log' \
https://moirai2.github.io/command/star/align_paired.json

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
-i '$id->#bam->$bam' \
-o '$id->#html->$html' \
https://moirai2.github.io/command/sam/samstats.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#bam->$input' \
-o '$id->#multicount->$multicount' \
https://moirai2.github.io/command/star/remove_multimap_paired.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#bam->$input' \
-o '$id->#sorted->$output' \
https://moirai2.github.io/command/samtools/sortbam.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#sorted->$input' \
-o '$id->#bed->$output' \
https://moirai2.github.io/command/bedtools/bam2bed.json
