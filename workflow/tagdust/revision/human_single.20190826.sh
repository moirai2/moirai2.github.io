perl rdf.pl -d tagdust.sqlite3 -q prompt tagdust '#reference' 'Path to human ribosomal RNA fasta [default=download] ? '
perl rdf.pl -d tagdust.sqlite3 -q install tagdust
perl rdf.pl -d tagdust.sqlite3 -q input tagdust '#input' $@
perl rdf.pl -d tagdust.sqlite3 -q rmexec

perl moirai2.pl \
-d tagdust.sqlite3 \
-o 'tagdust->#reference->$output' \
https://moirai2.github.io/database/ncbi/download_human_ribosomal_DNA.json

perl moirai2.pl \
-d tagdust.sqlite3 \
-i 'tagdust->#reference->$reference' \
-o 'tagdust->#input->$input' \
https://moirai2.github.io/command/tagdust/tagdust_single.json
