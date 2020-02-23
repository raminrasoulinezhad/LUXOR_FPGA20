library(ggplot2)
library(ggthemes)
library(reshape2)
library(viridis)
library(grid)
library(pBrackets)

# read in all results into a dataframe
data <- read.csv("results/all_results.csv")
data$test_num <- data$test_num + 1

# primary compression costs, sorted by test number as listed in tests/all_tests.csv
primary_compression_cost <- c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,18,32,50,72,98,128,162,200,242,288,338,392,450,512)
primary_compression_cost_baseline_bnns <- c(384,768,1536,3072,6144)
primary_compression_cost_luxor_bnns <- c(192,384,768,1536,3072)
num_all_minus_bnns <- length(primary_compression_cost)
num_bnns <- length(primary_compression_cost_baseline_bnns)

# data-frame of primary compression (PC) costs
pcdf <- data.frame(test_num=seq(1,num_all_minus_bnns+num_bnns),primary_cost=c(primary_compression_cost,primary_compression_cost_baseline_bnns))
pcdf$label <- "all"
tmp <- data.frame(test_num=seq(num_all_minus_bnns+1,num_all_minus_bnns+num_bnns),primary_cost=primary_compression_cost_luxor_bnns)
tmp$label <- "luxor"
pcdf <- rbind(pcdf,tmp)

# merge PC costs to main data frame
data$label <- "all"
data$label[data$test_num > num_all_minus_bnns & (data$arch == "X_LUXOR" | data$arch == "X_LUXOR+" | data$arch == "I_LUXOR" | data$arch == "I_LUXOR+")] <- "luxor"
data <- merge(data,pcdf,by=c("test_num","label"))
data$total_cost <- data$primary_cost + data$cost
data <- data[,c("test_num","arch","total_cost","stages")]

# reshape dataframe
tmp <- data.frame(test_num=c(-1),x=c(0),x_l=c(0),x_lp=c(0),i=c(0),i_l=c(0),i_lp=c(0),x_stages=c(0),x_l_stages=c(0),x_lp_stages=c(0),i_stages=c(0),i_l_stages=c(0),i_lp_stages=c(0))
for (i in 1:58) {
    v <- data.frame(
            test_num=c(i),
            x=c(data$total_cost[data$test_num == i & data$arch == "Xilinx_Baseline"]),
            x_l=c(data$total_cost[data$test_num == i & data$arch == "X_LUXOR"]),
            x_lp=c(data$total_cost[data$test_num == i & data$arch == "X_LUXOR+"]),
            i=c(data$total_cost[data$test_num == i & data$arch == "Intel_Baseline"]),
            i_l=c(data$total_cost[data$test_num == i & data$arch == "I_LUXOR"]),
            i_lp=c(data$total_cost[data$test_num == i & data$arch == "I_LUXOR+"]),
                    
            x_stages=c(data$stages[data$test_num == i & data$arch == "Xilinx_Baseline"]),
            x_l_stages=c(data$stages[data$test_num == i & data$arch == "X_LUXOR"]),
            x_lp_stages=c(data$stages[data$test_num == i & data$arch == "X_LUXOR+"]),
            i_stages=c(data$stages[data$test_num == i & data$arch == "Intel_Baseline"]),
            i_l_stages=c(data$stages[data$test_num == i & data$arch == "I_LUXOR"]),
            i_lp_stages=c(data$stages[data$test_num == i & data$arch == "I_LUXOR+"])
        )
    tmp <- rbind(tmp,v)
}
data <- tmp[tmp$test_num > 0,]

data$x_l_ratio <- data$x_l / data$x
data$x_lp_ratio <- data$x_lp / data$x
data$x_l_ratio[data$x_l_ratio > 1.0] <- 1.0
data$x_lp_ratio[data$x_lp_ratio > 1.0] <- 1.0

data$i_l_ratio <- data$i_l / data$i
data$i_lp_ratio <- data$i_lp / data$i
data$i_l_ratio[data$i_l_ratio > 1.0] <- 1.0
data$i_lp_ratio[data$i_lp_ratio > 1.0] <- 1.0

data$x_ratio <- 1.0
data$i_ratio <- 1.0

# pretty labels for plot
data$labels <- c("S4","S8","S16","S32","S64","S128","S256","S512","S1024","S2048","S4096","D4","D8","D16","D32","D64","D128","D256","D512","D1024","D2048","D4096","2x 2b","3x 3b","4x 4b","5x 5b","6x 6b","7x 7b","8x 8b","9x 9b","10x 10b","11x 11b","12x 12b", "13x 13b", "14x 14b", "15x 15b", "16x 16b", "FIR-3","3M2x2b","3M3x3b","3M4x4b","3M5x5b","3M6x6b","3M7x7b","3M8x8b","3M9x9b","3M10x10b","3M11x11b","3M12x12b","3M13x13b","3M14x14b","3M15x15b","3M16x16b","3x3x64","3x3x128","3x3x256","3x3x512","3x3x1024")

