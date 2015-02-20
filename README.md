# Getting & Cleaning Data Course Project
This README will describe the steps I took to tidy the raw data set. All of these operations are performed in the script named `run_analysis.R`. I will describe these operations using the line numbers of the script.

## Description of the Tidying Process
To describe how the data is tidied, the format of the raw data must be understood. In both the `test/` and `train/` directories, there are three files and a subdirectory. The three files are the `X` data (`X_test.txt`, `X_train.txt`), the `y` (`y_test.txt`, `y_train.txt`) data, and the subject IDs (`subtect_test.txt`, `subject_train.txt`). Each row of these files represents a single observation that correspond to one another.

- a row in the `X` data represents all of the measurements described in the `features.txt` file at one specific time (there are 561 features, and thus 561 numbers per row)
- a row in the `y` data represents the activity that the subject is doing at that specific time, using a number as described in `activity_labels.txt`
- a row in the subject IDs represents the ID number of the subject

As specified in the course project details, we only care about the data points that represent the mean or the standard deviation of the measurements. I decided to include the mean frequency in this set as well, as it is described as the "weighted average of the frequency components" in the `features_info.txt` file. These data points have the suffixes "mean()", "std()" and "meanFreq()". Since these are the only data points we care about, the subdirectories `Intertial Signals/` in the test & train directories are ignored.

These data points then must be extracted from each observation. The numbers associated with the features are the indices of the data points of interest in each row, which allows for easy extraction. We get these indices by using pattern matching in each feature name in the `features.txt`. The `X` data is then read in, ignoring any columns that are not in our vector of indices. This gives us the `X` data we desire. This is performed on both the train and test data.

The `y` data and subject IDs do not require any special operations to extract. Both the train and test data is read in.

For each set of data (`X`, `y`, IDs), the train and test data are merged in that order.

An additional vector, representing the "type" of the subject (train vs. test), is created that corresponds to the subject ID vector. Each element in this new vector represents the type of the subject at the same location in the ID vector.

The subject IDs are put into the column "SubjectID", the subject types are put in the column "SubjectType", the y data is put into the column "Activity", and each point in the x data is put into its appropriately named column - the feature name, with the "()" stripped out. All of these columns are put into a single data frame.

This tidied data frame is the iterated over, by subject ID and activity number. Each pair of possible values is obtained, e.g. ID #1, activity #1, then ID #1, activity #2, etc. until ID #30, activity #6. A subset of the tidied data frame is created using the subject ID and activity number - i.e. the subset contains only the data about a single subject doing a specific activity. Then, each `x` value is averaged along its column (i.e. the mean of each feature is calculated for this subset). This averaged data is now only one row long. These operations are done for all pairs of IDs and activity numbers, and then put into a new data frame.

The column names for the averaged `x` values are changed by appending a "-avg" suffix to each feature name, e.g. "fBodyGyro-std-X" becomes "fBodyGyro-std-X-avg".

The summarized data set is written into a text file called `tidied_data.txt`.

## Description of the Code
### A Brief Overview
Here's a brief summary of what the code does:
- download the ZIP file of the data and unzip it, if it doesn't already exist
- get the indices of the features that represent the mean, standard deviation or mean frequency of the data (these are the only data points we are interested in)
- get the names of the respective features
- get the raw X data, but ignore any column that does not represent the mean or standard deviation
- get the y data and subject IDs
- merge the train data and test data for x, y, subject IDs
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

**Line 61-63** merge (vertically stack) the x data frames into a single data frame (`xData`), remove the "()" substring from each feature name, and then assign the feature names to the column names of this data frame.

**Lines 67** creates a vector of the activity names `activities` by reading in the `activity_labels.txt` file, where the index of each activity corresponds to its number.

**Line 71** creates a vector `subjectTypes` that is the same length as `IDs`, where each element represents the type of the subject corresponds to the IDs vector. 

**Line 74** creates a data frame `tidiedData` with the columns "Subject ID", "Subject Type", "Activity", and the features we are interested in.

#### Summarizing the tidy data
**Lines 83-84** create a vector `IDs` that contain all of the different subject IDs and a vector `ACTIVITY_NUMBERS` that contain all of the different activity numbers. Used for iterating over and subsetting `tidiedData`.

**Line 85** creates a vector of the training IDs but removes duplicates. This is used while iterating over the data to determine if a subject is a "Train" subject or a "Test" subject.

**Line 88** creates an data frame, `outputData`, which we will put the summarized data into.

**Lines 93-106** iterate over the IDs and activity numbers and subsets the features columns from tidied data for each pair of ID and activity number, calling it `subsetData`, which is also a data frame. E.g., for subject #1 while doing the walking activity (1), the raw x data is subsetted (ignoring the other columns).

dplyr's `mutate_each` applies a list of functions to each column of a data frame, so it is used to calculate the mean of each column, and the result is put into `summarizedData`. The mean of each column is actually put into every row of each column, so the `distinct` function collapses the resulting data frame into a single row.

The type of the subject corresponding to the current ID is then determined.  A data frame with the current ID, the type of the current subject, the current activity and then summarized data are then put into a data frame and stacked vertically with `outputData`.

**Line 108** appends "-avg" to each of the feature names and puts these new feature names into a vector `featureNamesAveraged`.

**Line 109** changes the column names of the summarized data set to be "SubjectID", "SubjectType", "Activity", and the feature names with the "-avg" suffix.

**Line 111** writes this new tidied data to a file, `tidied_data.txt`.