#!/bin/bash

echo processing db.log
for bench in `grep micros db.log | cut -f1 -d" "`; do
    echo benchmark: $bench
    P90=`grep -A 10 $bench db.log | grep -o "P90: [0-9.]*" | cut -d: -f2`
    P99=`grep -A 10 $bench db.log | grep -o "P99: [0-9.]*" | cut -d: -f2`
    P999=`grep -A 10 $bench db.log | grep -o "P99.9: [0-9.]*" | cut -d: -f2`
    Avg=`grep micros db.log | awk '{print $3}'`
    echo $bench $P90 $P99 $P999 $Avg
done
