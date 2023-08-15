# run_analysis.R
# This is the programming file for Getting and Cleaning Data Course Project

## install.packages("reshape2")
library(reshape2)

#Get dataset from web
rawdataDir <- "./rawdata"
rawdataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rawdataFilename <- "rawdata.zip"
rawdataDFn <- paste(rawdataDir, "/", "rawdata.zip", sep = "")
datadir <- "./data"

if (!file.exists(rawdataDir)) {
  dir.create(rawdataDir)
  download.file(url = rawdataUrl, destfile = rawdataDFn)
}
if (!file.exists(datadir)) {
  dir.create(datadir)
  unzip(zipfile = rawdataDFn, exdir = datadir)
}


#1. Merges the training and the test sets to create one data set.
# refer: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

# train data
x_train <- read.table(paste(sep = "", datadir, "/UCI HAR Dataset/train/X_train.txt"))
# 7352 obs of 561 variables
y_train <- read.table(paste(sep = "", datadir, "/UCI HAR Dataset/train/Y_train.txt"))
# 7352 obs of 1 variables
s_train <- read.table(paste(sep = "", datadir, "/UCI HAR Dataset/train/subject_train.txt"))

# test data
x_test <- read.table(paste(sep = "", datadir, "/UCI HAR Dataset/test/X_test.txt"))
y_test <- read.table(paste(sep = "", datadir, "/UCI HAR Dataset/test/Y_test.txt"))
s_test <- read.table(paste(sep = "", datadir, "/UCI HAR Dataset/test/subject_test.txt"))

# merge
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(s_train, s_test)

#2. Extract data by cols & using descriptive name

#fisrtly load feature & activity info for the V1-561 and measurments accordingly 
feature <- read.table(paste(sep = "", datadir, "/UCI HAR Dataset/features.txt"))

# Read in activity labels
# 1 WALKING
# 2 WALKING_UPSTAIRS
# 3 WALKING_DOWNSTAIRS
# 4 SITTING
# 5 STANDING
# 6 LAYING

a_label <- read.table(paste(sep = "", datadir, "/UCI HAR Dataset/activity_labels.txt"))
a_label[,2] <- as.character(a_label[,2])

# extract feature cols & names named 'mean, std'
selectedCols <- grep("-(mean|std).*", as.character(feature[,2]))
selectedColNames <- feature[selectedCols, 2]
selectedColNames <- gsub("-mean", "Mean", selectedColNames)
selectedColNames <- gsub("-std", "Std", selectedColNames)
selectedColNames <- gsub("[-()]", "", selectedColNames)
# extract data
x_data <- x_data[selectedCols]
data_c <- cbind(s_data, y_data, x_data)


#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names.
colnames(data_c) <- c("Subject", "Activity", selectedColNames)
data_c$Activity <- factor(data_c$Activity, levels = a_label[,1], labels = a_label[,2])
data_c$Subject <- as.factor(data_c$Subject)


#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
data_melt<- melt(data_c, id = c("Subject", "Activity"))
#Subject-level tidy dataset
data_tidy <- dcast(data_melt, Subject + Activity ~ variable, mean)

write.table(data_tidy, "./FinalTidyData.txt", row.names = FALSE, quote = FALSE)
