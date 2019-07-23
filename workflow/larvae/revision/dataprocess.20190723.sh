if [ $# -gt 0 ] ; then
nodeid=`perl rdf.pl -d larvae.sqlite3 newnode`
perl rdf.pl -d larvae.sqlite3 insert $nodeid '#read1' $1
perl rdf.pl -d larvae.sqlite3 insert $nodeid '#read2' $2
perl rdf.pl -d larvae.sqlite3 insert root '#star' STAR
perl rdf.pl -d larvae.sqlite3 insert root '#samtools' samtools
perl rdf.pl -d larvae.sqlite3 insert root '#starindex' /Users/ah3q/Sites/javascript/201903/TruSeq
fi

perl moirai2.pl \
-d larvae.sqlite3 \
-i 'root->#star->$starbin,root->#starindex->$starindex,root->#samtools->$samtoolsbin,$id->#read1->$input1,$id->#read2->$input2' \
-o '$id->#bam->$bam,$id->#log->$log' \
/Users/ah3q/Sites/moirai2.github.io/command/star/revision/align_paired.20190723.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#read1->$fastq' \
-o '$fastq->#seqcount->$count' \
/Users/ah3q/Sites/moirai2.github.io/command/fastq/revision/countseq.20190403.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#read2->$fastq' \
-o '$fastq->#seqcount->$count' \
/Users/ah3q/Sites/moirai2.github.io/command/fastq/revision/countseq.20190403.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#bam->$bam' \
-o '$id->#html->$html' \
/Users/ah3q/Sites/moirai2.github.io/command/sam/revision/samstats.20190723.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#bam->$input' \
-o '$id->#multicount->$multicount' \
/Users/ah3q/Sites/moirai2.github.io/command/star/revision/remove_multimap_paired.20190723.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#bam->$input' \
-o '$id->#sorted->$output' \
/Users/ah3q/Sites/moirai2.github.io/command/samtools/revision/sortbam.20190403.json

perl moirai2.pl \
-d larvae.sqlite3 \
-i '$id->#sorted->$input' \
-o '$id->#bed->$output' \
/Users/ah3q/Sites/moirai2.github.io/command/bedtools/revision/bam2bed.20190403.json
