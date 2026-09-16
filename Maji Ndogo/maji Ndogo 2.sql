-- View all employee records --
SELECT * FROM md_water_services.employee;

-- replacing space with full stop --
SELECT
	REPLACE(employee_name, " ", ".") AS employee_name 
FROM md_water_services.employee;

-- setting strings to lower case --
SELECT
	LOWER(REPLACE(employee_name, " ", ".")) AS employee_name 
FROM md_water_services.employee;

-- add all to create the email --
SELECT
	CONCAT(
	LOWER(REPLACE(employee_name, " ", ".")), "@ndogowater.gov") AS new_email 
FROM md_water_services.employee;

-- update the employee data with new_emails --
UPDATE employee
SET email =CONCAT(
		   LOWER(REPLACE(employee_name, " ", ".")), "@ndogowater.gov"); 

-- View all updates made --
SELECT * FROM md_water_services.employee;

-- Verifying phone_number validity --
SELECT
	LENGTH(phone_number)
FROM employee; -- Error, characters are supposed to be 12 including the '+'. Could be as a result of trailing space

SELECT
	LENGTH(TRIM(phone_number))
FROM md_water_services.employee; -- Fixed! It was trailing spaces

UPDATE employee
SET phone_number = TRIM(phone_number); -- Updated

SELECT
	town_name,
    COUNT(*) AS employee_count -- counting how many of our employees live in each town.
FROM employee
GROUP BY town_name;

# The President wishes to reward the three most hardworking employees

SELECT
	assigned_employee_id,
    COUNT(*) AS visits_count
FROM visits
GROUP BY assigned_employee_id
ORDER BY visits_count DESC    -- top hardworking employee_ids are 1, 30 & 34
LIMIT 3;

SELECT 
	employee_name,
    email,
    phone_number
FROM employee
WHERE assigned_employee_id IN (1, 30, 34); -- info about employees with highest visits

# Back to main analysis

SELECT *
FROM location;

SELECT province_name, town_name, location_type
FROM location;

-- Count the number of location records in each town. --
SELECT 
    town_name, 
    COUNT(*) AS records_per_town
FROM location
GROUP BY town_name
ORDER BY records_per_town DESC;

-- Count location records within each province. --
SELECT 
    province_name, 
    COUNT(*) AS records_per_province
FROM location
GROUP BY province_name
ORDER BY records_per_province DESC;

-- Count location records for each province/town combination. --
SELECT province_name, town_name,
	COUNT(*) AS records_per_town
FROM location
GROUP BY province_name, town_name
ORDER BY province_name, town_name DESC;

-- Count locations by location type --
SELECT COUNT(*), location_type
FROM location
GROUP BY location_type;

# Getting the values in percentages
SELECT 
    ROUND(COUNT(CASE WHEN location_type = 'Rural' THEN 1 END) * 100.0 / COUNT(*), 2) AS rural_pct,
    ROUND(COUNT(CASE WHEN location_type = 'Urban' THEN 1 END) * 100.0 / COUNT(*), 2) AS urban_pct
FROM 
    location;
    
SELECT * FROM water_source;   
 
SELECT COUNT(*) FROM water_source; -- 39,650

SELECT 
	type_of_water_source, -- number of water types available
    COUNT(*) AS num_water_types
FROM water_source
GROUP BY type_of_water_source
ORDER BY num_water_types DESC;

SELECT type_of_water_source, ROUND(AVG(number_of_people_served)) AS avg_people_per_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY avg_people_per_source DESC; -- There are actually about 6 people per tap_in_home and not 644.03. Thus, tap_in_home is about 644/6 ~ 100

SELECT 
	type_of_water_source,
    SUM(number_of_people_served) AS pop_of_people_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY pop_of_people_served DESC;

SELECT SUM(number_of_people_served) AS total_people_served FROM water_source; -- 27,628,140 people



SELECT 
    type_of_water_source,
    SUM(number_of_people_served) AS population_served,
    ROUND(
        (SUM(number_of_people_served) * 100.0) / SUM(SUM(number_of_people_served)) OVER ()
    ) AS percentage_served -- percentage of people served
