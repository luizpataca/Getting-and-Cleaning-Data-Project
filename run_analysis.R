## Getting and Cleaning Data Course Project

## Student: Luiz Carlos Moutinho Pataca
## e-mai: luiz.pataca@gmail.com

# 0. Load needed libraries
require(dplyr)
require(data.table)
require(knitr)

# 1. Merges the training and the test sets to create one data set.

## 1.1 Load data

subject_train <- read.table(file = "UCI HAR Dataset/train/subject_train.txt")
X_train <- read.table(file = "UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_test <- read.table(file = "UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
features <- read.table("UCI HAR Dataset/features.txt")
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")

## 1.2 Name columns of data

names(subject_train) <- "Subject"
names(subject_test) <- "Subject"
names(X_train) <- features$V2
names(X_test) <- features$V2
names(y_train) <- "Activity"
names(y_test) <- "Activity"

## 1.3 Merge data

allTrain <- cbind(subject_train, y_train, X_train)
allTest <- cbind(subject_test, y_test, X_test)
allData <- rbind(allTrain, allTest)


# 2. Extracts only the measurements on the mean and standard deviation
#    for each measurement.

## 2.1 Find which columns contain mean or std
colMeanStd <- grepl("mean\\(\\)", names(allData)) |
        grepl("std\\(\\)", names(allData))

colMeanStd[1:2] <- TRUE

## 2.2 Remove unused columns and stay with the measurements on mean and std
allData <- allData[, colMeanStd]


# 3. Uses descriptive activity names to name the activities in the data set.

allData$Activity <- as.character(allData$Activity)

for (i in 1:6) {
        allData$Activity[allData$Activity == i] <-
                as.character(activity_labels[i, 2])
}

allData$Activity <- as.factor(allData$Activity)


# 4. Appropriately labels the data set with descriptive variable names.

names(allData) <- gsub("Acc", "Accelerometer", names(allData))
names(allData) <- gsub("Gyro", "Gyroscope", names(allData))
names(allData) <- gsub("BodyBody", "Body", names(allData))
names(allData) <- gsub("Mag", "Magnitude", names(allData))
names(allData) <- gsub("^t", "Time", names(allData))
names(allData) <- gsub("^f", "Frequency", names(allData))
names(allData) <- gsub("tBody", "TimeBody", names(allData))
names(allData) <-
        gsub("-mean()", "Mean", names(allData), ignore.case = TRUE)
names(allData) <-
        gsub("-std()", "STD", names(allData), ignore.case = TRUE)
names(allData) <-
        gsub("-freq()", "Frequency", names(allData), ignore.case = TRUE)
names(allData) <- gsub("angle", "Angle", names(allData))
names(allData) <- gsub("gravity", "Gravity", names(allData))


# 5. From the data set in step 4, creates a second, independent tidy data
#    set with the average of each variable for each activity and each subject.

allData$Subject <- as.factor(allData$Subject)
allData <- data.table(allData)

tidyData <- aggregate(. ~Subject + Activity, allData, mean)
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]
write.table(tidyData, file = "tidydata.txt", row.names = FALSE)

