######################
# this script loads and cleans the data
######################
install_required_libs<-function(){
for(i in 1:length(required_lib)){
    if(required_lib[i] %in% rownames(installed.packages()) == FALSE)
        {install.packages(required_lib[i])}
}
}
required_lib =c("plyr", "knitr", "ggplot2")
install_required_libs()
library(plyr)

#locate the files, the City of Vancouver provided separate spreadsheets for each of the neighbourhoods
csvdir <- "csv_street_trees"
temp <- paste(csvdir, list.files(csvdir, pattern="*.csv"), sep="/")

#read all csv and join them in one dataframe
#make sure the NA strings are read correctly, with na.strings = c("NA", ""," ")
cityTreesDF <- adply(temp, .margin=1, .fun=function(x){read.csv(x,na.strings=c("NA","", " "))})[,-1]
str(cityTreesDF) #sanity check to make sure everything was imported correctly

#parse date planted to year/month/date, using substr() and adply()
#somehow this is taking a while
cityTreesDF <- cbind(cityTreesDF, 
                     adply(cityTreesDF$DATE_PLANTED,
                           .margin=1,
                           .fun=function(x){c(year=as.numeric(substr(x,1,4)),
                                              month=as.numeric(substr(x,5,6)),
                                              yearmonth=as.numeric(substr(x,1,6)))},
                           .progress="text")[,-1])
##########################
#dropping unuseful factors... and wierd data
##########################
with(cityTreesDF, table(NEIGHBOURHOOD_NAME)) 
#drop the neighborhood with only 1 tree
cityTreesDF <- droplevels(subset(cityTreesDF, NEIGHBOURHOOD_NAME!="CITY WIDE"))
with(cityTreesDF, table(NEIGHBOURHOOD_NAME))

summary(cityTreesDF$DIAMETER)### apparently Diameter is in inches-> 2931 inches = 73meter
#this is kinda rediculous
with(droplevels(subset(cityTreesDF, HEIGHT_RANGE_ID==10)), table(DIAMETER)) 
#the width in this category totally does not make sense... this is likely typo?
#and besides not too many observations in this category
cityTreesDF <- droplevels(subset(cityTreesDF, HEIGHT_RANGE_ID!=10))

###write this merged dataframe
cols.to.save <- c("NEIGHBOURHOOD_NAME", "DIAMETER", "HEIGHT_RANGE_ID", "year","month")
write.table(cityTreesDF[,cols.to.save], "cityTreesDF.txt", quote=F, sep=";")
