#!/bin/bash

#for f in ls */*insert*; do
#    echo $f
#done

# for bench in insert overwrite readwrite writesync randread; do
#     echo -n processing $bench ... " "
#     >db_${bench}.csv
#     grep -wrn Values */*${bench}_db_*.txt | \
# 	awk '{printf $2 " "} END {printf "\n"}' >> db_${bench}.csv
#     grep -wrn micros/op */*${bench}_db_*.txt | \
# 	awk '{printf $3 " "} END {printf "\n"}' >> db_${bench}.csv
#     grep -wrn micros/op */*${bench}_db_*.txt | \
# 	awk '{printf $5 " "} END {printf "\n"}' >> db_${bench}.csv
#     grep -wrn micros/op */*${bench}_db_*.txt | \
# 	awk '{printf $7 " "} END {printf "\n"}' >> db_${bench}.csv
#     grep -wrn -A 6 "DB path" */*${bench}_db_*.txt |\
# 	awk '{if ($2 == "P50:") printf $3 " "} END {printf "\n"}' \
# 	    >> db_${bench}.csv
#     grep -wrn -A 6 "DB path" */*${bench}_db_*.txt |\
# 	awk '{if ($6 == "P99:") printf $7 " "} END {printf "\n"}' \
# 	    >> db_${bench}.csv
#     grep -wrn -A 6 "DB path" */*${bench}_db_*.txt |\
# 	awk '{if ($8 == "P99.9:") printf $9 " "} END {printf "\n"}' \
# 	    >> db_${bench}.csv
#     grep -wrn -A 6 "DB path" */*${bench}_db_*.txt |\
# 	awk '{if ($10 == "P99.99:") printf $11 " "} END {printf "\n"}' \
# 	    >> db_${bench}.csv


#     echo done
# done


for bench in insert overwrite readwrite writesync randread; do
    echo -n processing $bench ... " "
    >db_${bench}.csv
    # 1 values size KB
    grep -wrn Values */*${bench}_db_*.txt | awk '{print $2/1000}' > tmp.csv && \
	cp db_${bench}.csv db_${bench}.csv.old && \
	paste db_${bench}.csv.old tmp.csv > db_${bench}.csv && \
	rm -f  db_${bench}.csv.old

    # 2 us/op
    grep -wrn micros/op */*${bench}_db_*.txt |awk '{print $3}' > tmp.csv &&\
    	cp db_${bench}.csv db_${bench}.csv.old && \
    	paste db_${bench}.csv.old tmp.csv > db_${bench}.csv && \
    	rm -f  db_${bench}.csv.old

    # 3 ops/sec
    grep -wrn micros/op */*${bench}_db_*.txt |awk '{print $5}' > tmp.csv &&\
    	cp db_${bench}.csv db_${bench}.csv.old && \
    	paste db_${bench}.csv.old tmp.csv > db_${bench}.csv && \
    	rm -f  db_${bench}.csv.old

    # 4 MB/s
    grep -wrn micros/op */*${bench}_db_*.txt |awk '{print $7}' > tmp.csv &&\
    	cp db_${bench}.csv db_${bench}.csv.old && \
    	paste db_${bench}.csv.old tmp.csv > db_${bench}.csv && \
    	rm -f  db_${bench}.csv.old

    # 5 P50
    grep -wrn -A 6 "DB path" */*${bench}_db_*.txt |\
    	awk '{if ($2 == "P50:") print $3}' > tmp.csv &&\
    	cp db_${bench}.csv db_${bench}.csv.old && \
    	paste db_${bench}.csv.old tmp.csv > db_${bench}.csv && \
    	rm -f  db_${bench}.csv.old

    # 6 P99
    grep -wrn -A 6 "DB path" */*${bench}_db_*.txt |\
    	awk '{if ($6 == "P99:") print $7}' > tmp.csv &&\
    	cp db_${bench}.csv db_${bench}.csv.old && \
    	paste db_${bench}.csv.old tmp.csv > db_${bench}.csv && \
    	rm -f  db_${bench}.csv.old

    # 7 P999    
    grep -wrn -A 6 "DB path" */*${bench}_db_*.txt |\
    	awk '{if ($8 == "P99.9:") print $9}' > tmp.csv &&\
    	cp db_${bench}.csv db_${bench}.csv.old && \
    	paste db_${bench}.csv.old tmp.csv > db_${bench}.csv && \
    	rm -f  db_${bench}.csv.old

    # 8 P9999
    grep -wrn -A 6 "DB path" */*${bench}_db_*.txt |\
    	awk '{if ($10 == "P99.99:") print $11}' > tmp.csv &&\
    	cp db_${bench}.csv db_${bench}.csv.old && \
    	paste db_${bench}.csv.old tmp.csv > db_${bench}.csv && \
    	rm -f  db_${bench}.csv.old


    sed -i 's/\t/ /g' db_${bench}.csv
    rm -f tmp.csv
    cat db_${bench}.csv | awk '{printf NR; print}'
    cat db_${bench}.csv | awk '{if (NR%2 == 1) print}' > db_${bench}_kern.csv
    cat db_${bench}.csv | awk '{if (NR%2 == 0) print}' > db_${bench}_spdk.csv

    sed "s/bench/${bench}/g" dbtest.gp.template > dbtest_${bench}.gp

    gnuplot dbtest_${bench}.gp
    
    echo done
done


