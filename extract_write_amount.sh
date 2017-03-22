#!/bin/bash


if [ $# -ne 2 ]; then
    echo usage: $0 event_log db_log
    exit -1
fi

#cat  $1  | awk '{if ( $6=="D") print $0}' |  grep W | awk '{blknum = blknum + $10}END{print blknum * 512/1024/1024 GB}'

data_size=`cat $2 | grep FileSize | awk '{print $2}'`
level_num=`cat $2 | awk '{print $1}'| tail -n 2| head -n 1`
written_size=`cat  $1  | awk '{if ( $6=="D") print $0}' |  grep W | grep db_bench | awk '{blknum = blknum + $10}END{print blknum * 512/1024/1024}'`
#cat $2 | head -n 7  | tail -n 1| awk '{print $1}'
echo original data size $data_size MB
echo written data size $written_size MB with $level_num levels
echo write amplification: `echo $written_size / $data_size | bc -l`






#cat  $1  | awk '{if ( $6=="D") print $0}' |  grep W | grep jbd | awk '{blknum = blknum + $10}END{print blknum * 512/1024/1024 GB}'
