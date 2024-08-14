select * from hr_data3;

-- Note the below code is to be used in MySQL, not compatible with SSMS

-- note that y and Y are different for str_to_date function. Since the data shows 4 digit year, you want to use "Y" and not lower case. 



-- remember that the termdate column had hours, minutes and seconds in it as well. You went into excel, highlighted that column, clicked on " Find & Select" tool, 
-- clicked on "replace" and then in the "find what" box you entered in " *" and then clicked on replace all. This removed the time. 






-- ---------------------------- Clean data -------------------------------------------------
select * from hr_data3

UPDATE hr_data3
SET birthdate = STR_TO_DATE(birthdate, "%m/%d/%Y"); 

UPDATE hr_data3
SET hire_date = STR_TO_DATE(hire_date, "%m/%d/%Y"); 

-- note that for the term_date column, there are also empty string values. These are not null. Change that first.

update hr_data3
	SET termdate = null
    WHERE termdate = ''
    
-- Now we will convert the remaining dates from a string to a date datatype

UPDATE hr_data3
SET termdate = STR_TO_DATE(termdate, '%m/%d/%Y');

-- Next, let's go ahead and add our new column, new_termdate.

ALTER TABLE HR_data3
ADD new_termdate DATE; 

-- lastly, go ahead and now copy the data from termdate into new_termdate
    
UPDATE hr_data3
	SET new_termdate = termdate
    
    
-- Next, create a new column called "age" 
select * from hr_data3

ALTER TABLE hr_data3
ADD age varchar(50) 

-- find the current age of everyone within the data

UPDATE hr_data3
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE())

-- timestampdiff is the SSMS equivalent of datediff and CURDATE is the SSMS equivalent of GETDATE function
-- ------------------------------- Questions to now answer from the data -----------------------------

-- 1. What is the age distribution in the company?

-- age distribution: 

select
MIN(age) AS youngest,
MAX(age) AS Oldest
FROM HR_data3; 

-- Age group by gender

select gender, age, count(gender) AS gender_count FROM hr_data3
GROUP BY age, gender
ORDER BY age desc; 

-- The above queries show how many individuals in the company are at each age, and you can separate by gender. For data purposes, we are going to break
-- down the information into categories, and go from there.

-- age group

SELECT age_group,
COUNT(*) AS count
FROM 
(SELECT 
	CASE 
	WHEN age >=31 AND age <= 30 THEN '21 to 30'
	WHEN age >=31 AND age <= 40 THEN '31 to 40'
	WHEN age >=41 AND age <= 50 THEN '41 to 50'
	ELSE '50+'
	END AS age_group
	FROM hr_data3
	WHERE new_termdate IS NULL
	) AS subquery
GROUP BY age_group
ORDER BY age_group;


-- age group by gender

SELECT age_group, gender,
COUNT(*) AS count
FROM 
(SELECT 
	CASE 
	WHEN age >=21 AND age <= 30 THEN '21 to 30'
	WHEN age >=31 AND age <= 40 THEN '31 to 40'
	WHEN age >=41 AND age <= 50 THEN '41 to 50'
	ELSE '50+'
	END AS age_group, gender
	FROM hr_data3
	WHERE new_termdate IS NULL
	) AS subquery
GROUP BY age_group, gender
ORDER BY age_group, gender

-- 2) What's the gender breakdown in the company?

select * from hr_data3;

select gender, count(gender) AS Count
FROM hr_data3
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender asc; 


-- 3) How does gender vary across departments and job titles?

select department, gender, count(gender) AS count FROM HR_data3
WHERE new_termdate IS NULL 
Group by gender, department
order by department, gender ASC;


-- 4) What's the race distribution in the company?

SELECT race, count(race) AS count FROM HR_Data3 
WHERE new_termdate IS NULL
Group by race
order by count desc; 

-- 5) What's the average length of employment in the company? 

