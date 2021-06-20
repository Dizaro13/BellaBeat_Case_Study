install.packages("tidyverse")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("lubridate")

library(tidyverse)
library(dplyr)
library(ggplot2)
library(lubridate)

daily_activity <- read.csv("C:/Users/Dizaro/Documents/R/R Coding/archive/Fitabase Data 4.12.16-5.12.16/dailyActivity_merged.csv")
daily_sleep <- read.csv("C:/Users/Dizaro/Documents/R/R Coding/archive/Fitabase Data 4.12.16-5.12.16/sleepDay_merged.csv")
daily_weight <- read.csv("C:/Users/Dizaro/Documents/R/R Coding/archive/Fitabase Data 4.12.16-5.12.16/weightLogInfo_merged.csv")

str(daily_activity)
str(daily_sleep)
str(daily_weight)

names(daily_activity)[names(daily_activity) =="ActivityDate"] <- "Date"
names(daily_sleep)[names(daily_sleep) =="SleepDay"] <- "Date"

n_distinct(daily_activity$LoggedActivitiesDistance)
n_distinct(daily_activity$SedentaryActiveDistance)
daily_activity <- (select(daily_activity, -c(LoggedActivitiesDistance,SedentaryActiveDistance)))
daily_weight <- (select(daily_weight, -c(Fat)))
daily_weight <- (select(daily_weight, -c(LogId)))
daily_activity$Date <- as.Date(daily_activity$Date, format='%m/%d/%Y')
daily_sleep$Date <- as.Date(daily_sleep$Date, format='%m/%d/%Y')
daily_weight$Date <- as.Date(daily_weight$Date, format='%m/%d/%Y')

##Got Rid of time with daily_weight$Date, it's unnecessary, doesnt fit format. Also removed 'Fat' because all values were blank.
##Plus LogId isn't useful in our analysis

sum(duplicated(daily_activity))
sum(is.na(daily_activity))

sum(duplicated(daily_sleep))
sum(is.na(daily_sleep))
daily_sleep <- distinct(daily_sleep, .keep_all = FALSE)

sum(duplicated(daily_weight))
sum(is.na(daily_weight))

daily_merged <- full_join(daily_activity,daily_sleep,by=NULL,copy=FALSE)
daily_merged <- full_join(daily_merged,daily_weight,by=NULL,copy=FALSE)

summary(daily_merged)

##People spend the majority of their time walking by ?

intensity <- full_join(c(daily_merged$VeryActiveDistance,daily_merged$ModeratelyActiveDistance,by=NULL,copy=FALSE))
ggplot(data=daily_merged) +
  geom_point(mapping=aes(x=VeryActiveDistance,y=TotalSteps),color="red")+
  geom_point(mapping=aes(x=ModeratelyActiveDistance,y=TotalSteps),color="orange")+
  geom_point(mapping=aes(x=LightActiveDistance,y=TotalSteps),color="yellow")+
  labs(title="Difference ")

ggplot(data=daily_merged) +
  geom_point(mapping=aes(x=VeryActiveMinutes,y=TotalSteps),color="red")+
  geom_point(mapping=aes(x=FairlyActiveMinutes,y=TotalSteps),color="orange")+
  geom_point(mapping=aes(x=LightlyActiveMinutes,y=TotalSteps),color="yellow")

Activity_Minutes <- c(daily_merged$VeryActiveMinutes + daily_merged$FairlyActiveMinutes + daily_merged$LightlyActiveMinutes)
ggplot(data=daily_merged)+
  geom_histogram(mapping=aes(x=Activity_Minutes,y=SedentaryMinutes))


