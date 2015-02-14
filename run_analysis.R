#
# Human Activity Recognition
# Coursera - Getting And Cleaning Data - Course Project 
#
# Below are the steps and commands to analyse the data on human activity recognition.
# The output generated will be a table in text format showing tidy data for later analysis.
# The steps in overview:
# - The required data set is downloaded and unzipped in current working directory.
# - A test data set is loaded (only mean and standard deviation observations).
# - A training data set is loaded (only mean and standard deviation observations).
# - Test and training data sets are merged.
# - Descriptive names are applied during that load process.
# - A tidy data set is created showing the average of each variable for each activity and subject.
# - This tidy data set is then saved in a file 'tidy.txt' in the current working directory
# 
# Required data: data is downloaded from https://d396qusza40orc.cloudfront.net, so network access is required
# Required (dependent) packages: plyr, LaF, reshape2
#
# Please keep in mind this code has only been tested on a Windows environment, downloading files might need
# to be changed on an other operating system.

library(plyr)
library(LaF)
library(reshape2)

# define helper functions
# returns string w/o leading or trailing white space
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

# loads the core data for a given data set name (avoiding boilerplate code or duplication)
# input: name of the data set; important, the directory structure and file names need to follow the same pattern
load_data <- function(directory, datasetname) {
  # get the file names for subject, data set X (measure per observation), data set Y (activity per observation) and activity labels
  fSubject = paste(directory, "/", datasetname, "/subject_", datasetname, ".txt", sep="")
  fDataX = paste(directory, "/", datasetname, "/X_", datasetname, ".txt", sep="")
  fDataY = paste(directory, "/", datasetname, "/y_", datasetname, ".txt", sep="")
  fActivity = paste(directory, "/activity_labels.txt", sep="")
  
  # load the subject data; there is no header provided
  subject <- read.csv(fSubject, header=F)
  # rename the column to 'subject'
  subject <- rename(subject, replace=c("V1" = "subject"))

  # find out the number of lines to read
  nlines <- determine_nlines(fSubject)
  # open a connection to the source file; all columns are numeric with fixed with of 16 using the columns names prepared above
  con <- laf_open_fwf(fDataX, column_types=rep("numeric",cols), column_widths=rep(16,cols), column_names=colnames)
  # read the full file in one call
  data <- next_block(con, nrows=nlines)
  # close the connection
  close(con)

  # read all the test labels and rename it to activity_id for later merge (each observation has a label, which defines the activity)
  act_data <- read.csv(fDataY,header=F,col.names=c("activity_id"))
  # read the activity labels and trim the white space; rename the headers for later merge
  act_labels <- read.fwf(fActivity,widths=c(1,80),header=F,col.names=c("activity_id","activity"))
  act_labels$activity <- trim(act_labels$activity)
  # merge the activity with the activity name for each observation
  act_labels <- merge(act_labels, act_data)

  # now combine the test data into a data frame which looks like:
  # activity_id, activity, subject, measure1, measure2, measure3, ..., measureN
  result <- data.frame(act_labels, subject, data)
  # return the data
  result
}


# data source location
zipF <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# as the URL is https this setting has to be enabled to allow downloading of files
setInternet2(TRUE)
# download zip file in binary format
download.file(zipF, destfile="getdata_projectfiles_UCI_HAR_Dataset.zip", mode="wb")
# unzip data file
unzip("getdata_projectfiles_UCI_HAR_Dataset.zip")

# load the features file without header; this will be the source for the column names
feat <- read.csv("UCI HAR Dataset/features.txt", sep=" ",header=F)
# change column names to be R standard; replace dash '-' with underscore '_', remove brackets '()'
feat <- as.data.frame(sapply(feat,gsub,pattern="-",replacement="_"))
feat <- as.data.frame(sapply(feat,gsub,pattern="()",replacement="",fixed=T))
# only columns with mean and std in the name are used; transpose the vertical list into a horizontal vector
colnames <- as.vector(t(feat[feat$V1 %in% grep("mean|std", feat$V2),2]))
# determine number of columns
cols <- length(colnames)

# the source directory
dir <- "UCI HAR Dataset"
# load the data for data set 'train' and data set 'test' and combine the rows into one data frame
total <- rbind(load_data(dir, "train"),load_data(dir, "test"))

# flatten the data on id's activity and subject to allow easy application of function
tidy <- melt(total, id=c("activity", "subject"), measure.vars=colnames)
# calculate average of each variable for each activity and each subject
tidy <- ddply(tidy, c("activity", "subject", "variable"), fun=mean)
# save data in a text file 'tidy.txt'
write.table(x = tidy, file = "tidy.txt", row.name=F)
print (paste("Text file 'tidy.txt' written in directory", getwd()))
