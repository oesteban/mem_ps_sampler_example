#!/bin/bash

# run this in a screen or tmux session in the background
# maybe launch it as
#  stdbuf -o 0 ./sample.sh > sampler.out 
# so output isn't buffered in mem.
# this creates a sample file.

while [ 1 ]; do 
    date=$(date)

    while read line; do 
        echo -e "MEM\t${date}\t${line}"
    done < <(cat /proc/meminfo)

    while read line; do 
        echo -e "PROC\t${date}\t${line}"
    done < <(ps -jFl -u wtriplet -U wtriplet)

    sleep 1
done


