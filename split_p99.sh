if [ ! -d p99 ]; then
    mkdir -p p99
fi


rm p99/*

cat */p99.log  | sort -k3,3d -k1,1g -k2,2g |sed -e 's/\t/ /g' |tee  p99/p99_total.log

cd p99

awk '{print>$3}' p99_total.log
