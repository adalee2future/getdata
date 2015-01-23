# getdata

### Introduction
This is my project on the course "Getting and Cleaning the data", data can be downloaded from [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip), my code is in run_analysis.R, and my result is in tidy_data.txt.  

### Below is how I clean the data

1. read "features.txt"" using read.table, col.names = c("id", "feature"), assign features to the result, assign X_name = features$feature, I would assign names of X_test and X_train to be X_name later
  
2. read "subject_test.txt" using read.table, col.names = "subject", colClasses = "factor", assign subject_test to the result
3. read "X_test.txt" using read.fwf, col.names = X_name, assign X_test to the result
4. read "y_test.txt" using read.table, col.names = "y", colClasses = "factor", assign y_test to the result
  
5. read "subject_train.txt" using read.table, col.names = "subject", colClasses = "factor", assign subject_train to the result
6. read "X_train.txt" using read.fwf, col.names = X_name, assign X_train to the result (Note that read.fwf allow us to read fixed width format file)
7. read "y_train.txt" using read.table, col.names = "y", colClasses = "factor", assign y_train to the result
  
8. merge subject_test, X_test, y_test, set (set = c("test", "test", ..., "test")) using cbind, assign test to the result
9. merge subject_train, X_train, y_train, set (set = c("train", "train", ..., "train")) using cbind, assign train to the result
10. merge test and train using rbind, assign allData to the result
  
11. extract only the measurements on the mean and standard deviation for each measurement using regular expressions "[M]mean|[Ss]td", assign subData to the result
  
12. using read.table to read "activity_labels.txt", col.names = c("label", "activity""), assign activity_labels to the result, assign activities to activity_labels$activity
13. assign levels(subData) to activities
  
14. change the colname of subData which is "y"" to "activity" since "activity"" is more descriptive
  
15. use sqldf, to get the average of each variable for each activity and each subject, assign tidy_data to the result. (Note that sqldf allow us to treat data.frame like SQL, it's useful if one knows about SQL)
16. use write.table to write out tidy_data, file = "tidy_data.txt", row.names = FALSE