# fix order of labels in plot
data$labels <- factor(data$labels, levels=c("S4","S8","S16","S32","S64","S128","S256","S512","S1024","S2048","S4096","D4","D8","D16","D32","D64","D128","D256","D512","D1024","D2048","D4096","2x 2b","3x 3b","4x 4b","5x 5b","6x 6b","7x 7b","8x 8b","9x 9b","10x 10b","11x 11b","12x 12b", "13x 13b", "14x 14b", "15x 15b", "16x 16b", "FIR-3","3M2x2b","3M3x3b","3M4x4b","3M5x5b","3M6x6b","3M7x7b","3M8x8b","3M9x9b","3M10x10b","3M11x11b","3M12x12b","3M13x13b","3M14x14b","3M15x15b","3M16x16b","3x3x64","3x3x128","3x3x256","3x3x512","3x3x1024"))

# find test cases whose stages decreased
data$x_annotate_stage <- ""
data$i_annotate_stage <- ""
data$x_l_annotate_stage <- ""
data$x_lp_annotate_stage <- ""
data$i_l_annotate_stage <- ""
data$i_lp_annotate_stage <- ""
data$x_l_annotate_stage[data$x_l_stages < data$x_stages] <- "*"
data$x_lp_annotate_stage[data$x_lp_stages < data$x_stages] <- "*"
data$i_l_annotate_stage[data$i_l_stages < data$i_stages] <- "*"
data$i_lp_annotate_stage[data$i_lp_stages < data$i_stages] <- "*"

# prune benchmark list to show (make plot look cleaner)
data <- data[!(data$test_num %in% seq(1,4)),]
data <- data[!(data$test_num %in% seq(12,15)),]
data <- data[!(data$test_num %in% c(39,40,42,43,44,46,47,48,50,51,52)),]
data <- data[!(data$test_num %in% seq(23,26)),]
data <- data[!(data$test_num %in% seq(28,36,by=2)),]

# change shape of dataframe
data.m <- data[,c("test_num","labels","x_ratio","x_l_ratio","x_lp_ratio","i_ratio","i_l_ratio","i_lp_ratio")]
data.m <- melt(data.m,id.vars=c("test_num","labels"))
tmp <- data[,c("test_num","labels","x_annotate_stage","x_l_annotate_stage","x_lp_annotate_stage","i_annotate_stage","i_l_annotate_stage","i_lp_annotate_stage")]
tmp <- melt(tmp,id.vars=c("test_num","labels"))
tmp$variable <- as.character(tmp$variable)
tmp$variable[tmp$variable == "x_annotate_stage"] <- "x_ratio"
tmp$variable[tmp$variable == "x_l_annotate_stage"] <- "x_l_ratio"
tmp$variable[tmp$variable == "x_lp_annotate_stage"] <- "x_lp_ratio"
tmp$variable[tmp$variable == "i_annotate_stage"] <- "i_ratio"
tmp$variable[tmp$variable == "i_l_annotate_stage"] <- "i_l_ratio"
tmp$variable[tmp$variable == "i_lp_annotate_stage"] <- "i_lp_ratio"
colnames(tmp) <- c("test_num","labels","variable","annotate_stage")
data.m <- merge(data.m,tmp,by=c("test_num","labels","variable"))

############# make plot for xilinx (without BNNs) #################

# subset relevant data
df <- data.m[data.m$test_num <= num_all_minus_bnns & (data.m$variable == "x_ratio" | data.m$variable == "x_l_ratio" | data.m$variable == "x_lp_ratio"),]

# rename architectures to prettier names for plot
df$variable <- as.character(df$variable)
df$variable[df$variable == "x_ratio"] <- "Xilinx Baseline"
df$variable[df$variable == "x_l_ratio"] <- "X-LUXOR"
df$variable[df$variable == "x_lp_ratio"] <- "X-LUXOR+"
df$variable <- factor(df$variable, levels=c("Xilinx Baseline","X-LUXOR","X-LUXOR+"))

