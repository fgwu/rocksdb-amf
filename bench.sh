#!/bin/bash

if [ $# -ne 1 ]; then
    echo usage: $0 num
    exit -1
fi

sudo db_bench --db=/home/fwu/levelmount --num=$(($1*1024)) --value_size=1008 --benchmarks=fillrandom,stats | tee db.log
