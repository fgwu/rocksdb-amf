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
    
    echo time  $AMF_HOME/bench-lite.sh $BENCH_SIZE $DEV $MOUNTPOINT $AF $1 $2
    time $AMF_HOME/bench-lite.sh $BENCH_SIZE $DEV $MOUNTPOINT $AF $1 $2
    
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
    echo sudo mkfs.xfs $DEV
    sudo mkfs.xfs $DEV
    
    echo sudo mount -t xfs $DEV $MOUNTPOINT
    sudo mount -t xfs $DEV $MOUNTPOINT
fi

run_bench fillseq 0
#run_bench fillrandom 0
#run_bench seekrandom 1
run_bench overwrite 1
run_bench readwhilewriting 1
run_bench readrandom 1
#run_bench readseq 1
#run_bench readhot 1
#run_bench readmissing 1

