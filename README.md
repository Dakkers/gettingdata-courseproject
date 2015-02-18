# Getting & Cleaning Data Course Project
This README will describe the steps I took to tidy the raw data set. All of these operations are performed in the script named `run_analysis.R`. I will describe these operations using the line numbers of the script.

## Description of the Tidying Process


## Description of the Code
### A Brief Overview
Here's a brief summary of what the code does:
- download the ZIP file of the data and unzip it, if it doesn't already exist
- get the indices of the features that represent the mean or standard deviation of the data (these are the only data points we are interested in)
- get the names of the respective features
- get the raw X data, but ignore any column that does not represent the mean or standard deviation
- get the y data and subject IDs
- merge the train data and test data for x, y, subject IDs
- change the y data from activity numbers to activity labels
- create vector of subject types
- put subject IDs, subject types, y data and x data into a data frame
- subset x data by ID and activity number and take the average of each kind of observation
- put the averaged data into a new data frame and the writes it to the file `tidied_data.txt`

### Specific Operations
#### Getting the data
**Line 2** changes the working directory. **This must be changed to wherever you cloned the Git repository.**

Lines 5-22 check for the existence of the raw data directory (`UCI HAR Dataset`). If the directory does not exist, it checks to see if the ZIP of the raw data exists (`getdata-projectfiles-UCI HAR Dataset.zip`). If the ZIP does not exist, it downloads from the URL given in the course project description on Coursera. The ZIP file is now guaranteed to exist, so it is extracted.


#### Tidying the raw data
**Line 27** creates a data frame called `features` of all of the features included in the study. There are two columns to this data frame: `Number`, which is the numbers of the features, and `Name`, which is the names of the features.

**Line 28** creates a vector called `meanIndices` which represent the row numbers that have the string `mean()` in the corresponding feature name. This is done using the `grepl` function, which allows one to check for a substring inside a string, on the `Name` column of the `features` data frame. A Boolean vector is created from this, and is then used to index the `Number` column.

**Line 29** does what Line 28 did, but for the string `std()` for a vector called `stdIndices`.

**Line 31** defines an integer value, `numFeatures`, which is simply the number of features for our data set (561).

**Line 34** combines `meanIndices` and `stdIndices` together and then sorts them, putting them into a vector called `featureIndices`. This gives us all of the indices of the data points we are interested in (`mean()` and `std()` data points).

**Line 37** gets the names of the features that we are interested in and puts them into a vector `featureNames`.

**Lines 41-42** create a vector `columnNumbers` of column numbers to extract from the X data set. The only columns we should extract are the ones that have the data points that we are interested in, which correspond to `featureIndices`. To specify the columns to extract, we specify `"NULL"` for columns we do not need, and `"numeric"` for columns we do need. This vector is passed as the `colClasses` parameter in the `read.table` function.

**Line 47** creates a data frame `xDataTrain` that is a subset of the raw X data for the training subjects. We ignore the columns we do not need.

**Line 48** is the same as Line 47, but for the test subjects `xDataTest`.

**Lines 51-52** put the y data for the training subjects and the test subjects into vectors (`yDataTrain` and `yDataTest`, respectively).

**Lines 55-56** put the subject IDs for the training subjects and test subjects into vectors (`idsTrain` and `idsTest`, respectively).

**Line 59** merges the two y-data vectors into a single vector `yData`.

**Line 60** merges the two ID vectors into a single vector `IDs`.

**Line 61-62** merge (vertically stack) the x data frames into a single data frame (`xData`) and then assign the column names of this data frame to be the feature names.

**Lines 66-67** create a vector of the activity names `activities` by reading in the `activity_labels.txt` file, where the index of each activity corresponds to its number. A new vector (`y`) is then created, consisting of the activities instead of their numbers.

**Line 71** creates a vector `subjectTypes` that is the same length as `IDs`, where each element represents the type of the subject corresponds to the IDs vector. 

**Line 74** creates a data frame `tidiedData` with the columns "Subject ID", "Subject Type", "Activity", and the features we are interested in.

#### Summarizing the tidy data
**Lines 83-84** create a vector `IDs` that contain all of the different subject IDs and a vector `ACTIVITY_NUMBERS` that contain all of the different activity numbers. Used for iterating over and subsetting `tidiedData`.

**Line 87** creates an data frame, `outputData`, which we will put the summarized data into.

**Lines 92-105** iterate over the IDs and activity numbers and subsets the features columns from tidied data for each pair of ID and activity number, calling it `subsetData`, which is also a data frame. E.g., for subject #1 while doing the walking activity (1), the raw x data is subsetted (ignoring the other columns).

dplyr's `mutate_each` applies a list of functions to each column of a data frame, so it is used to calculate the mean of each column, and the result is put into `summarizedData`. The mean of each column is actually put into every row of each column, so the `distinct` function collapses the resulting data frame into a single row.

The type of the subject corresponding to the current ID is then determined.  A data frame with the current ID, the type of the current subject, the current activity and then summarized data are then put into a data frame and stacked vertically with `outputData`. 