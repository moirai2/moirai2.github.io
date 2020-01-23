# http://dgt-gitlab.gsc.riken.jp/gitlab/melissa/BCA_regions
# git clone git@dgt-gitlab.gsc.riken.jp:melissa/BCA_regions.git

#################### submit ####################

if [ "$1" == "submit" ] ; then
perl rdf.pl -d breastcancer.sqlite3 input breastcancer '#geneid'
exit
fi

#################### initialize ####################

perl rdf.pl -d breastcancer.sqlite3 prompt "breastcancer" '#krakenDB' "Path to Kraken database [default=download]: "
perl rdf.pl -d breastcancer.sqlite3 install "kraken"
perl rdf.pl -d breastcancer.sqlite3 rmexec

#################### Kraken database ####################

perl moirai2.pl -q -m 10 \
-d breastcancer.sqlite3 \
-i 'breastcancer->#krakensize->4GB' \
-o 'breastcancer->#krakenDB->$path' \
https://moirai2.github.io/database/kraken/minikraken_4GB.json

perl moirai2.pl -q -m 10 \
-d breastcancer.sqlite3 \
-i 'breastcancer->#krakensize->8GB' \
-o 'breastcancer->#krakenDB->$path' \
https://moirai2.github.io/database/kraken/minikraken_8GB.json

#################### gene ####################
