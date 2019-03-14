#!/bin/sh
root=`dirname $0`
cd ${root}
datetime=`date +%Y%m%d.%H%M%S`
git add --all
git commit -m "update on $datetime"
git push -u origin master
