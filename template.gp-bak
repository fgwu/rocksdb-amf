reset

set terminal postscript eps color enhanced size 10,3 font "Times-Roman" 22
set output 'BENCH.eps'

set style data histogram 
#set style histogram rowstacked
set style histogram cluster gap 1
set style fill solid border -1

set boxwidth .65

set key invert nobox
set multiplot layout 2,1
set ylabel 'avg latency (us)'
plot 'BENCH_avg.log' u ($2):xtic(1) t 'AF=4',\
     '' u ($3) t 'AF=7', \
     '' u ($4) t 'AF=10', \
    '' u ($5) t 'AF=20'



#set logscale y
set ylabel 'p99 latency (us)'
plot 'BENCH_p99.log' u ($2):xtic(1) t 'AF=4',\
     '' u ($3) t 'AF=7', \
     '' u ($4) t 'AF=10', \
    '' u ($5) t 'AF=20'