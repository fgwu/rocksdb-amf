reset

set terminal postscript eps color enhanced size 6,4 font "Times-Roman" 22
set output 'BENCH.eps'

set style data histogram 
#set style histogram rowstacked
set style histogram cluster gap 1
set style fill solid border -1

set boxwidth .65
set yrange [0:*]

#set key invert nobox
set key  nobox
set key right outside
set multiplot layout 2,1
set title 'BENCH avg lat'
set ylabel 'avg latency (us)'
plot 'BENCH_avg.log' u ($2):xtic(1) t 'AF=4',\
     '' u ($3) t 'AF=10'



#set logscale y
set title 'BENCH p99 lat'
set ylabel 'p99 latency (us)'
plot 'BENCH_p99.log' u ($2):xtic(1) t 'AF=4',\
     '' u ($3) t 'AF=10'
