#!/bin/bash

result_dir=result

#rm -rf $result_dir
#mkdir $result_dir

for bench in fillseq overwrite readwhilewriting readrandom; do
    echo -n processing $bench ... " "
    >${result_dir}/db_${bench}.csv
    for size in 1000 10000 100000; do
	echo -n ${size} " " >> ${result_dir}/db_${bench}.csv
	for AF in 4 10; do
	    logfile=r${AF}s${size}M/${bench}_db.log
	    # value size
	    grep -wrn Values $logfile |	awk '{print $2/1000, "\ "}' | \
		xargs echo -n >> ${result_dir}/db_${bench}.csv

	    # us/op
	    grep -wrn micros/op $logfile | awk '{print $3, "\ "}' | \
		xargs echo -n >> ${result_dir}/db_${bench}.csv

	    # p50
	    grep -wrn Percentiles $logfile | awk '{print $3, "\ "}' | \
		xargs echo -n >> ${result_dir}/db_${bench}.csv

	    # p99
	    grep -wrn Percentiles $logfile | awk '{print $7, "\ "}' | \
		xargs echo -n >> ${result_dir}/db_${bench}.csv

	    # p999
	    grep -wrn Percentiles $logfile | awk '{print $9, "\ "}' | \
		xargs echo -n >> ${result_dir}/db_${bench}.csv
	done
	echo ""  >> ${result_dir}/db_${bench}.csv # new line
    done
    echo done
#    cat ${result_dir}/db_${bench}.csv

    sed "s/bench/${bench}/g" dbtest.gp.template > ${result_dir}/db_${bench}.gp
    (cd ${result_dir} && gnuplot db_${bench}.gp )
done



