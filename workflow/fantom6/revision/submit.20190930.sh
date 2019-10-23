mkdir -p rDNA
mkdir -p genome

perl rdf.pl -d fantom6.sqlite3 newprompt fantom6 '#library' "New library [default is none] ? "
perl moirai2.pl -d fantom6.sqlite3 -i 'fantom6->#library->$library' -o '$library->#species->$_' prompt 'Input species of library "$library" [default=human] ? ' human
perl moirai2.pl -d fantom6.sqlite3 -i 'fantom6->#library->$library' -o '$library->#barcode->$_' prompt 'Input barcode(s) of library "$library" with delim ","" [default=none] ? '
