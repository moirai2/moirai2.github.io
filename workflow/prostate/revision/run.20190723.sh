# command line
# clone repository
# git clone git@dgt-gitlab.gsc.riken.jp:melissa/Prostate.git
#directories:
# candidate_probes
# fof
# heatmaps
# kraken_results
# pcr_probes
# Reports
# scripts

#################### submit ####################

if [ "$1" == "submit" ] ; then
perl rdf.pl -d prostate.sqlite3 input prostate '#geneid'
exit
fi

#################### initialize ####################

perl rdf.pl -q -d prostate.sqlite3 prompt "prostate" '#krakensize' "Kraken DB size (4GB or 8GB) [default=8GB]: " "8GB"
perl rdf.pl -d prostate.sqlite3 prompt "prostate" '#krakenDB' "Path to Kraken database [default=download]: "
perl rdf.pl -d prostate.sqlite3 install "kraken"
perl rdf.pl -d prostate.sqlite3 rmexec

#################### Kraken database ####################

perl moirai2.pl -q -m 10 \
-d prostate.sqlite3 \
-i 'prostate->#krakensize->8GB' \
-o 'prostate->#krakenDB->$path' \
https://moirai2.github.io/database/kraken/minikraken_8GB.json

perl moirai2.pl -q -m 10 \
-d prostate.sqlite3 \
-i 'prostate->#krakensize->4GB' \
-o 'prostate->#krakenDB->$path' \
https://moirai2.github.io/database/kraken/minikraken_4GB.json

#################### gene ####################
