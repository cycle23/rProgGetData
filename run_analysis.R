## run_analysis provides functions to analyze wearable computing data
## gathered from a smartphone

## Submitted for Getting and Cleaning Data Course Project

## Assignment description: 
##   https://class.coursera.org/getdata-030/human_grading/view/courses/975114/assessments/3/submissions

## Direct data link:
##   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

## Data source: 
##   http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

## See README.md and CodeBook.md for more details.

library(plyr)
library(dplyr)


## readDataTable: Reads one of the datatables from file as indicated in the string parameter
readDataTable <- function(setLabel,featCols) {
  setTable <- read.table(paste("UCI HAR Dataset/",setLabel,"/X_",setLabel,".txt",sep=""),col.names=featCols)
  setTable$subject <- readLines(paste("UCI HAR Dataset/",setLabel,"/subject_",setLabel,".txt",sep=""))
  setTable$activity <- readLines(paste("UCI HAR Dataset/",setLabel,"/y_",setLabel,".txt",sep=""))
  setTable
}

## summarizeData will load all data and generate the output tidy data set
## Must be executed in a directory containing the subfolder "UCI HAR Dataset", as delivered from the link above.
## Will write the output file "wearable_tidy.txt"
summarizeData <- function() {
  # Read in our feature column labels
  featCols <- read.table("UCI HAR Dataset/features.txt")
  
  # Read in our activities label strings
  activities <- read.table("UCI HAR Dataset/activity_labels.txt")
  
  ## read the test and train data tables along with their subject and activity values  
  testTable <- readDataTable("test",featCols$V2)
  trainTable <- readDataTable("train",featCols$V2)
  
  ## vertically merge the two tables, as we are ensured no overlap on the data
  mergedData <- rbind(testTable,trainTable)

  ## Select the 'means()' and 'std()' columns out of the 561 features
  ## columns 562 and 563 are the subject and activity columns
  extractedData <- mergedData[,c(grep("(std|mean)\\(",as.character(featCols$V2)),562,563)]

  # Assign this label to all of the activities as factors
  labeledData <- mutate(extractedData,activity=factor(as.numeric(activity),labels=activities$V2))
  
  # Group the data by subject and activity
  groupedData <- group_by(labeledData, subject, activity)
  
  # Summarize by the means of each of the selected columns per the above groups
  tidyData <- summarise_each(groupedData,funs(mean))
  
  # Write out the results to the current folder
  write.table(tidyData, "wearable_tidy.txt",row.name=FALSE)
}
