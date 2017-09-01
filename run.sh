#!/bin/bash
BDEV=nvme0n1
DEV=/dev/$BDEV
MOUNTPOINT=/home/fwu/levelmount
AMF_HOME=/home/fwu/blktrace

# usaage: run_bench benchmark use_existing_db
# e.g.  : run_bench fillrandom($1) 0($2)
function run_bench
{
    mkdir $1 && cd $1
    if [ $2 -eq 0 ]; then
	BENCH_SIZE=$SIZE
    else
	BENCH_SIZE=$SMALL_SIZE
    fi
    
#    echo    "sudo blktrace $DEV  & PID=$!; sleep 1 ; $AMF_HOME/bench.sh $BENCH_SIZE $DEV $MOUNTPOINT $AF $1 $2; echo kill $PID; sudo kill $PID"
#    sudo blktrace $DEV  & PID=$!; sleep 1 ; $AMF_HOME/bench.sh $BENCH_SIZE $DEV $MOUNTPOINT $AF $1 $2; echo kill $PID; sudo kill $PID


    echo  $AMF_HOME/bench.sh $BENCH_SIZE $DEV $MOUNTPOINT $AF $1 $2
    $AMF_HOME/bench.sh $BENCH_SIZE $DEV $MOUNTPOINT $AF $1 $2
    
    cd ..

    mv $1/*.log .
}


if [ \( $# -ne 1 \) -a \( $# -ne 2 \) ]
then
    echo usage: $0 db_size_in_M db_amplification_factor
fi

SIZE=$1
SMALL_SIZE=1000
AF=$2

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

#run_bench fillseq 0
run_bench fillrandom 0
#run_bench seekrandom 1
run_bench readrandom 1
#run_bench overwrite 1
#run_bench readwhilewriting 1
#run_bench readseq 1
#run_bench readhot 1
#run_bench readmissing 1


echo sudo umount $MOUNTPOINT
sudo umount $MOUNTPOINT


 $AMF_HOME/extract_write_amount.sh fillrandom_blk.log fillrandom_db.log | tee result.log

# p99.log format:
# db_size_in_M AF benchmark p90 p99 p999
#paste <(cat db.log|grep p99 | awk '{print $1, $4, $6, $8 }' | sed -e "s/^/$1 $2 /") <(cat db.log|grep micros | awk '{print $3}') | tee p99.log 

#paste <(cat db.log|grep p99 | awk '{print $1, $4, $6, $8 }' | sed -e "s/^/$1 $2 /") <(cat db.log|grep micros | awk '{print $3}') | tee p99.log 

rm -f p99.log db.log
echo processing db.log
cat *_db.log > db.log
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