FROM 
    water_source
GROUP BY 
    type_of_water_source
ORDER BY 
    population_served DESC;
    

SELECT 
    type_of_water_source,
    SUM(number_of_people_served) AS total_people_served,
    RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS rank_by_population
FROM 
    water_source
WHERE 
    type_of_water_source != 'tap_in_home'
GROUP BY 
    type_of_water_source;

-- which shared taps or wells should be fixed first?
SELECT 
	source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER(
    PARTITION BY type_of_water_source
    ORDER BY number_of_people_served DESC
    ) AS priority_rank
FROM water_source
WHERE type_of_water_source IN ('shared_tap', 'well')
ORDER BY type_of_water_source, priority_rank ;

# Using RANK() can make things tricky to keep track of repairs as they rank skips based on frequency, Denserank serves better here
SELECT 
	source_id,
    type_of_water_source,
    number_of_people_served,
    DENSE_RANK() OVER(
    PARTITION BY type_of_water_source
    ORDER BY number_of_people_served DESC
    ) AS priority_rank
FROM water_source
WHERE type_of_water_source IN ('shared_tap', 'well')
ORDER BY type_of_water_source, priority_rank ;

# This makes things even easier for the engineers in deciding what water sources to fix first making it the best choice.
SELECT 
	source_id,
    type_of_water_source,
    number_of_people_served,
    ROW_NUMBER() OVER(
    PARTITION BY type_of_water_source
    ORDER BY number_of_people_served DESC
    ) AS priority_rank
FROM water_source
WHERE type_of_water_source IN ('shared_tap', 'well')
ORDER BY type_of_water_source, priority_rank ;

SELECT * FROM visits;

-- How long did the survey last?
SELECT
MIN(time_of_record) AS start_of_survey,
MAX(time_of_record) AS end_of_survey,
DATEDIFF(MIN(time_of_record), MAX(time_of_record)) AS survey_duration -- The survey took about 924 days. Which is about 2.5 years
FROM visits;

-- average total queue time for water
SELECT 
ROUND(SUM(time_in_queue)/COUNT(*), 0) AS avg_queue_time
FROM visits
WHERE time_in_queue > 0;

	-- OR --
    
SELECT 
    ROUND(AVG(time_in_queue), 0) AS avg_queue_time_minutes
FROM 
    visits
WHERE 
    time_in_queue > 0;
    

-- average queue time on different days
SELECT 
(SUM(time_in_queue)/COUNT(*)) AS avg_queue_time
FROM visits;

-- What is the average queue time on different days?
SELECT 
    DAYNAME(time_of_record) AS day_of_week,
    ROUND(AVG(time_in_queue), 0) AS avg_queue_time_minutes
FROM 
    visits
WHERE 
    time_in_queue > 0
GROUP BY 
    DAYNAME(time_of_record),
    DAYOFWEEK(time_of_record)
ORDER BY 
    DAYOFWEEK(time_of_record);
    
-- What time during the day people collect water
SELECT 
	TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    ROUND(AVG(time_in_queue), 0) AS avg_queue_time
FROM visits
GROUP BY TIME_FORMAT(TIME(time_of_record), '%H:00')
ORDER BY hour_of_day; -- we have mornings and evenings as the busiet periods

/*
   Display the hour, day name, and queue time for Sunday
   observations.

   CASE returns time_in_queue only when the visit occurred
   on Sunday.

   For other days, NULL is returned.

   Because the WHERE clause excludes zero queue times, only
   observations with a non-zero queue are considered.
*/
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record),
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END AS Sunday
FROM
visits
WHERE
time_in_queue != 0; -- this exludes other sources with 0 queue times.

/*
-- HOUR-BY-HOUR COMPARISON ACROSS THE WEEK: Compare average queue times for every hour across each
-- day of the week.The result produces one row per hour and one column for each day of the week. --*/

SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,
-- Tuesday--
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday,
-- Wednesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,
-- Thursday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END
),0) AS Thursday,
-- Friday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END
),0) AS Friday,
-- Saturday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL
END
),0) AS Saturday
FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;

