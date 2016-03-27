library(ggplot2)

unlist.me <- function (l) {
  ## turn a list into a dataframe?
  len <- length(l)
  if (len > 11) {
    data.frame(pid=l[2], pct.cpu=l[3], pct.mem=l[4], rss=l[6], stat=l[8], start=l[9], time=l[10], command=l[11], args=paste(l[12:len], collapse=' '), stringsAsFactors=FALSE)
  } else {
    data.frame(pid=l[2], pct.cpu=l[3], pct.mem=l[4], rss=l[6], stat=l[8], start=l[9], time=l[10], command=l[11], args=NA, stringsAsFactors=FALSE)
  }
  
}

sampler <- read.delim("sampler.out", 
                      header=FALSE, 
                      stringsAsFactors=FALSE)

### fixup sampled memory (from /proc/mem)
sampled.mem <- sampler[sampler$V1 == "MEM",] # only mem entries
# split output from /proc/mem into variable -> value pairs
mem.var <- gsub('^([^:]+):[ ]+([0-9]+).*', '\\1', sampled.mem$V3)
mem.val <- as.numeric(gsub('^([^:]+):[ ]+([0-9]+).*', '\\2', sampled.mem$V3))
sampled.mem <- data.frame(type=sampled.mem$V1, date=sampled.mem$V2, variable=mem.var, value=mem.val)
rm(mem.var, mem.val)
# unfactor date
sampled.mem$date <- as.character(sampled.mem$date)
# extract time
sampled.mem$time <- gsub("^.+(\\d\\d:\\d\\d:\\d\\d).*$", "\\1", sampled.mem$date)

### Fix up sampled processes 
sampled.proc <- sampler[sampler$V1 == "PROC",]
names(sampled.proc) <- c("type", "date", "psout")
sampled.proc.splt <- strsplit(sampled.proc$psout, "[ ]+") # split output into components
# create a data frame of tabular ps output (will take a while...)
sampled.proc <- cbind(sampled.proc$type, sampled.proc$date, do.call(rbind.data.frame, lapply(sampled.proc.splt, unlist.me)))
names(sampled.proc)[1] <- "type"
names(sampled.proc)[2] <- "date"
rm(sampled.proc.splt)
sampled.proc <- sampled.proc[sampled.proc$pid != "PID",] # delete ps header rows
`%ni%` = Negate(`%in%`)
# get rid of samples from non-relevant processes
sampled.proc <- sampled.proc[sampled.proc$command %ni% c("/bin/bash", "tee", "-bash", "ps", "/bin/sh", "[sh]", '[3dcalc]', '[mriqc]', 'top'), ]
sampled.proc$type <- as.character(sampled.proc$type)
sampled.proc$type[grep("/bin/mriqc", sampled.proc$args)] <- "PROC.mriqc"
sampled.proc$type[grep("/bin/mriqc", sampled.proc$args, invert=TRUE)] <- "PROC.interfaced_subprocess"
# call this command what it actually is
sampled.proc$command[sampled.proc$command == "/work/03872/wtriplet/lonestar/anaconda/bin/python"] <- "python mriqc -i ..."
# fix up date/time
sampled.proc$date <- as.character(sampled.proc$date)
sampled.proc$time <- gsub("^.+(\\d\\d:\\d\\d:\\d\\d).*$", "\\1", sampled.proc$date)
sampled.proc$time <- as.POSIXct(sampled.proc$time, format = "%H:%M:%S")
sampled.proc$type <- as.factor(sampled.proc$type)
sampled.proc$rss <- as.numeric(sampled.proc$rss)

### plot

# i think this only makes since because table is already sorted in time.
p <- ggplot(sampled.proc, aes(x=time, y=rss/1024/1024))
p + geom_point(aes(color=stat), pch=3, size=1, alpha=0.75) + 
  facet_wrap(~command, ncol=1) + theme_bw(base_size=12) + 
  labs(x="Time", y="Memory Used (GB)", title="Memory profile of mriqc run (linear)")
ggsave(filename='sampled.pdf', w=8.5, h=14, plot=last_plot())
