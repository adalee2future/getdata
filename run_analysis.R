# read features.txt, get all features
features <- read.table("UCI HAR Dataset/features.txt", sep = " ", col.names = c("id", "feature"))
X_names <- features$feature
# read test data
## read subject
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject", colClasses = "factor")

### read first line of X_test.txt and get length of the first line, divided by 16
### will get ncol, that is how many colomns in a row
firstLine = readLines(con = "UCI HAR Dataset/test/X_test.txt", n = 1)
ncol = nchar(firstLine) / 16  # ncol is 561
## read X using fwf(fixed width format files), for every col, all 561 values have
## 16 width,no separation, so sep = "", file has size 26.2 Mb, so need some time to read all.
X_test <- read.fwf("UCI HAR Dataset/test/X_test.txt", widths = rep(16, ncol), sep = "", col.names = X_names)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "y", colClasses = "factor")

# read train data
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject", colClasses = "factor")

### read first line of X_test.txt and get length of the first line, divided by 16
### will get ncol, that is how many colomns in a row
firstLine = readLines(con = "UCI HAR Dataset/train/X_train.txt", n = 1)
ncol = nchar(firstLine) / 16  # ncol is 561
## read X using fwf(fixed width format files), for every col, all 561 values have
## 16 width,no separation, so sep = "", file has size 26.2 Mb, so need some time to read all.
X_train = read.fwf("UCI HAR Dataset/train/X_train.txt", widths = rep(16, ncol), sep = "", col.names = X_names)
y_train = read.table("UCI HAR Dataset/train/y_train.txt", col.names = "y", colClasses = "factor")


# 1. Merges the training and the test sets to create one data set
## set is not needed in this assignment, but I would rather construct it, which help us know
## if the data come from test set or train set
## construct test using cbind
test <- cbind(set = rep("test", length(y_test$y)), subject_test, y_test, X_test)
## construct train using cbind
train <- cbind(set = rep("train", length(y_train$y)), subject_train, y_train, X_train)
## combine test and train sets
allData <- rbind(test, train)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement
mean_or_std_index <- grep("[Mm]ean|[Ss]td", names(allData))
subData <- subset(allData, select = c(1, 2, 3, mean_or_std_index)) ## set, subject, and y are needed, too

# 3. Uses descriptive activity names to name the activities in the data set
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", sep = " ", 
                              col.names = c("label", "activity"), stringsAsFactors = TRUE)
activities <- activity_labels$activity  ## WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS SITTING, STANDING, LAYING
## change 1,2,3,4,5 to WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS SITTING, STANDING, LAYING,
## which would make activity more descriptive
levels(subData$y) <- activities   

# 4. Appropriately labels the data set with descriptive variable names. 
## change label "y" to "activity" to make subData more descriptive, others like subject are already descriptive
names(subData)[names(subData) == "y"] <- "activity"

# 5. From the data set in step 4, creates a second, independent tidy data
# set with the average of each variable for each activity and each subject.
## I would use sqldf package, which allow us to treat data.frame like SQL,
## since there are too many dots (like tBodyAcc.mean...X) in the colnames of subData 
## and SQL does not support them as colnames, so I would change the name of temp to v1, v2, ..., v86
library(sqldf)  ## if not installed, install it
temp <- subData
ncol <- length(subData) ## 89
some_colnames <- paste("v", as.character(1: (ncol - 3)), sep = "") ## of course set, subject, activity do not need to change
names(temp)[4: ncol] <- some_colnames

## construct SQL commnand
format_avg <- function(colname) {paste(",avg(", colname, ")", sep = "")}  ## ",avg(colname)"
avgs <- sapply(some_colnames, format_avg)  ## ",avg(v1)" ",avg(v2)", ..., ",avg(v86)"
## "select avg(v1), avg(v2), ..., avg(v86) from temp group by subject, activity"
SQL <- paste("select subject, activity", paste(avgs, collapse = ""), "from temp group by subject, activity")
## run SQL
tidy_data <- sqldf(SQL)
## change name to make it maore expressive
names(tidy_data) <- names(subData)[2:ncol]  ## "set" not included


