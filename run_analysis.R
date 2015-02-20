# set your own working directory, of course!
setwd("/home/stdako/pro/r/coursera/getting-data/proj")

# check to see if the UCI HAR Dataset directory exists.
if (!file.exists("UCI HAR Dataset")) {
  # the directory does not exist.
  print("UCI HAR Dataset directory doesn't exist. Checking to see if the ZIP file exists...")
  
  # now check to see if the ZIP file of the data exists.
  if (!file.exists("getdata-projectfiles-UCI HAR Dataset.zip")) {
    # the ZIP file does not exist. download it.
    print("ZIP file doesn't exist, attemping to download it...")
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                  destfile="getdata-projectfiles-UCI HAR Dataset.zip", method="curl")
    print("ZIP file downloaded.")
  }
  
  # ZIP file is now guaranteed to exist. extract it.
  print("Extracting ZIP file...")
  unzip("getdata-projectfiles-UCI HAR Dataset.zip")
  print("ZIP file extracted.")
}

# Get the list of features from 'features.txt', get the row numbers that have 
# 'mean()' or 'meanFreq()' in the name and put those into a vector; do this again 
# but for 'std()' - these are the data points we want from the data files
features <- read.table("./UCI HAR Dataset/features.txt", sep=" ", col.names=c("Number", "Name"))
meanIndices <- features$Number[ grepl("mean()", features$Name, fixed=TRUE) | grepl("meanFreq()", features$Name, fixed=TRUE) ]
stdIndices  <- features$Number[ grepl("std()",  features$Name, fixed=TRUE) ]

numFeatures <- length(features$Name)  # total number of features

# Combine these indices
featureIndices <- sort(c(meanIndices, stdIndices))

# Similarly, grab the feature names themselves (for 'mean()' and 'std()')
featureNames <- features$Name[featureIndices]

# Create a vector to extract only specific columns of the data
# we only care about the column numbers that are given by featureIndices
columnNumbers = rep("NULL", each=numFeatures)
columnNumbers[featureIndices] = "numeric"

# put the X data into a data frame, where each row is a feature vector, as 
# described in the dataset's 'README.txt' file, but only get the points 
# that we care about.
xDataTrain <- read.table("./UCI HAR Dataset/train/X_train.txt", colClasses=columnNumbers)
xDataTest  <- read.table("./UCI HAR Dataset/test/X_test.txt",   colClasses=columnNumbers)

# put y data into vectors
yDataTrain <- scan("./UCI HAR Dataset/train/y_train.txt",)
yDataTest  <- scan("./UCI HAR Dataset/test/y_test.txt",  )

# put subject IDs into vectors
idsTrain <- scan("./UCI HAR Dataset/train/subject_train.txt",)
idsTest  <- scan("./UCI HAR Dataset/test/subject_test.txt",  )

# begin to merge components of the data...
y   <- c(yDataTrain, yDataTest)
ids <- c(idsTrain, idsTest)
x   <- rbind(xDataTrain, xDataTest)
colnames(x) <- gsub("()", "", featureNames, fixed=TRUE)

# create a vector of activity names so that the y-column in the tidied 
# data frame is the activity names instead of their corresponding numbers
activities <- read.table("./UCI HAR Dataset/activity_labels.txt")$V2


# create a vector that represents the 'type' of the subject (i.e. test 
# vs. train)
subjectTypes = c(rep("TRAIN", length(idsTrain)), rep("TEST", length(idsTest)))

# combine the subject IDs, subject types, activities and raw data!
tidiedData <- data.frame(SubjectID=ids, SubjectType=subjectTypes, Activity=y, x)


# SUMMARIZING TIDIED DATA SET =====================
# dplyr comes in handy for mutating subsets
library(dplyr)

# define some constant vectors that will be useful for summarizing data
# we'll use these to loop over the data frame
IDS <- sort(unique(ids))
ACTIVITY_NUMBERS <- 1:length(activities)

# create the resultant data frame that we want
outputData <- data.frame()

# loop over each of the IDs and activity numbers to extract those chunks 
# from the tidied data set, sum up all of the rows for each feature, and 
# put it in the resultant data frame.
for (id in IDS) {
  for (a_num in ACTIVITY_NUMBERS) {
    subsetData <- select( filter(tidiedData, Activity == a_num & SubjectID == id), -(SubjectID:Activity) )
    summarizedData <- distinct(mutate_each(subsetData, funs(mean)))
    
    # get the type for this subject by checking to see if this ID is in 
    # the vector of training IDs or not
    subjectType <- if (is.element(id, idsTrain)) "TRAIN" else "TEST"
    
    outputData <- rbind(outputData, 
                  data.frame(SubjectID=id, SubjectType=subjectType, 
                             Activity=activities[a_num], summarizedData) )
  }
}

write.table(outputData, "tidied_data.txt", row.name=FALSE)