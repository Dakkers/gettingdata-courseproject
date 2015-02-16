# Getting & Cleaning Data Course Project
This README will describe the steps I took to tidy the raw data set. All of these operations are performed in the script named `run_analysis.R`. I will describe these operations using the line numbers of the script.

## A General Overview
Here's a brief summary of what the code does:
- downloads the ZIP file of the data and unzips it, if it doesn't already exist
- gets the indices of the features that represent the mean or standard deviation of the data (these are the only data points we are interested in)
- gets the names of the respective features
- gets the raw X data, but ignores any column that does not represent the mean or standard deviation


## Specific Operations
### Getting the data
**Line 2** is changing the working directory. **This must be changed to wherever you cloned the Git repository.**

Lines 5-22 check for the existence of the raw data directory (`UCI HAR Dataset`). If the directory does not exist, it checks to see if the ZIP of the raw data exists (`getdata-projectfiles-UCI HAR Dataset.zip`). If the ZIP does not exist, it downloads from the URL given in the course project description on Coursera. The ZIP file is now guaranteed to exist, so it is extracted.


### Manipulating the data
**Line 27** creates a data frame called `features` of all of the features included in the study. There are two columns to this data frame: `Number`, which is the numbers of the features, and `Name`, which is the names of the features.

**Line 28** creates a vector called `meanIndices` which represent the row numbers that have the string `mean()` in the corresponding feature name. This is done using the `grepl` function, which allows one to check for a substring inside a string, on the `Name` column of the `features` data frame. A Boolean vector is created from this, and is then used to index the `Number` column.

**Line 29** does what Line 28 did, but for the string `std()` for a vector called `stdIndices`.

**Line 31** defines an integer value, `numFeatures`, which is simply the number of features for our data set (561).

**Line 34** combines `meanIndices` and `stdIndices` together and then sorts them, putting them into a vector called `featureIndices`. This gives us all of the indices of the data points we are interested in (`mean()` and `std()` data points).

**Line 37** gets the names of the features that we are interested in and puts them into a vector (`featureNames`).

**Lines 41-42** create a vector (`columnNumbers`) of column numbers to extract from the X data set. The only columns we should extract are the ones that have the data points that we are interested in, which correspond to `featureIndices`. To specify the columns to extract, we specify `"NULL"` for columns we do not need, and `"numeric"` for columns we do need. This vector is passed as the `colClasses` parameter in the `read.table` function.

**Line 47** creates a data frame (`xDataTrain`) that is a subset of the raw X data for the training subjects. We ignore the columns we do not need.

**Line 48** is the same as Line 47, but for the test subjects (`xDataTest`).

**Lines 51-52** put the y data for the training subjects and the test subjects into vectors (`yDataTrain` and `yDataTest`, respectively).

**Lines 55-56** put the subject IDs for the training subjects and test subjects into vectors (`idsTrain` and `idsTest`, respectively).

**Line 59** merges the two y-data vectors into a single vector (`yData`).

**Line 60** merges the two ID vectors into a single vector (`IDs`).

**Line 61-62** merge (vertically stack) the x data frames into a single data frame (`xData`) and then assign the column names of this data frame to be the feature names.

**Lines 66-67** create a vector of the activity names (`activities`) by reading in the `activity_labels.txt` file, where the index of each activity corresponds to its number. A new vector (`y`) is then created, consisting of the activities instead of their numbers.