SELECT AVG(TIMESTAMPDIFF(year, hire_date, new_termdate)) AS tenure FROM hr_data3
WHERE new_termdate IS NOT NULL AND new_termdate <= CURDATE(); 

-- Which department has the highest turnover count? 

Select department, count(*) AS total_count,
sum(CASE 
		WHEN new_termdate IS NOT NULL AND new_termdate <=CURDATE() THEN 1 ELSE 0
        END
        ) AS terminated_count
FROM hr_data3
GROUP BY department
order by terminated_count desc;


-- which department has the highest turnover rate?

SELECT 
	department, 
	total_count,
	terminated_count, 
	round((CAST(terminated_count AS FLOAT)/total_count), 2) * 100 AS turnover_rate
	FROM
		(select department, count(*) AS total_count,
		SUM(CASE
			WHEN new_termdate IS NOT NULL AND new_termdate <=CURDATE()  THEN 1 ELSE 0
			END
			) AS terminated_count
		FROM hr_data3
		GROUP BY department
		) AS subquery
	ORDER BY turnover_rate DESC;

select * from HR_Data;

-- 7) What is the tenure distribution for each department?

SELECT department, AVG(TIMESTAMPDIFF(year, hire_date, new_termdate)) AS tenure FROM hr_data3
WHERE new_termdate IS NOT NULL AND new_termdate <= CURDATE()
GROUP BY department
order by tenure DESC; 

-- 8) How many employees work remotely from each department?

select * from HR_data;

SELECT Location, count(*) AS count FROM HR_Data3
WHERE new_termdate IS NULL
GROUP BY location; 

-- 9) What's the distribution of employees across different states?

select location_state, count(*) AS Employees_at_location FROM HR_data3
WHERE new_termdate IS NULL
GROUP BY location_state
order by count(*) desc

-- 10) How are job titles distributed in the company?

SELECT jobtitle, count(*) AS number_of_employees_in_role FROM HR_Data3
WHERE new_termdate IS NULL
GROUP BY jobtitle
order by count(*) desc; 

-- 11) How have employee hire counts varied over time? 

-- Calculate hires
-- Calculate terminations
-- (Hires-Terminations)/hires Percent hire change

select * from HR_data3;
SELECT
	hire_year, hires, terminations, hires - terminations AS net_change,
	(round(CAST(hires-terminations AS FLOAT)/hires, 2))*100 AS percent_hire_change
	FROM
	(
	SELECT Year(hire_date) AS Hire_year, count(*) AS hires,
	SUM(CASE
		WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0
		END
		) AS terminations
	FROM HR_data
	GROUP BY YEAR(Hire_date) 
	) AS subquery
ORDER BY percent_hire_change ASC;



-- the below code is not relevant to the above queries, you wrote this as an experiment to determine how to 
-- set the termdate column into a datetime datatype since it had blank data values in there.


create table date_exp (
	ID int NOT NULL AUTO_INCREMENT,
    Name varchar(20),
    termdate varchar(50),
    new_termdate datetime,
    primary key (ID)
    );

insert into date_exp(Name, termdate, new_termdate) values('John', '01/05/1993', NULL); 
insert into date_exp(Name, termdate, new_termdate) values('Mike', '02/06/1987', NULL); 
insert into date_exp(Name, termdate, new_termdate) values('Rob', '', NULL); 
insert into date_exp(Name, termdate, new_termdate) values('Bill', '', NULL); 
insert into date_exp(Name, termdate, new_termdate) values('Tim', '09/11/2001', NULL); 

select * from date_exp


 -- step 1. 
update date_exp
	SET termdate = null 
    WHERE termdate = ''

-- step 2.
UPDATE date_exp
SET termdate = STR_TO_DATE(termdate, '%m/%d/%Y');

-- step 3.
UPDATE date_exp
SET new_termdate = termdate


select * from hr_data2

-- step 2.
update hr_data2
	SET termdate = null
    WHERE termdate = ''
    
-- step 3. 

UPDATE hr_data2
	SET new_termdate = termdate
    