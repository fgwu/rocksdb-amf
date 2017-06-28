if [ ! -d p99 ]; then
    mkdir -p p99
fi


rm -f p99/*

cat */p99.log  | sort -k3,3d -k1,1g -k2,2g |sed -e 's/\t/ /g' >  p99/p99_total.log

cd p99

awk '{print>$3".log"}' p99_total.log
for f in `ls | grep -v p99_total.log`; do
    bench=`echo $f|sed "s/.log//g"`
    echo processing $bench ...
    cat $f | awk 'BEGIN{prev=""}{if (prev != "" && $1!=prev) printf "\n"; if ($1 != prev) printf $1 "MB ";  printf $5 " "; prev = $1 }END{printf "\n"}' > ${bench}_p99.log
    cat $f | awk 'BEGIN{prev=""}{if (prev != "" && $1!=prev) printf "\n"; if ($1 != prev) printf $1 "MB ";  printf $7 " "; prev = $1 }END{printf "\n"}' > ${bench}_avg.log
    cat ../template.gp | sed -e "s/BENCH/$bench/g" > $bench.gp
    gnuplot $bench.gp
#    evince $bench.eps &
done
