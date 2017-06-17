#!/bin/bash
BDEV=loop0
DEV=/dev/$BDEV
MOUNTPOINT=/home/fwu/levelmount

if [ $# -ne 1 ]; then
    echo usage: $0 [num]
    num=100
else
    num=$1
fi

rm -rf *
echo "sudo blktrace $DEV  & PID=$!; sleep 1 ; ../bench.sh $num $DEV $MOUNTPOINT; echo kill $PID; sudo kill $PID"

sudo blktrace $DEV  & PID=$!; sleep 1 ; ../bench.sh $num $DEV $MOUNTPOINT; echo kill $PID; sudo kill $PID

sleep 1
blkparse $BDEV > events.log
sleep 1
 ../extract_write_amount.sh events.log db.log | tee result.log
