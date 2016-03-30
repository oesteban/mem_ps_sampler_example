library(ggplot2)
library(plyr)

sampled.proc <- read.delim("ds053_BIDS_T1nodeface_sampled.proc")
sampled.proc$command[sampled.proc$CMD == "/work/03872/wtriplet/lonestar/anaconda/bin/python"] <- "python mriqc -i ..."
# fix up date/time
sampled.proc$TIME <- as.POSIXct(sampled.proc$TIME, format = "%H:%M:%S")

# compute total mem used for single process in time
sampled.proc.grp <- ddply(sampled.proc, .(TIME, CMD), summarize, RSStot = sum(RSS))

# read the mem file, fix time, headers
sampled.mem <- read.delim("ds053_BIDS_T1nodeface_sampled.mem", header=FALSE)
names(sampled.mem) <- c("type", "TIME", "variable", "value")
sampled.mem$TIME <- as.POSIXct(sampled.mem$TIME, format = "%H:%M:%S")
sampled.mem <- sampled.mem[sampled.mem$variable %in% c("MemFree", "Active", "MemTotal", "Cached"),]

# from nipype crash timestamps
crashes <- read.delim("crashes.tsv")
crashes$TIME <- as.POSIXct(crashes$TIME, format = "%H:%M:%S")

# this one:
p <- ggplot(sampled.proc.grp, aes())
p + geom_line(data=sampled.mem, aes(x=TIME, y=value/1024/1024, color=variable), alpha=0.5) + 
  geom_point(aes(x=TIME, y=RSStot/1024/1024), pch=20, size=1, alpha=0.75) +
  geom_vline(data=crashes, aes(xintercept=as.numeric(TIME)), linetype=3, color='#999999') +
  facet_wrap(~CMD, ncol=1) + theme_bw(base_size=12) + 
  theme(panel.grid.major=element_blank(), panel.grid.minor=element_blank()) +
  labs(x="Time", y="Total Memory (GB)", 
       title="Memory profile of mriqc run (multiproc --threads=48)", 
       color="Memory Partition")
#ggsave(filename='sampled_multiproc.pdf', w=8.5, h=14, plot=last_plot())

# not this
# sampled.mem.grp <- ddply(sampled.mem, .(TIME), summarize, MemFree=sum(value))
# p <- ggplot(sampled.proc.grp, aes())
# p + geom_line(data=sampled.mem.grp, aes(x=TIME, y=MemFree/1024/1024), color="#999999", alpha=0.5) + 
#   geom_point(aes(x=TIME, y=RSStot/1024/1024), pch=20, size=1, alpha=0.75) +
#   scale_x_date() + 
#   facet_wrap(~CMD, ncol=1) + theme_bw(base_size=12) + 
#   labs(x="Time", y="Total Memory (GB)", 
#        title="Memory profile of mriqc run (multiproc --threads=48)", 
#        color="Memory Partition")
# ggsave(filename='sampled_multiproc.pdf', w=8.5, h=14, plot=last_plot())
