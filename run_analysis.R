# read features.txt, get all features
features <- read.table("UCI HAR Dataset/features.txt", sep = " ", col.names = c("id", "feature"), stringsAsFactors = FALSE)
X_names <- features$feature
# read test data
## read subject
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject", nrows = 302)
## read X using fwf(fixed width format files), for every col, all 561 values have
## 16 width,no separation, so sep = "", file has size 26.2 Mb, so need some time to read all.
### read first line of X_test.txt and get length of the first line, divided by 16
### will get ncol, that is how many colomns in a row
firstLine = readLines(con = "UCI HAR Dataset/test/X_test.txt", n = 1)
ncol = nchar(firstLine) / 16  # ncol is 561
X_test <- read.fwf("UCI HAR Dataset/test/X_test.txt", widths = rep(16, ncol), sep = "", n = 302, col.names = X_names)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "y", nrows = 302)

# read train data
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject", nrows = 347)
## read X using fwf(fixed width format files), for every col, all 561 values have
## 16 width,no separation, so sep = "", file has size 26.2 Mb, so need some time to read all.
### read first line of X_test.txt and get length of the first line, divided by 16
### will get ncol, that is how many colomns in a row
firstLine = readLines(con = "UCI HAR Dataset/train/X_train.txt", n = 1)
ncol = nchar(firstLine) / 16  # ncol is 561
X_train = read.fwf("UCI HAR Dataset/train/X_train.txt", widths = rep(16, ncol), sep = "", n = 347, col.names = X_names)
y_train = read.table("UCI HAR Dataset/train/y_train.txt", col.names = "y", nrows = 347)


# 1. Merges the training and the test sets to create one data set
test <- cbind(X_test, subject_test, y_test, set = rep("test", 1))
train <- cbind(X_train, subject_train, y_train, set = rep("train", 1))
allData <- rbind(test, train)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement
mean_or_std_index <- grep("[Mm]ean|[Ss]td", names(allData))
subData <- subset(allData, select = c(mean_or_std_index, 562, 563, 564))

# 3. Uses descriptive activity names to name the activities in the data set
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", sep = " ", stringsAsFactors = FALSE, col.names = c("label", "activity"))
activities <- activity_labels$activity

subData$y <- as.factor(subData$y)
levels(subData$y) <- activities

# 4. Appropriately labels the data set with descriptive variable names. 
## change label "subject" to "person" to make subData more descriptive
names(subData)[names(subData) == "subject"] <- "person"
## change label "y" to "activity" to make subData more descriptive
names(subData)[names(subData) == "y"] <- "activity"

# 5. From the data set in step 4, creates a second, independent tidy data
# set with the average of each variable for each activity and each subject.