pdf("plots/xilinx_groups_0to4.pdf",width=15,height=6)
p <- ggplot(df,aes(x=labels,y=value)) +
    geom_col(aes(fill=variable),position=position_dodge(width=0.7),width=.7) +
    geom_text(aes(x=c(4),y=c(1.2),label=c("Popcount")),size=6) +
    geom_text(aes(x=c(11),y=c(1.2),label=c("2-Column Popcount")),size=6) +
    geom_text(aes(x=c(17.5),y=c(1.2),label=c("Multi-Operand Addition")),size=6) +
    geom_text(aes(x=c(22.8),y=c(1.2),label=c("FIR-3 and 3-MAC")),size=6) +
    # geom_text(aes(x=c(27.8),y=c(1.2),label=c("XNOR-Popcount")),size=6) +
    geom_text(aes(y=value,label=annotate_stage),size=8,color="red",hjust=-0.5) +
    xlab("Micro-Benchmark") +
    scale_y_continuous("Resource Utilization Ratio",limits=c(0,1.25),breaks=seq(0,1,by=0.1),expand=c(0,0)) +
    theme(axis.title=element_text(),axis.title.y=theme_bw()$axis.title.y) +
	scale_fill_viridis(discrete=TRUE) +
	theme_minimal() +
	theme(
		legend.position="top",
        legend.direction="horizontal",
		#legend.background = element_rect(fill="gray90"),
		legend.title=element_blank(), #element_text(size=24,face="plain"),
		legend.key=element_blank(),
		legend.key.width=unit(1,"cm"),
		legend.key.height=unit(1,"cm"),
		axis.text.x=element_text(size=12,angle=45,hjust=1.0,vjust=1.0),
		axis.text.y=element_text(size=14,angle=0,hjust=1),
		axis.title.x = element_text(size=16,angle=0,hjust=.5,vjust=0,face="plain"),
        axis.title.y = element_text(size=16,hjust=.5,vjust=.5,face="plain"),
        #axis.line = element_line(colour = "black"),
        panel.border = element_blank(), # element_rect(colour = "black", fill=NA, size=1),
        # panel.border=element_blank(),
        axis.line=element_line(),
        axis.line.x=element_blank(),
        strip.text.x = element_text(size = 20,face="bold"),
		legend.text=element_text(size=16)) +
	guides(
		color=guide_legend(ncol=3,nrow=1)
	) +
	theme(axis.line = element_line(color = 'black'))

p
grid.locator(unit="native")
bottom_y <- 330
grid.brackets(57, bottom_y, 325, bottom_y, lwd=2, col="black")
grid.brackets(340, bottom_y, 610, bottom_y, lwd=2, col="black")
grid.brackets(628, bottom_y, 855, bottom_y, lwd=2, col="black")
grid.brackets(872, bottom_y, 1060, bottom_y, lwd=2, col="black")
# grid.brackets(905, bottom_y, 1060, bottom_y, lwd=2, col="black")

############# make plot for intel (without BNNs) #################

# subset relevant data
df <- data.m[data.m$test_num <= num_all_minus_bnns & (data.m$variable == "i_ratio" | data.m$variable == "i_l_ratio" | data.m$variable == "i_lp_ratio"),]

# rename architectures to prettier names for plot
df$variable <- as.character(df$variable)
df$variable[df$variable == "i_ratio"] <- "Intel Baseline"
df$variable[df$variable == "i_l_ratio"] <- "I-LUXOR"
df$variable[df$variable == "i_lp_ratio"] <- "I-LUXOR+"
df$variable <- factor(df$variable, levels=c("Intel Baseline","I-LUXOR","I-LUXOR+"))

pdf("plots/intel_groups_0to4.pdf",width=15,height=6)
p <- ggplot(df,aes(x=labels,y=value)) +
    geom_col(aes(fill=variable),position=position_dodge(width=0.7),width=.7) +
    geom_text(aes(x=c(4),y=c(1.2),label=c("Popcount")),size=6) +
    geom_text(aes(x=c(11),y=c(1.2),label=c("2-Column Popcount")),size=6) +
    geom_text(aes(x=c(17.5),y=c(1.2),label=c("Multi-Operand Addition")),size=6) +
    geom_text(aes(x=c(22.8),y=c(1.2),label=c("FIR-3 and 3-MAC")),size=6) +
    # geom_text(aes(x=c(27.8),y=c(1.2),label=c("XNOR-Popcount")),size=6) +
    geom_text(aes(y=value,label=annotate_stage),size=8,color="red",hjust=-0.5) +
    xlab("Micro-Benchmark") +
    scale_y_continuous("Resource Utilization Ratio",limits=c(0,1.25),breaks=seq(0,1,by=0.1),expand=c(0,0)) +
    theme(axis.title=element_text(),axis.title.y=theme_bw()$axis.title.y) +
	scale_fill_viridis(discrete=TRUE) +
	theme_minimal() +
	theme(
		legend.position="top",
        legend.direction="horizontal",
		#legend.background = element_rect(fill="gray90"),
		legend.title=element_blank(), #element_text(size=24,face="plain"),
		legend.key=element_blank(),
		legend.key.width=unit(1,"cm"),
		legend.key.height=unit(1,"cm"),
		axis.text.x=element_text(size=12,angle=45,hjust=1.0,vjust=1.0),
		axis.text.y=element_text(size=14,angle=0,hjust=1),
		axis.title.x = element_text(size=16,angle=0,hjust=.5,vjust=0,face="plain"),
        axis.title.y = element_text(size=16,hjust=.5,vjust=.5,face="plain"),
        #axis.line = element_line(colour = "black"),
        panel.border = element_blank(), # element_rect(colour = "black", fill=NA, size=1),
        # panel.border=element_blank(),
        axis.line=element_line(),
        axis.line.x=element_blank(),
        strip.text.x = element_text(size = 20,face="bold"),
		legend.text=element_text(size=16)) +
	guides(
		color=guide_legend(ncol=3,nrow=1)
	) +
	theme(axis.line = element_line(color = 'black'))

