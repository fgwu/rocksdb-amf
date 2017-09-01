#!/bin/bash

if [ $# -ne 6 ]; then
    echo usage: $0 db_size_in_M bdevname mountpoint amplification_factor benchmark use_existing_db
    exit -1
fi

bench=$5
size=$((1024 * $1))
use_existing_db=$6
mount_point=$3
AF=$4

function main_thread
{
    db_bench --db=${mount_point} --num=${size} \
	     --value_size=1008 --histogram=1 \
	     --compression_ratio=1 \
	     --max_bytes_for_level_multiplier=${AF} \
	     --benchmarks=${bench},amp_stats,stats \
	     --use_existing_db=${use_existing_db} |\
	tee  ${bench}_db.log
    
    kill -SIGINT $(pgrep -x profile)
    kill -SIGINT $(pgrep -x offcputime)

    sleep 1
    
    flamegraph < ${bench}.profile \
	       --title="Profile Flame Graph" \
	       --countname=ms --width=600 > ${bench}.profile.svg
    flamegraph < ${bench}.offcpu \
	       --title="Off-CPU Time Flame Graph" \
	       --color=io \
	       --countname=ms --width=600 > ${bench}.offcpu.svg 
   
}


(main_thread)&

sleep 1

PID=$(pgrep -x db_bench)
cp /proc/$PID/maps /tmp/proc$PID

(trap - SIGINT;  \
 profile -f -p $PID \
	 --stack-storage-size=51200\
	 > ${bench}.profile )&

(trap - SIGINT;  \
 offcputime -f -p $PID \
	    --stack-storage-size=51200  \
	    > ${bench}.offcpu )&

FAIL=0

for job in `jobs -p`
do
    echo $job
    wait $job || let "FAIL+=1"
done

echo $FAIL

if [ "$FAIL" == "0" ];
then
    echo "YAY!"
else
    echo "FAIL! ($FAIL)"
fi

    


#if [ -z $(pgrep -x profile) ]; then
#    echo  kill -SIGINT `pgrep -x profile`
#    kill -SIGINT `pgrep -x profile`
#fi

#if [ -z $(pgrep -x offcputime) ]; then
#    echo  kill -SIGINT `pgrep -x offcputime`
#    kill -SIGINT `pgrep -x offcputime`
#fi
