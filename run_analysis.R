
# returns string w/o leading whitespace
trim.leading <- function (x)  sub("^\\s+", "", x)

# returns string w/o trailing whitespace
trim.trailing <- function (x) sub("\\s+$", "", x)

# returns string w/o leading or trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

rm(list=ls())
library(dplyr)
#setwd("D:/_Project_DataScientist/03 - Getting and Cleaning Data/Course Project")
zipF <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(zipF, destfile="getdata_projectfiles_UCI_HAR_Dataset.zip", mode="wb")
unzip("getdata_projectfiles_UCI_HAR_Dataset.zip")

s_test <- read.csv("UCI HAR Dataset/test/subject_test.txt",header=F)
s_test <- rename(s_test, subject = V1)
#s_test <- rename(s_test, replace=c("V1" = "subject"))

feat <- read.csv("UCI HAR Dataset/features.txt", sep=" ",header=F)
feat <- as.data.frame(sapply(feat,gsub,pattern="-",replacement="_"))
feat <- as.data.frame(sapply(feat,gsub,pattern="()",replacement="",fixed=T))
# only columns with -mean() in the name are used as the others is as I understand it an angle between X and the gravityMean)
colnames <- paste("V", grep("mean|std", feat$V2), sep="")    # old version
colnames <- as.vector(t(feat[feat$V1 %in% grep("mean|std", feat$V2),2]))
cols <- length(colnames)
# read the text data set
con <- laf_open_fwf("UCI HAR Dataset/test/X_test.txt", column_types=rep("numeric",cols), column_widths=rep(16,cols), column_names=colnames)
t_test <- next_block(con, nrows=3000)
close(con)

a_test <- read.csv("UCI HAR Dataset/test/y_test.txt",header=F,col.names=c("activity_id"))
act_test <- read.fwf("UCI HAR Dataset/activity_labels.txt",widths=c(1,80),header=F,col.names=c("activity_id","activity"))
act_test$activity <- trim(act_test$activity)
act_test <- merge(act_test, a_test)

test <- data.frame(act_test,s_test, t_test)

s_train <- read.csv("UCI HAR Dataset/train/subject_train.txt", header=F)
s_train <- rename(s_train, subject = V1)
#s_train <- rename(s_train, replace=c("V1" = "subject"))

con <- laf_open_fwf("UCI HAR Dataset/train/X_train.txt", column_types=rep("numeric",cols), column_widths=rep(16,cols), column_names=colnames)
t_train <- next_block(con, nrows=8000)
close(con)

a_train <- read.csv("UCI HAR Dataset/train/y_train.txt",header=F,col.names=c("activity_id"))
act_train <- read.fwf("UCI HAR Dataset/activity_labels.txt",widths=c(1,80),header=F,col.names=c("activity_id","activity"))
act_train$activity <- trim(act_train$activity)
act_train <- merge(act_train, a_train)

train <- data.frame(act_train,s_train, t_train)

total <- rbind(train,test)

orig <- melt(total, id=c("activity", "subject"), measure.vars=colnames)
tidy <- ddply(orig, c("activity", "subject", "variable"), fun=mean)
write.table(x = tidy, file = "tidy.txt", row.name=F)

