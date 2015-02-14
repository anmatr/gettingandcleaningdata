# Human Activity Recognition
## Coursera - Getting And Cleaning Data - Course Project

### The Course Project Assignment
You should create one R script called run_analysis.R that does the following.

  - Merges the training and the test sets to create one data set.
  - Extracts only the measurements on the mean and standard deviation for each measurement.
  - Uses descriptive activity names to name the activities in the data set
  - Appropriately labels the data set with descriptive activity names.
  - Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### Steps to consider before running the script 'run_analysis.R'
The script will by default NOT download the data set from https://d396qusza40orc.cloudfront.net, as this could cause issues on different operating systems. If the script is run with command line argument TRUE
`run_analysis.R TRUE`
then the source data is downloaded.
Then the data is unzipped into the current directory and then finally produces the tidy data set in a file called `tidy.txt`.
The file will also be created in the currenct directory.

To successfully download the file, internet access need to be given; please check firewall access.

Please keep in mind this code has only been tested on a Windows environment, code might need to be changed to allow downloading the files on another operating system.

In case the data could not be downloaded by the script follow this 'Plan B' approach:

  - download the data from this location: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
  - call the script from rscript with `run_analysis FALSE`
  - call the script from RStudio with `system("rscript run_analysis.R FALSE")` or `system("rscript run_analysis.R TRUE")`
  - call the script from RStudio with `source("run_analysis.R")`; when calling this way no argument can be passed and it always will NOT download the sources.

### Dependencies
Libraries which should be installed are:

  - plyr
  - LaF
  - reshape2
