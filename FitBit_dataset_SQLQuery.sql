use Strava_Fitness
go


-- Checking Number of Rows on daily_activity
SELECT COUNT (*)
FROM dailyActivity_merged;

-- Checking for duplicates in daily_activity
SELECT Id, ActivityDate, TotalSteps, Count(*)
FROM dailyActivity_merged
GROUP BY id, ActivityDate, TotalSteps
HAVING Count(*) > 1;

-- Modify date format for better understaning in daily_activity
Update dailyActivity_merged
Set ActivityDate = Convert(date, ActivityDate, 21);

-- Add day_0f_week column on daily_activities
Alter Table dailyActivity_merged
ADD day_of_week nvarchar(50)

--Extract datename from ActivityDate
Update dailyActivity_merged
SET day_of_week = DATENAME(DW, ActivityDate)

-- Modify date format for better understaning in sleep_day
Update sleepDay_merged
Set SleepDay = Convert(date, SleepDay, 21)

-- Add sleep data columns on daily_activity
Alter Table dailyActivity_merged
ADD TotalMinutesAsleep int,
TotalTimeInBed int;

--Add sleep records into dailyActivity
UPDATE dailyActivity_merged
Set TotalMinutesAsleep = temp2.TotalMinutesAsleep,
	TotalTimeInBed = temp2.TotalTimeInBed 
From dailyActivity_merged as temp1
Full Outer Join sleepDay_merged as temp2
on temp1.id = temp2.id and temp1.ActivityDate = temp2.SleepDay;

--Adding specific date format to daily_activity
Alter table dailyActivity_merged
Add date_new date;
Update dailyActivity_merged
Set date_new  = CONVERT( date, ActivityDate, 103 )

--Split date and time for hourly_calories
Alter Table hourlyCalories_merged
ADD time_new int, date_new DATE;
Update hourlyCalories_merged
Set time_new = DATEPART(hh, ActivityHour);
Update hourlyCalories_merged
Set date_new = CAST(ActivityHour AS DATE);

--Split date and time seperately for hourly_intensities
Alter Table hourlyIntensities_merged
ADD time_new int, date_new DATE;
Update hourlyIntensities_merged
Set time_new = DATEPART(hh, ActivityHour);
Update hourlyIntensities_merged
Set date_new = CAST(ActivityHour AS DATE);

--Split date and time seperately for hourly_steps
Alter Table hourlySteps_merged
ADD time_new int, date_new DATE;
Update hourlySteps_merged
Set time_new = DATEPART(hh, ActivityHour);
Update hourlySteps_merged
Set date_new = CAST(ActivityHour AS DATE);

--Split date and time seperately for minute_METs_narrow
Alter Table minuteMETsNarrow_merged
ADD time_new TIME, date_new DATE
Update minuteMETsNarrow_merged
Set time_new = CAST(ActivityMinute as time)
Update minuteMETsNarrow_merged
Set time_new = Convert(varchar(5), time_new, 108)
Update minuteMETsNarrow_merged
Set date_new = CAST(ActivityMinute AS DATE);

--Create new table to merge hourly_calories, hourly_intensities, and hourly_steps
Create table hourly_data_merge(
id numeric(18,0),
date_new nvarchar(50),
time_new int,
calories numeric(18,0),
total_intensity numeric(18,0),
average_intensity float,
step_total numeric (18,0)
);
--Insert corresponsing data and merge multiple table into one table
Insert Into hourly_data_merge(id, date_new, time_new, calories, total_intensity, average_intensity, step_total)
(SELECT temp1.Id, temp1.date_new, temp1.time_new, temp1.Calories, temp2.TotalIntensity, temp2.AverageIntensity, temp3.StepTotal
From hourlyCalories_merged AS temp1
Inner Join hourlyIntensities_merged AS temp2
ON temp1.Id = temp2.Id and temp1.date_new = temp2.date_new and temp1.time_new = temp2.time_new 
Inner Join hourlySteps_merged AS temp3
ON temp1.Id = temp3.Id and temp1.date_new = temp3.date_new and temp1.time_new = temp3.time_new);

--Checking for duplicates
SELECT id, time_new, calories, total_intensity, average_intensity, step_total, Count(*) as duplicates
	  FROM hourly_data_merge
	  GROUP BY id, time_new, calories, total_intensity, average_intensity, step_total
	  HAVING Count(*) > 1;
SELECT sum(duplicates) as total_duplicates
FROM (SELECT id, time_new, calories, total_intensity, average_intensity, step_total, Count(*) as duplicates
	  FROM hourly_data_merge
	  GROUP BY id, time_new, calories, total_intensity, average_intensity, step_total
	  HAVING Count(*) > 1) AS temp;



