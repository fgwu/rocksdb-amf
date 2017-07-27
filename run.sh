#!/bin/bash
BDEV=nvme0n1
DEV=/dev/$BDEV
MOUNTPOINT=/home/fwu/levelmount

if [ \( $# -ne 1 \) -a \( $# -ne 2 \) ]
then
    echo usage: $0 db_size_in_M db_amplification_factor
fi

rm -rf *


if [ ! -d $MOUNTPOINT ]; then
    echo mkdir -p $MOUNTPOINT
    mkdir -p $MOUNTPOINT
fi


if ! mountpoint -q $MOUNTPOINT; then
    echo sudo mkfs.xfs -f $DEV
    sudo mkfs.xfs -f $DEV

    echo sudo mount -t xfs $DEV $MOUNTPOINT
    sudo mount -t xfs $DEV $MOUNTPOINT
fi


sudo blktrace $DEV  & PID=$!; sleep 1 ; ../bench.sh $1 $DEV $MOUNTPOINT $2 fillrandom 0; echo kill $PID; sudo kill $PID



echo sudo umount $MOUNTPOINT
sudo umount $MOUNTPOINT


sleep 1
blkparse $BDEV > events.log
sleep 1
 ../extract_write_amount.sh events.log db.log | tee result.log

# p99.log format:
# db_size_in_M AF benchmark p90 p99 p999
#paste <(cat db.log|grep p99 | awk '{print $1, $4, $6, $8 }' | sed -e "s/^/$1 $2 /") <(cat db.log|grep micros | awk '{print $3}') | tee p99.log 

#paste <(cat db.log|grep p99 | awk '{print $1, $4, $6, $8 }' | sed -e "s/^/$1 $2 /") <(cat db.log|grep micros | awk '{print $3}') | tee p99.log 

rm -f p99.log
echo processing db.log
for bench in `grep micros db.log | cut -f1 -d" "`; do
#    echo benchmark: $bench
    P50=`grep -A 10 $bench db.log | grep -o "P50: [0-9.]*" | cut \
-d: -f2`    
    P99=`grep -A 10 $bench db.log | grep -o "P99: [0-9.]*" | cut \
-d: -f2`
    P999=`grep -A 10 $bench db.log | grep -o "P99.9: [0-9.]*" | c\
ut -d: -f2`
    Avg=`grep -A 10 $bench db.log | grep micros | awk '{print $3}'`
    echo $1 $2 $bench $P50 $P99 $P999 $Avg | tee -a p99.log
done
