#!/bin/bash


if [ $# -ne 1 ]; then
    echo usage: $0 [num]
    num=100
else
    num=$1
fi

rm -rf *
sudo blktrace /dev/nvme0n1  & PID=$!; sleep 1 ; ../bench.sh $num; echo kill $PID; sudo kill $PID
sleep 1
blkparse nvme0n1 > events.log
sleep 1
 ../extract_write_amount.sh events.log db.log
