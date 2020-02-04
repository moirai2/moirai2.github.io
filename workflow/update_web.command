#!/bin/sh
#root=`dirname $0`
root="/Users/ah3q/Sites"
datetime=`date +%Y%m%d.%H%M%S`
cd $root
perl github/commandindex.pl moirai2.github.io/command Command json > moirai2.github.io/command/index.html
perl github/commandindex.pl moirai2.github.io/software Software json > moirai2.github.io/software/index.html
perl github/commandindex.pl moirai2.github.io/database Database json > moirai2.github.io/database/index.html
perl github/commandindex.pl moirai2.github.io/workflow Workflow sh > moirai2.github.io/workflow/index.html
cd ${root}/moirai2.github.io
rm .DS_Store */.DS_Store */*/.DS_Store */*/*/.DS_Store */*/*/*/.DS_Store
git add --all
git commit -m "update on $datetime"
git push -u origin master
