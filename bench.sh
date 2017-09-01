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


sudo -- bash -c " mkfifo myfifo.$$; $DB_BENCH --db=$3 --num=$(($1*1024)) --value_size=1008 --histogram=1 --compression_ratio=1 --max_bytes_for_level_multiplier=$4  --benchmarks=$5,amp_stats,stats --use_existing_db=$6 > myfifo.$$ &  PID=\$!; tee $5_db.log < myfifo.$$ & (trap - SIGINT; profile -f -U -p \$PID 5 > $5.profile )& (trap - SIGINT; offcputime -f -U -p \$PID 5 > $5.offcpu )&  wait \$PID; echo PID \$PID completed.; rm -f myfifo.$$;"

$DB_BENCH --db=$3 --num=$(($1*1024)) --value_size=1008 --histogram=1 --compression_ratio=1 --max_bytes_for_level_multiplier=$4  --benchmarks=$5,amp_stats,stats --use_existing_db=$6 |tee $5_db.log 

#if [ `pgrep -x profile` ]; then
#    echo  kill -SIGINT `pgrep -x profile`
#    kill -SIGINT `pgrep -x profile`
#fi

#if [ `pgrep -x offcputime` ]; then
#    echo  kill -SIGINT `pgrep -x offcputime`
#    kill -SIGINT `pgrep -x offcputime`
#fi


flamegraph < $5.profile --title="Profile Flame Graph" --countname=ms --width=600 > $5.profile.svg
flamegraph < $5.offcpu --title="Off-CPU Time Flame Graph" --color=io --countname=ms --width=600 > $5.offcpu.svg


    iostat -m | grep `basename $2`  | sed "s/`basename $2`/$5/g" | tee -a $5_iostat.log


cat $5_iostat.log | awk -v data_size_M=$1 'BEGIN{lastr=-1; lastw=-1}{if (lastr >= 0){print $1, data_size_M, $5 - lastr, $6 - lastw, ($5 - lastr)/data_size_M, ($6 - lastw)/data_size_M;} lastr = $5; lastw = $6}' | tee $5_iostat_adv.log
