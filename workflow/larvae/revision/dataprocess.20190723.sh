if [ $# -gt 0 ] ; then
runid=$1;
perl rdf.pl -d larvae.sqlite3 insert larvae '#run' $runid
perl rdf.pl -d larvae.sqlite3 insert $runid '#read1' $2
perl rdf.pl -d larvae.sqlite3 insert $runid '#read2' $3
perl rdf.pl -d larvae.sqlite3 insert larvae '#host' chrY
perl rdf.pl -d larvae.sqlite3 insert larvae '#pathogen' chrY
#perl rdf.pl -d larvae.sqlite3 install STAR samtools bedtools
fi

mkdir -p host
mkdir -p pathogen
perl rdf.pl -d larvae.sqlite3 rmexec

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
-i '$id->#read1->$input1,$id->#read2->$input2,larvae->#host->$starindex' \
-o '$id->#hostbam->$bam,$id->#hostlog->$log,$id->#hostgenecounts->$genecounts' \
https://moirai2.github.io/command/STAR/align_paired_genecounts.json '$bam=host/$id.bam' '$log=host/$id.log' '$genecounts=host/$id.genecounts.txt'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#read1->$input1,$id->#read2->$input2,larvae->#pathogen->$starindex' \
-o '$id->#pathogenbam->$bam,$id->#pathogenlog->$log,$id->#pathogengenecounts->$genecounts' \
https://moirai2.github.io/command/STAR/align_paired_genecounts.json '$bam=pathogen/$id.bam' '$log=pathogen/$id.log' '$genecounts=pathogen/$id.genecounts.txt'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#hostbam->$bam' \
-o '$id->#hosthtml->$html' \
https://moirai2.github.io/command/sam/samstats.json '$html=host/$id.html'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#pathogenbam->$bam' \
-o '$id->#pathogenhtml->$html' \
https://moirai2.github.io/command/sam/samstats.json '$html=pathogen/$id.html'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#hostbam->$input' \
-o '$id->#hostmulticount->$multicount,$id->#hostunmap1->$unmap1,$id->#hostunmap2->$unmap2' \
https://moirai2.github.io/command/STAR/remove_multimap_paired.json '$unmap1=host/$id.unmap1.fq.gz' '$unmap2=host/$id.unmap2.fq.gz'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#pathogenbam->$input' \
-o '$id->#pathogenmulticount->$multicount,$id->#pathogenunmap1->$unmap1,$id->#pathogenunmap2->$unmap2' \
https://moirai2.github.io/command/STAR/remove_multimap_paired.json '$unmap1=pathogen/$id.unmap1.fq.gz' '$unmap2=pathogen/$id.unmap2.fq.gz'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#hostbam->$input' \
-o '$id->#hostsorted->$output' \
https://moirai2.github.io/command/samtools/sortmappedbam.json '$output=host/$id.sorted.bam'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#hostbam->$file,$id->#hostsorted->$kept' \
https://moirai2.github.io/command/unix/rm.json

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#pathogenbam->$input' \
-o '$id->#pathogensorted->$output' \
https://moirai2.github.io/command/samtools/sortmappedbam.json '$output=pathogen/$id.sorted.bam'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#pathogenbam->$file,$id->#pathogensorted->$kept' \
https://moirai2.github.io/command/unix/rm.json

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#hostsorted->$input' \
-o '$id->#hostbed->$output' \
https://moirai2.github.io/command/bedtools/bam2gbedgzip.json '$output=host/$id.bed'

perl moirai2.pl -q -m 10 \
-d larvae.sqlite3 \
-i '$id->#pathogensorted->$input' \
-o '$id->#pathogenbed->$output' \
https://moirai2.github.io/command/bedtools/bam2gbedgzip.json '$output=pathogen/$id.bed'
