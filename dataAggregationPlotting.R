###########################
# this script looks at aggregating data by interesting properties and plotting them
##########################
cityTreesDF <- read.delim("cityTreesDF.txt", header=T, sep=";")
required_lib =c("plyr", "knitr", "ggplot2")
install_required_libs()

install_required_libs<-function(){
for(i in 1:length(required_lib)){
    if(required_lib[i] %in% rownames(installed.packages()) == FALSE)
        {install.packages(required_lib[i])}
}
}
library(plyr)
library(ggplot2)
dir.create("Figs")
##################
# what is the distribtuion of height class
##################
png("Figs/heightClassDistribution.png")
p <- ggplot(data=cityTreesDF, 
            aes(x=HEIGHT_RANGE_ID))
p+geom_bar(binwidth=1)
dev.off()

###################
# is diameter assocation with height class?
###################

#drop level 10, because it did not make sense
png("Figs/diameterVSHeightClass.png")
p <- ggplot(data=cityTreesDF, 
            aes(x=reorder(HEIGHT_RANGE_ID, DIAMETER, median, order=TRUE), y=DIAMETER))
p+geom_boxplot()+xlab("HEIGHT RANGE ID") +ylab("diameter of tree at breast height (inches)")+scale_y_continuous(limits = c(0, 100))+theme(axis.text.x = element_text(angle = 90, hjust = 1))
dev.off()

#########################
# what is the average diameter of trees in each area?
#########################
summary(cityTreesDF$DIAMETER)### apparently Diameter is in inches-> 2931 inches = 73meter
#this is kinda rediculous, so order by median instead
cityTreesDF[which.max(cityTreesDF$DIAMETER),]
png("Figs/diameterVSNeighbourhood.png")
p <- ggplot(data=cityTreesDF, 
            aes(x=reorder(NEIGHBOURHOOD_NAME, DIAMETER, median, order=TRUE), y=DIAMETER))
p+geom_boxplot()+xlab("NEIGHBOURHOOD")  +ylab("diameter of tree at breast height (inches)")+scale_y_continuous(limits = c(0, 100))+theme(axis.text.x = element_text(angle = 90, hjust = 1))
dev.off()


#########################
# is there correlation between year planted and diameter?
#########################
#q <- ggplot(data=cityTreesDF,
 #      aes(x=year, y=DIAMETER))
#q+geom_point(alpha=1/2)+scale_y_continuous(limits = c(0, 100))

(planting_pattern <- count(subset(cityTreesDF, month!="NA"), vars=c("month")))
planting_pattern$month <- factor(planting_pattern$month, levels=c(6:12,1:5))

png("Figs/yearlyTreePlanting.png")
m <- ggplot(data=subset(cityTreesDF, month!="NA"),aes(x= month))
m + geom_bar(binwidth=1)+facet_wrap(~year)# every year the time of planting seem very consistent
planting_pattern$month <- (planting_pattern$month)
dev.off()

#################
#let's graph this with a sinusoidal curve fitted by glm
################
png("Figs/cyclicTrendTreePlanting.png")
m <- ggplot(data=planting_pattern,aes(x= month, y=freq, group=1))
m + geom_point(binwidth=1) +stat_smooth(geom="smooth",method="glm", formula=y~sin(2*pi/12*x)+cos(2*pi/12*x))
dev.off()

