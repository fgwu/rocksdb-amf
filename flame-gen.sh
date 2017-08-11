
if [ $# -eq 1 ]; then
    bench=$1
else
    bench=$(echo `pwd` | awk -F'/' '{print $NF}')
fi

flamegraph.pl < ${bench}.profile --title="${bench} On-CPU Flame Graph" --countname=ms --width=600 > ${bench}.profile.svg
flamegraph.pl < ${bench}.offcpu --title="${bench} Off-CPU Time Flame Graph" --color=io --countname=ms --width=600 > ${bench}.offcpu.svg
