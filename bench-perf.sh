#!/bin/bash

DB_BENCH=/home/fwu/leveldb/out-static/db_bench
FLAME_GRAPH_PATH=/home/fwu/FlameGraph
BCC_TOOLS_PATH=/usr/share/bcc/tools
#DB_BENCH=/home/fwu/rocksdb_official/db_bench

if [ $# -ne 6 ]; then
    echo usage: $0 db_size_in_M bdevname mountpoint amplification_factor benchmark use_existing_db
    exit -1
fi

iostat -m | grep `basename $2`  | sed "s/`basename $2`/start/g" | tee $5_iostat.log

#    sudo perf record -ag   --  $DB_BENCH --db=$3 --num=$(($1*1024)) --value_size=1008 --histogram=1 --compression_ratio=1 --max_bytes_for_level_multiplier=$4  --benchmarks=$5,amp_stats,stats --use_existing_db=$6 | tee $5_db.log

sudo perf record -ag   --  $DB_BENCH --db=$3 --num=$(($1*1024)) --value_size=1008 --histogram=1 --compression_ratio=1 --max_bytes_for_level_multiplier=$4  --benchmarks=$5,amp_stats,stats --use_existing_db=$6 # | tee $5_db.log

perf script | $FLAME_GRAPH_PATH/stackcollapse-perf.pl > out.perf-folded
$FLAME_GRAPH_PATH/flamegraph.pl out.perf-folded > flamegraph-kernel-$5.svg

#--max_grandparent_overlap_factor=$overlap
    iostat -m | grep `basename $2`  | sed "s/`basename $2`/$5/g" | tee -a $5_iostat.log


cat $5_iostat.log | awk -v data_size_M=$1 'BEGIN{lastr=-1; lastw=-1}{if (lastr >= 0){print $1, data_size_M, $5 - lastr, $6 - lastw, ($5 - lastr)/data_size_M, ($6 - lastw)/data_size_M;} lastr = $5; lastw = $6}' | tee $5_iostat_adv.log
