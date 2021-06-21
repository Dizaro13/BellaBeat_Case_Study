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
- [Analyze](#analyze)
- [Act](#act)
- [Conclusion](#conclusion)


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

## Analyze

I wanted to see how the average user used their time throughout an average day. I took the mean from each activity time metric inlcuding the amount of
sleep from each recorded data row to create a new data frame table. Used the new table to create a column graph to showcase the differences between the different
activity types. 

`Average_Activity_Minutes <- c(21,14,193,991,419)`

`Activity_Names <- c("Very","Fairly","Lightly","Sedentary","Sleeping")`

`Average_Intensity <- data.frame(Average_Activity_Minutes, Activity_Names)`

`ggplot(data= Average_Intensity)+`

  `geom_col(aes(x=Average_Activity_Minutes,y=Activity_Names,fill=Activity_Names))+`
  
  `labs(title="Average Intensity",x="Minutes per day",y="Activity Type")`
  
![Average Intensity Graph](https://user-images.githubusercontent.com/86019532/122692918-8f8d3e80-d205-11eb-983a-e9d772865825.png)

The graph shows the average user, from the dataset we're working with, how they spend their day wearing their FitBit. The average user spends 16% of their day active
whether that be Very, Fairly, or Lightly active. They also spend 69% of their recorded day Sedentary.

Next I wanted to see the ratio between Active minutes and Sedentary minutes. I didn't take the average because I wanted to see each individual data point.
Checking the ratio will allow you to see how many people record their activity compared to them being sedentary. Creating a histogram with the ratio on the
x axis and Density or number of users on the y axis

`Activity_Minutes <- c(daily_merged$VeryActiveMinutes + daily_merged$FairlyActiveMinutes + daily_merged$LightlyActiveMinutes)`

`Activity_Minutes_Ratio <- c(Activity_Minutes/daily_merged$SedentaryMinutes)`

`ggplot(data=daily_merged)+`

  `geom_histogram(mapping=aes(x=Activity_Minutes_Ratio,y=..density..),fill="orange")+`
  
  `labs(title="Ratio of Active Minutes vs Sedentary Minutes",x="Ratio",y="Density")`
  
![Ratio Active vs Sedentary Graph](https://user-images.githubusercontent.com/86019532/122693707-efd1af80-d208-11eb-84fe-8477c6d0468c.png)

Checking the ratio shows how most users spend their time Active. Most users spend less than 33% of their time wearing the FitBit being Active.
Some of the data points show a few users spening most of or an equal amount of time being Active rather than Sedentary. We need more data points
to check if users only wear their FitBit during exercise.

After that I wanted to check the average user's Activity compared to the Distance they travelled while active. Creating another column graph to see how much people
travel using 3 metrics of Very, Moderately, and Light activity distance travelled. I included Total Distance to compare each metric to the total.

`Average_Activity_Distance <- c(1.5,0.5,3.3,5.5)`

`Distance_Names <- c("Very","Moderately","Light","Total")`

`Average_Distance <- data.frame(Average_Activity_Distance,Distance_Names)`

`ggplot(data=Average_Distance)+`

  `geom_col(mapping=aes(x=Average_Activity_Distance,y=Distance_Names,fill=Distance_Names))+`
  
  `labs(title="Average Distance",x="Distance in km",y="Distance Type")+`
  
  `annotate("text",x=3,y="Total",label="Total Distance is 5.5km")`

![Average Distance Graph](https://user-images.githubusercontent.com/86019532/122694646-0c231b80-d20c-11eb-9f0f-4bf31db0c027.png)

The majority activity type based on distance travelled was Light activity of 60%. The Moderate activity type only contributed to 10% of the Total Distance travelled.
Showing that the average user spends most of their time travelling either by light or very active activity.

## Act

Our first [graph](https://user-images.githubusercontent.com/86019532/122692918-8f8d3e80-d205-11eb-983a-e9d772865825.png) shows us a vast majority of time FitBit users spend their time wearing their FitBit being Sedentary and not active.
Also shows in our data thatmost FitBit users don't wear it while they sleep. BellaBeat could collect more data on FitBit users or their own users to better understand why their customers don't wear smart devices overnight. If there was a clear benefit of wearing a smart device while you sleep that would put BelleBeat at a distinct advantage over
FitBit. Also if BelleBeat showed the benefits of exercise or reminded users to be more active while wearing the device, it would give their customers more data
about their health and habits which is one of their main goals at BelleBeat.

The second [graph](https://user-images.githubusercontent.com/86019532/122692918-8f8d3e80-d205-11eb-983a-e9d772865825.png) shows that people wear their FitBit 
most of the day but they aren't active nearly as much as they are sedentary. It also shows that some of their users only wear their smart device during exercise,
which is probably because they want to track other factors such as heart rate. But those are a lot of assumptions, we need more data points to find exactly why this is.
BellaBeat should encourage users to wear their smart device throughout the day to keep a consistent measurement of their activity.

The third [chart](https://user-images.githubusercontent.com/86019532/122694646-0c231b80-d20c-11eb-9f0f-4bf31db0c027.png) has shown that FitBit users mostly travel
by lightly walking or running. The lightly active and very active activity Distance reflect that most don't travel by moderate activity. This shows that walking and running
are the most common type of travelling for FitBit users. BellaBeat could use this information by focusing on metrics that are runners are most interested in. We don't know 
what most runners are interested in measuring because we don't have that data available. Although encouraging people to run or reminding them to run would probably benefit
because users wearing their smart devices while running is something most customers want to measure. Again this is not a definite statement, we need more data before we are able
to fully understand why FitBit users mostly either walk or run while wearing their smart device.

## Conclusion

The dataset that we analyzed was lacking but we were able to gather some useful insights into what FitBit users are using their smart device for. BellaBeat could use this
analysis to make general observations of users with metrics such as Activity Distance, Activity Time, Sleep Time, and weight. More data should be gathered before making a
decision on implementing new technology using this data into their products.



