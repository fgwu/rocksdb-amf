#!/bin/bash
BDEV=nvme0n1
DEV=/dev/$BDEV
MOUNTPOINT=/home/fwu/levelmount

if [ \( $# -ne 1 \) -a \( $# -ne 2 \) ]
then
    echo usage: $0 db_size_in_M db_amplification_factor
fi

rm -rf *
echo "sudo blktrace $DEV  & PID=$!; sleep 1 ; ../bench.sh $1 $DEV $MOUNTPOINT$2; echo kill $PID; sudo kill $PID"

sudo blktrace $DEV  & PID=$!; sleep 1 ; ../bench.sh $1 $DEV $MOUNTPOINT $2; echo kill $PID; sudo kill $PID

sleep 1
blkparse $BDEV > events.log
sleep 1
 ../extract_write_amount.sh events.log db.log | tee result.log

# p99.log format:
# db_size_in_M AF benchmark p90 p99 p999
paste <(cat db.log|grep p99 | awk '{print $1, $4, $6, $8 }' | sed -e "s/^/$1 $2 /") <(cat db.log|grep micros | awk '{print $3}') | tee p99.log 
