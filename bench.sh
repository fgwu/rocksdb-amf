#!/bin/bash

DB_BENCH=/home/fwu/leveldb/out-static/db_bench
#DB_BENCH=/home/fwu/rocksdb_official/db_bench

# run_bench  db_size_in_M bdevname mountpoint amplification_factor benchmark using_existing_db
function run_bench
{
    echo     "sudo $DB_BENCH --db=$3 --num=$(($1*1024)) --value_size=1008 --histogram=1 --compression_ratio=1 --max_bytes_for_level_multiplier=$4  --benchmarks=$5,amp_stats,stats --use_existing_db=$6 | tee -a db.log"

    sudo $DB_BENCH --db=$3 --num=$(($1*1024)) --value_size=1008 --histogram=1 --compression_ratio=1 --max_bytes_for_level_multiplier=$4  --benchmarks=$5,amp_stats,stats --use_existing_db=$6 | tee -a db.log
#--max_grandparent_overlap_factor=$overlap
    iostat -m | grep `basename $2`  | sed "s/`basename $2`/$5/g" | tee -a iostat.log
}

if [ $# -ne 4 ]; then
    echo usage: $0 db_size_in_M bdevname mountpoint amplification_factor
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

#echo "sudo db_bench --db=$3 --num=$(($1*1024)) --value_size=1008 --histogram=1 --compression_ratio=1 --amplification_factor=$4 --benchmarks=fillrandom,stats,seekrandom,stats,readrandom,stats | tee db.log"
iostat -m | grep `basename $2`  | sed "s/`basename $2`/start/g" | tee iostat.log

run_bench $@ fillrandom 0
run_bench $@ seekrandom 1
run_bench $@ readrandom 1
run_bench $@ overwrite 1
run_bench $@ readwhilewriting 1

cat iostat.log | awk -v data_size_M=$1 'BEGIN{lastr=-1; lastw=-1}{if (lastr >= 0){print $1, data_size_M, $5 - lastr, $6 - lastw, ($5 - lastr)/data_size_M, ($6 - lastw)/data_size_M;} lastr = $5; lastw = $6}' | tee iostat_adv.log

echo sudo umount $3
sudo umount $3
