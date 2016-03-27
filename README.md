# mem_ps_sampler_example
quick example script to sample what's running on a system

## usage
```{sh}
screen 
stdbuf -o 0 ./sampler.sh > sampler.out
# sampling begins.
```
When the time comes to wrap things up, sampler.out looks like:
```
MEM	Sun Mar 27 09:41:42 CDT 2016	PageTables:         3360 kB
MEM	Sun Mar 27 09:41:42 CDT 2016	NFS_Unstable:          0 kB
MEM	Sun Mar 27 09:41:42 CDT 2016	Bounce:                0 kB
MEM	Sun Mar 27 09:41:42 CDT 2016	WritebackTmp:          0 kB
MEM	Sun Mar 27 09:41:42 CDT 2016	CommitLimit:    63996108 kB
[...]
MEM	Sun Mar 27 09:41:42 CDT 2016	HugePages_Rsvd:        0
MEM	Sun Mar 27 09:41:42 CDT 2016	DirectMap2M:     2023424 kB
MEM	Sun Mar 27 09:41:42 CDT 2016	DirectMap1G:    65011712 kB
PROC	Sun Mar 27 09:41:42 CDT 2016	USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
PROC	Sun Mar 27 09:41:42 CDT 2016	wtriplet   380 40.0  0.0  14980  1696 pts/1    S+   09:41   0:00 /bin/bash /home1/03872/wtriplet/sample.sh
PROC	Sun Mar 27 09:41:42 CDT 2016	wtriplet   384  0.0  0.0  14980   812 pts/1    S+   09:41   0:00 /bin/bash /home1/03872/wtriplet/sample.sh
PROC	Sun Mar 27 09:41:42 CDT 2016	wtriplet   385  0.0  0.0   7500  1024 pts/1    R+   09:41   0:00 ps auwww
[...]
```
Then, the R script turns sampler.out into a graph. note that some filtering happens to remove processes that are not relevant to what's being profiles, and the filtering may need to be customized on a per-case basis.

## notes
* R script does not make use of the `MEM` entries -- could be used to track system memory availability vs the single process mem. 
