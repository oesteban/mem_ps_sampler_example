#!/bin/bash

cat ds053_BIDS_T1nodeface.sampout | grep "^MEM" | perl -p -e "s/^(.+):\s*([0-9]+).*$/\1\t\2/g;" -e "s/Tue Mar .. ([^ ]+) CDT 2016/\1/g" | egrep "(MemTotal|MemFree|Cached|Active|Inactive|Dirty)" > ds053_BIDS_T1nodeface_sampled.mem

(
	echo -e "TYPE\tTIME\tF\tS\tPID\tPPID\tPGID\tSID\tC\tPRI\tNI\tADDR\tSZ\tWCHAN\tRSS\tPSR\tSTIME\tTTY\tTIME\tCMD"; 
	cat ds053_BIDS_T1nodeface.sampout | grep "^PROC" | perl -p -e "s/[ ]+/\t/g" | cut -f 1,5,8-9,11-26 | egrep -v "(PPID|ssh|ps|bash|tee|top|sleep|cat|/bin/sh|ld-linux|\[.+\])"
)  > ds053_BIDS_T1nodeface_sampled.proc
