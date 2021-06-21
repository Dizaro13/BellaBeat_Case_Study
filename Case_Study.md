# BellaBeat Case Study
### Donovan Parsons - 6/20/2021
## Introduction
***BellaBeat*** Urška Sršen and Sando Mur founded Bellabeat, a high-tech company that manufactures health-focused smart products for women.
Collecting data on activity, sleep, stress and reproductive health has allowed BellaBeat to create products that help women be more knowledgable
about their health and habits.

## Table of contents
- [Ask](#ask)
- [Prepare](#prepare)
- [Process](#process)


## Ask
#### Approach
This case study is about gaining insight from 30 Fitbit users, who's data has been collected over the period of 30 days. Some of the data that was
collected includes time active, time asleep, weight, calorie intake, distance travelled, and total steps. I decided early on to not use some metrics
that didn't have enough data to form any reasonable analysis from. Instead of using per minute or per hour data metrics I decided to look at daily
metrics and look at the overall 30 day time period to better focus on trends for my analysis. During this analysis I wasn't able to use Excel or SQL because
of the large amount of data needed to clean and analyze, so I used R for my analysis. Some of the questions I wanted to answer are

- How do people spend their time exercising?
- How could this data apply to Bellabeat customers?
- Are people using the full capabilities of their smart devices?

## Prepare
The dataset I used the [FitBit Fitness Tracker Dataset](https://www.kaggle.com/arashnic/fitbit) found on [Kaggle.com](https://www.kaggle.com). There are 18 different csv files for
each of the different metrics. Some include merged data from others, and since I've already decided to only include daily tables I only loaded those into R.

`install.packages("tidyverse")`

`install.packages("dplyr") `

`install.packages("ggplot2")`

`install.packages("lubridate")`

`library(tidyverse)`

`library(dplyr)`

`library(ggplot2)`

`library(lubridate)`

`daily_activity <- read.csv("C:/Users/Dizaro/Documents/R/R Coding/archive/Fitabase Data 4.12.16-5.12.16/dailyActivity_merged.csv")`
`daily_sleep <- read.csv("C:/Users/Dizaro/Documents/R/R Coding/archive/Fitabase Data 4.12.16-5.12.16/sleepDay_merged.csv")`
`daily_weight <- read.csv("C:/Users/Dizaro/Documents/R/R Coding/archive/Fitabase Data 4.12.16-5.12.16/weightLogInfo_merged.csv")`

After importing the data tables I wanted to check each one for their metrics and the data types I'll be working with

`str(daily_activity)`

`str(daily_sleep)`

`str(daily_weight)`

![Str Data](https://user-images.githubusercontent.com/86019532/122690714-1b4c9e00-d1f9-11eb-8591-4b42183e8989.png)

## Process

I noticed some metrics that were showing the same data but not using the same name. For example "ActivityDate" and "Sleepday" from the
daily_activity and the daily_sleep tables. I changed both to "Date" so later I'm able to merge the datasets and sync the data.

`names(daily_activity)[names(daily_activity) =="ActivityDate"] <- "Date"`

`names(daily_sleep)[names(daily_sleep) =="SleepDay"] <- "Date"`

After matching those column names to match the other tables I checked some of the data that was showing only 0's for their metric values.
I looked at "LoggedActivitiesDistance" and "SedentaryActiveDistance" from the daily_activity table. "Fat" and "LogId" from the daily_weight table
to see there was not enough data to use in our analysis. I also changed the Date data type within each table from a character type to a date data type.
The daily_weight table has date and time metrics in "Date" but neither activity or sleep tables include time, filtering out time helps format the data.

`n_distinct(daily_activity$LoggedActivitiesDistance)`

`n_distinct(daily_activity$SedentaryActiveDistance)`

`daily_activity <- (select(daily_activity, -c(LoggedActivitiesDistance,SedentaryActiveDistance)))`

`daily_weight <- (select(daily_weight, -c(Fat)))`

`daily_weight <- (select(daily_weight, -c(LogId)))`

`daily_activity$Date <- as.Date(daily_activity$Date, format='%m/%d/%Y')`

`daily_sleep$Date <- as.Date(daily_sleep$Date, format='%m/%d/%Y')`

`daily_weight$Date <- as.Date(daily_weight$Date, format='%m/%d/%Y')`

Checked each table for duplicates or NA values and corrected them to further clean the data for analysis.

`sum(duplicated(daily_activity))`

`sum(is.na(daily_activity))`

`sum(duplicated(daily_sleep))`

`sum(is.na(daily_sleep))`

`daily_sleep <- distinct(daily_sleep, .keep_all = FALSE)`

`sum(duplicated(daily_weight))`

`sum(is.na(daily_weight))`

![Duplicated data](https://user-images.githubusercontent.com/86019532/122691654-10950780-d1ff-11eb-82d9-eb9a6ee25e21.png)

Then merged all 3 tables together into 1 data frame since now the primary key metrics match each other in the other tables. After merging
I summarized the merged table to check the data and make sure it's ready for analysis.

`daily_merged <- full_join(daily_activity,daily_sleep,by=NULL,copy=FALSE)`

`daily_merged <- full_join(daily_merged,daily_weight,by=NULL,copy=FALSE)`

`summary(daily_merged)`

![Summary Merged](https://user-images.githubusercontent.com/86019532/122691695-4afea480-d1ff-11eb-9082-c38d2e37f850.png)


