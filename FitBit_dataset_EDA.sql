--Time spent on activity per day
-- Time spent on activity per day (with type conversion)
SELECT DISTINCT Id,
    SUM(CAST(SedentaryMinutes AS INT)) AS sedentary_mins,
    SUM(CAST(LightlyActiveMinutes AS INT)) AS lightly_active_mins,
    SUM(CAST(FairlyActiveMinutes AS INT)) AS fairly_active_mins,
    SUM(CAST(VeryActiveMinutes AS INT)) AS very_active_mins
FROM dailyActivity_merged
WHERE TRY_CAST(TotalTimeInBed AS INT) IS NOT NULL
GROUP BY Id;



--Daily Average analysis - No trends/patterns found

SELECT 
    AVG(CAST(TotalSteps AS INT)) AS avg_steps,
    AVG(CAST(TotalDistance AS FLOAT)) AS avg_distance,
    AVG(CAST(Calories AS INT)) AS avg_calories,
    day_of_week
FROM dailyActivity_merged
GROUP BY day_of_week;



--Daily Sum Analysis - No trends/patterns found
SELECT 
    SUM(CAST(TotalSteps AS INT)) AS total_steps,
    SUM(CAST(TotalDistance AS FLOAT)) AS total_distance,
    SUM(CAST(Calories AS INT)) AS total_calories,
    day_of_week
FROM dailyActivity_merged
GROUP BY day_of_week;



--Sleep and calories comparison	

SELECT temp1.Id,
    SUM(CAST(temp2.TotalMinutesAsleep AS INT)) AS total_sleep_min,
    SUM(CAST(temp2.TotalTimeInBed AS INT)) AS total_time_inbed_min,
    SUM(CAST(temp1.Calories AS INT)) AS calories
FROM dailyActivity_merged AS temp1
INNER JOIN sleepDay_merged AS temp2
    ON temp1.Id = temp2.Id 
    AND temp1.ActivityDate = temp2.SleepDay
GROUP BY temp1.Id;


--Average Sleep Time per user
SELECT Id, Avg(TotalMinutesAsleep)/60 as avg_sleep_time_hour,
Avg(TotalTimeInBed)/60 as avg_time_bed_hour,
AVG(TotalTimeInBed - TotalMinutesAsleep) as wasted_bed_time_min
FROM sleepDay_merged
Group by Id


--Activities and colories comparison

SELECT Id,
    SUM(CAST(TotalSteps AS INT)) AS total_steps,
    SUM(CAST(VeryActiveMinutes AS INT)) AS total_very_active_mins,
    SUM(CAST(FairlyActiveMinutes AS INT)) AS total_fairly_active_mins,
    SUM(CAST(LightlyActiveMinutes AS INT)) AS total_lightly_active_mins,
    SUM(CAST(Calories AS INT)) AS total_calories
FROM dailyActivity_merged
GROUP BY Id;



--average met per day per user, and compare with the calories burned
Select Distinct temp1.Id, temp1.date_new, sum(temp1.METs) as sum_mets, temp2.Calories
From minuteMETsNarrow_merged as temp1
inner join dailyActivity_merged as temp2
on temp1.Id = temp2.Id and temp1.date_new = temp2.date_new
Group By temp1.Id, temp1.date_new, temp2.Calories
Order by date_new
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY
