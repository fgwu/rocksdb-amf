#!/bin/bash

for f in `ls */db.log`; do
    echo $f
    dir=`dirname $f`
    rm -f $dir/p99.log
    echo "processing $dir/db.log =>  $dir/p99.log"
    for bench in `grep micros $dir/db.log | cut -f1 -d" "`; do
	#    echo benchmark: $bench
	P50=`grep -A 10 $bench $dir/db.log | grep -o "P50: [0-9.]*" | cut \
\
-d: -f2`
	P99=`grep -A 10 $bench $dir/db.log | grep -o "P99: [0-9.]*" | cut \
\
-d: -f2`
	P999=`grep -A 10 $bench $dir/db.log | grep -o "P99.9: [0-9.]*" | c\
\
ut -d: -f2`
	Avg=`grep -A 10 $bench $dir/db.log | grep micros | awk '{print $3}\
'`
	af=`basename $dir | grep -o -E "r[0-9]+" | grep -o -E "[0-9]+"`
	size=`basename $dir | grep -o -E "s[0-9]+" | grep -o -E "[0-9]+"`
	echo $size $af $bench $P50 $P99 $P999 $Avg | tee -a $dir/p99.log
    done

done
