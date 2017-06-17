#!/bin/bash


if [ $# -ne 3 ]; then
    echo usage: $0 num bdevname mountpoint
    exit -1
fi
if [ ! -d $3 ]; then
    echo mkdir -p $3
    mkdir -p $3
fi

echo sudo mkfs.xfs $2
sudo mkfs.xfs $2

if ! mountpoint -q $3; then
    echo sudo mount -t xfs $2 $3
    sudo mount -t xfs $2 $3
fi

sudo db_bench --db=$MOUNTPOINT --num=$(($1*1024)) --value_size=1008 --benchmarks=fillrandom,stats,seekrandom,stats | tee db.log