p
grid.locator(unit="native")
bottom_y <- 330
grid.brackets(57, bottom_y, 325, bottom_y, lwd=2, col="black")
grid.brackets(340, bottom_y, 610, bottom_y, lwd=2, col="black")
grid.brackets(628, bottom_y, 855, bottom_y, lwd=2, col="black")
grid.brackets(872, bottom_y, 1060, bottom_y, lwd=2, col="black")
# grid.brackets(905, bottom_y, 1060, bottom_y, lwd=2, col="black")

############# make plot for xilinx/intel for BNNs #################

# subset relevant data
df <- data.m[data.m$test_num > num_all_minus_bnns,]

# rename architectures to prettier names for plot
df$variable <- as.character(df$variable)
df$variable[df$variable == "i_ratio"] <- "Intel"
df$variable[df$variable == "i_l_ratio"] <- "I-LUXOR"
df$variable[df$variable == "i_lp_ratio"] <- "I-LUXOR+"
df$variable[df$variable == "x_ratio"] <- "Xilinx"
df$variable[df$variable == "x_l_ratio"] <- "X-LUXOR"
df$variable[df$variable == "x_lp_ratio"] <- "X-LUXOR+"
df$variable <- factor(df$variable, levels=c("Xilinx","X-LUXOR","X-LUXOR+","Intel","I-LUXOR","I-LUXOR+"))
df$type <- ""
df$type[df$variable == "Xilinx" | df$variable == "X-LUXOR" | df$variable == "X-LUXOR+"] <- "Xilinx"
df$type[df$variable == "Intel" | df$variable == "I-LUXOR" | df$variable == "I-LUXOR+"] <- "Intel"
df$type <- factor(df$type, levels=c("Xilinx","Intel"))

pdf("plots/bnns.pdf",width=9,height=5)
ggplot(df,aes(x=labels,y=value)) +
    geom_col(aes(fill=variable),position=position_dodge(width=0.7),width=.7) +
    geom_text(aes(y=value,label=annotate_stage),size=8,color="red",hjust=-1.0) +
    xlab("Input size") +
    scale_y_continuous("Resource Utilization Ratio",limits=c(0,1),breaks=seq(0,1,by=0.1),expand=c(0,0)) +
    facet_wrap(~type,scales="fixed",ncol=2) +
    theme(axis.title=element_text(),axis.title.y=theme_bw()$axis.title.y) +
	scale_fill_viridis(discrete=TRUE) +
	theme_minimal() +
	theme(
		legend.position="top",
        legend.direction="horizontal",
		#legend.background = element_rect(fill="gray90"),
		legend.title=element_blank(), #element_text(size=24,face="plain"),
		legend.key=element_blank(),
		legend.key.width=unit(.8,"cm"),
		legend.key.height=unit(.8,"cm"),
		axis.text.x=element_text(size=12,angle=45,hjust=1.0,vjust=1.0),
		axis.text.y=element_text(size=14,angle=0,hjust=1),
		axis.title.x = element_text(size=16,angle=0,hjust=.5,vjust=0,face="plain"),
        axis.title.y = element_text(size=16,hjust=.5,vjust=.5,face="plain"),
        #axis.line = element_line(colour = "black"),
        panel.border = element_blank(), # element_rect(colour = "black", fill=NA, size=1),
        # panel.border=element_blank(),
        axis.line=element_line(),
        axis.line.x=element_blank(),
        strip.text.x = element_text(size = 20,face="bold"),
		legend.text=element_text(size=15)) +
	guides(
		color=guide_legend(ncol=6,nrow=1),
		fill=guide_legend(ncol=6,nrow=1)
	) +
	theme(axis.line = element_line(color = 'black'))

