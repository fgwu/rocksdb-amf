#!/bin/bash


if [ $# -ne 3 ]; then
    echo usage: $0 num bdevname mountpoint
    exit -1
fi
if [ ! -d $3 ]; then
    echo mkdir -p $3
    mkdir -p $3
fi


if ! mountpoint -q $3; then
    echo sudo mkfs.xfs -f $2
    sudo mkfs.xfs -f $2

    echo sudo mount -t xfs $2 $3
    sudo mount -t xfs $2 $3
fi

echo "sudo db_bench --db=$3 --num=$(($1*1024)) --value_size=1008 --benchmarks=fillrandom,stats,seekrandom,stats | tee db.log"

sudo db_bench --db=$3 --num=$(($1*1024)) --value_size=1008 --benchmarks=fillrandom,stats,seekrandom,stats | tee db.log

echo sudo umount $3
sudo umount $3
