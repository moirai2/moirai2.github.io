mkdir -p rDNA
mkdir -p genome

perl rdf.pl -d fantom6.sqlite3 prompt fantom6 '#library' "New library [default is none] ? "
perl rdf.pl -d fantom6.sqlite3 prompt -i 'fantom6->#library->$library' -o '$library->#species->$_' "Input species of library '$library' [default=human] ? " human
perl rdf.pl -d fantom6.sqlite3 prompt -i 'fantom6->#library->$library' -o '$library->#barcode->$_' "Input barcode(s) of library '$library' with delim ',' [default=none] ? "
