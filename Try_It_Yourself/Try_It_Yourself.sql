--------------------------------------------------------------
-- Practical SQL: A Beginner's Guide to Storytelling with Data
-- by Anthony DeBarros

-- Try It Yourself Questions and Answers
--------------------------------------------------------------


--------------
-- Chapter 1
--------------

-- 1. Imagine you're building a database to catalog all the animals at your
-- local zoo. You want one table for tracking all the kinds of animals and
-- another table to track the specifics on each animal. Write CREATE TABLE
-- statements for each table that include some of the columns you need. Why did
-- you include the columns you chose?

CREATE TABLE animal_types (
   animal_type_id bigserial,
   common_name varchar(100),
   scientific_name varchar(100),
   conservation_status varchar(50)
);

CREATE TABLE menagerie (
   animal_id bigserial,
   animal_type_id integer,
   date_acquired date,
   gender char(1),
   acquired_from varchar(100),
   name varchar(100),
   notes text
);

-- 2. Now create INSERT statements to load sample data into the tables.
-- How can you view the data via the pgAdmin tool?

INSERT INTO animal_types (common_name, scientific_name, conservation_status)
VALUES ('Bengal Tiger', 'Panthera tigris tigris', 'Endangered'),
      ('Arctic Wolf', 'Canis lupus arctos', 'Least Concern');
-- source: https://www.worldwildlife.org/species/directory?direction=desc&sort=extinction_status

INSERT INTO menagerie (animal_type_id, date_acquired, gender, acquired_from, name, notes)
VALUES
(1, '3/12/1996', 'F', 'Dhaka Zoo', 'Ariel', 'Healthy coat at last exam.'),
(2, '9/30/2000', 'F', 'National Zoo', 'Freddy', 'Strong appetite.');


-- 3. Create an additional INSERT statement for one of your tables. On purpose,
-- leave out one of the required commas separating the entries in the VALUES
-- clause of the query. What is the error message? Does it help you find the
-- error in the code?

INSERT INTO animal_types (common_name, scientific_name, conservation_status)
VALUES ('Javan Rhino', 'Rhinoceros sondaicus' 'Critically Endangered');

--------------
-- Chapter 2
--------------

-- 1. Write a query that lists the schools in alphabetical order along
-- with teachers ordered by last name A-Z.

SELECT school, first_name, last_name
FROM teachers
ORDER BY school, last_name;

-- 2. Find the one teacher whose first name both starts with the letter
-- 'S' and who earns more than $40,000.

SELECT first_name, last_name, school, salary
FROM teachers
WHERE first_name LIKE 'S%'
      AND salary > 40000;

-- 3. Rank teachers hired since Jan. 1, 2010, ordered by highest paid to lowest.

SELECT last_name, first_name, school, hire_date, salary
FROM teachers
WHERE hire_date >= '2010-01-01'
ORDER BY salary DESC;


--------------
-- Chapter 3
--------------

-- 1. Your company delivers fruit and vegetables to local grocery stores, and
-- you need to track the mileage driven by each driver each day to a tenth
-- of a mile. Assuming no driver would ever travel more than 999 miles in
-- a day, what would be an appropriate data type for the mileage column in your
-- table. Why?

decimal(5,1)
-- Total five digits with one after the decimal, such as 1000.9.
-- Never assume people won't go beyond your assumptions!

-- 2. In the table listing each driver in your company, what are appropriate
-- data types for the drivers’ first and last names? Why is it a good idea to
-- separate first and last names into two columns rather than having one
-- larger name column?
varchar(50)
-- Separating first and last names will allow you later to sort on each.

-- 3. Assume you have a text column that includes strings formatted as dates.
-- One of the strings is written as '4//2017'. What will happen when you try
-- to convert that string to the timestamp data type?
SELECT CAST('4//2017' AS timestamp);
-- Returns an error because the string is an invalid date format.


--------------
-- Chapter 4
--------------

-- 1. Write a WITH statement to include with COPY to handle the import of an
-- imaginary text file that has a first couple of rows that look like this:

-- id:movie:actor
-- 50:#Mission: Impossible#:Tom Cruise

WITH (FORMAT CSV, HEADER, DELIMITER ':', QUOTE '#')

-- 2. Using the table us_counties_2010, write SQL to export to CSV the 20
-- counties in the United States that have the most housing units. Make sure
-- you export each county's name, state and number of housing units. Hint: H
-- ousing units are totaled for each county in the field HU100.

COPY (
    SELECT geo_name, state_us_abbreviation, housing_unit_count_100_percent
    FROM us_counties_2010 ORDER BY HU100 DESC LIMIT 20
     )
TO 'C:\YourDirectory\us_counties_mill_export.txt'
WITH (FORMAT CSV, HEADER)

-- 3. Imagine you're importing a file that contains a field with these values:
      -- 17519.668
      -- 20084.461
      -- 18976.335
-- Will a field in your target table with data type decimal(3,8) work for these
-- values? Why or why not?

-- Answer:
-- No, it won't -- in fact, you won't even be able to create a field with that
-- data type because the precision must be larger than the scale. The correct
-- type is decimal(8,3)


--------------
-- Chapter 5
--------------

-- 1. Write a SQL statement for calculating the area of a circle whose radius is
-- 5 inches? Do you need parentheses in your calculation? Why or why not?

-- Answer:
SELECT 3.14 * 5 ^ 2;
-- Formula is pi * radius squared
-- You do not need parentheses because exponents and roots take precedence over
-- multiplication.

-- 2. Using 2010 Census county data, find the county in New York state that has
-- the highest percentage of the population that identified as "American
-- Indian/Alaska Native Alone." What can you learn about that county from online
-- research that explains the relatively high American Indian population
-- compared with other New York counties?

-- Answer:
SELECT name,
       STUSAB,
       (CAST (P0010005 AS DECIMAL(8,1)) / P0010001) * 100 AS "Pct Am Indian/Alaska Native Alone"
FROM us_counties_2010
WHERE stusab = 'NY'
ORDER BY "Pct Am Indian/Alaska Native Alone" DESC;
-- Franklin County, N.Y., with 7.4%. The county contains the St. Regis Mohawk
-- Reservation.

-- 3. Is median county population higher in California or New York?

-- Answer:
SELECT median(P0010001)
FROM us_counties_2010
WHERE stusab = 'NY';

SELECT median(P0010001)
FROM us_counties_2010
WHERE stusab = 'CA';
-- California has a median county population of 179,140.5, almost double that of
-- New York, at 91,301.

--------------
-- Chapter 6
--------------

-- 1. The table us_counties_2010 contains 3,143 rows, and us_counties_2000 has
-- 3,141. That reflects the ongoing adjustments to county-level geographies that
-- typically result from government decision making. Using appropriate joins and
-- the NULL value, identify which counties don't exist in both tables.

-- Answers:

-- Exist in 2010 data but not 2000:
SELECT c2010.geo_name,
       c2010.state_us_abbreviation,
       c2000.geo_name
FROM us_counties_2010 c2010 LEFT JOIN us_counties_2000 c2000
ON c2010.state_fips = c2000.state_fips
   AND c2010.county_fips = c2000.county_fips
WHERE c2000.geo_name IS NULL;

-- Exist in 2000 data but not 2010:
SELECT c2010.geo_name,
       c2000.geo_name,
       c2000.state_us_abbreviation
FROM us_counties_2010 c2010 RIGHT JOIN us_counties_2000 c2000
ON c2010.state_fips = c2000.state_fips
   AND c2010.county_fips = c2000.county_fips
WHERE c2010.geo_name IS NULL;

-- 2. Using either the median() or percentile_cont() functions in Chapter 5,
-- determine the median percent change in county population.

-- Answer: 3.2%

-- Using median():
SELECT median(round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
           / c2000.p0010001 * 100, 1 )) AS median_pct_change
FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
ON c2010.state_fips = c2000.state_fips
   AND c2010.county_fips = c2000.county_fips;

-- Using percentile_cont():
SELECT percentile_cont(.5)
       WITHIN GROUP (ORDER BY round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
           / c2000.p0010001 * 100, 1 )) AS percentile_50th
FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
ON c2010.state_fips = c2000.state_fips
   AND c2010.county_fips = c2000.county_fips;


-- 3. Which county had the greatest percentage loss of population between 2000
-- and 2010? Do you have any idea why? Hint: a weather event happened in 2005.

-- Answer: St. Bernard Parish, La.

SELECT c2010.geo_name,
       c2010.state_us_abbreviation,
       c2010.p0010001 AS pop_2010,
       c2000.p0010001 AS pop_2000,
       c2010.p0010001 - c2000.p0010001 AS raw_change,
       round( (CAST(c2010.p0010001 AS DECIMAL(8,1)) - c2000.p0010001)
           / c2000.p0010001 * 100, 1 ) AS pct_change
FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
ON c2010.state_fips = c2000.state_fips
   AND c2010.county_fips = c2000.county_fips
ORDER BY pct_change ASC;

--------------
-- Chapter 7
--------------

-- Consider the following two tables, part of a database you’re making to keep
-- track of your vinyl LP collection. Start by reviewing these CREATE TABLE
-- statements:

CREATE TABLE albums (
    album_id bigserial,
    album_catalog_code varchar(100),
    album_title text,
    album_artist text,
    album_time interval,
    album_release_date date,
    album_genre varchar(40),
    album_description text
);

CREATE TABLE songs (
    song_id bigserial,
    song_title text,
    song_artist text,
    album_id bigint
);

-- Use the tables to answer these questions:

-- 1. Modify these CREATE TABLE statements to include primary and foreign keys
-- plus additional constraints on both tables. Explain why you made your
-- choices.

CREATE TABLE albums (
    album_id bigserial,
    album_catalog_code varchar(100),
    album_title text NOT NULL,
    album_artist text NOT NULL,
    album_release_date date,
    album_genre varchar(40),
    album_description text,
    CONSTRAINT album_id_key PRIMARY KEY (album_id),
    CONSTRAINT release_date_check CHECK (album_release_date > '1/1/1925')
);

CREATE TABLE songs (
    song_id bigserial,
    song_title text NOT NULL,
    song_artist text NOT NULL,
    album_id bigint REFERENCES albums (album_id),
    CONSTRAINT song_id_key PRIMARY KEY (song_id)
);

-- Both tables get a primary key using the surrogate key id values that are
-- auto-generated via serial data types. The songs table references albums
-- via a foreign key constraint. In both tables, the title and artist columns
-- cannot be empty. We assume that every album and song should at minimum have
-- that information. Finally, we place a CHECK constraint on the
-- album_release_date column in albums because it would be likely impossible
-- for us to own an LP made before 1925.


-- 2. Instead of using album_id as a surrogate key for your primary key, are
-- there any columns in albums that could be useful as a natural key? What would
-- you have to know to decide?

-- We could consider the album_catalog_code. We would have to answer yes to
-- these questions:
-- -- Is it going to be unique across all albums released by all companies?
-- -- Will we always have one?
-- -- Will it never change for a particular album?


-- 3. To speed up queries, which columns are good candidates for indexes?

-- Primary key columns get indexes by default, but we should add an index
-- to the album_id foreign key column in the songs table because we'll use
-- it in table joins. It's likely that we'll query these tables to search
-- by titles and artists, so those columns in both tables should get indexes
-- too. The album_release_date in albums also is a candidate if we expect
-- to perform many queries that include date ranges.


--------------
-- Chapter 8
--------------

-- 1. We saw that library visits have declined in most places. What is the
-- pattern in the use of technology in libraries? Both the 2014 and 2009 library
-- survey tables contain the columns gpterms (the number of internet-connected
-- computers used by the public) and pitusr (uses of public internet computers
-- per year). Modify the code in Listing 8-12 to calculate the percent change in
-- the sum of each column over time. Watch out for negative values!


-- sum() gpterms (computer terminals) by state, add pct. change, and sort

SELECT pls14.stabr,
       sum(pls14.gpterms) AS "gpterms_2014",
       sum(pls09.gpterms) AS "gpterms_2009",
       round( (CAST(sum(pls14.gpterms) AS decimal(10,1)) - sum(pls09.gpterms)) /
                    sum(pls09.gpterms) * 100, 2 ) AS "pct_change"
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.gpterms >= 0 AND pls09.gpterms >= 0
GROUP BY pls14.stabr
ORDER BY pct_change DESC;

-- sum() pitusr (uses of public internet computers per year) by state, add
-- pct. change, and sort

SELECT pls14.stabr,
       sum(pls14.pitusr) AS "pitusr_2014",
       sum(pls09.pitusr) AS "pitusr_2009",
       round( (CAST(sum(pls14.pitusr) AS decimal(10,1)) - sum(pls09.pitusr)) /
                    sum(pls09.pitusr) * 100, 2 ) AS "pct_change"
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.pitusr >= 0 AND pls09.pitusr >= 0
GROUP BY pls14.stabr
ORDER BY pct_change DESC;


-- 2. Both library survey tables contain a column called obereg, a two-digit
-- Bureau of Economic Analysis Code that classifies each library agency
-- according to a region of the United States, like New England, Rocky
-- Mountains, and so on. Just as we calculated the percent change in visits
-- grouped by state, do the same to group percent changes in visits by US
-- regions using obereg. Consult the survey documentation to find the meaning
-- of each region code. For a bonus challenge, create a table with the obereg
-- code as the primary key and the region name as text, and join it to the
-- summary query to group by the region name rather than the code.

-- sum() visits by region.

SELECT pls14.obereg,
       sum(pls14.visits) AS "visits_2014",
       sum(pls09.visits) AS "visits_2009",
       round( (CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits)) /
                    sum(pls09.visits) * 100, 2 ) AS "pct_change"
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.visits >= 0 AND pls09.visits >= 0
GROUP BY pls14.obereg
ORDER BY pct_change DESC;

-- bonus of creating the lookup table and adding it to the query

CREATE TABLE obereg_codes (
    obereg varchar(2) CONSTRAINT obereg_key PRIMARY KEY,
    region varchar(50)
);

INSERT INTO obereg_codes
VALUES ('01', 'New England (CT ME MA NH RI VT)'),
       ('02', 'Mid East (DE DC MD NJ NY PA)'),
       ('03', 'Great Lakes (IL IN MI OH WI)'),
       ('04', 'Plains (IA KS MN MO NE ND SD)'),
       ('05', 'Southeast (AL AR FL GA KY LA MS NC SC TN VA WV)'),
       ('06', 'Soutwest (AZ NM OK TX)'),
       ('07', 'Rocky Mountains (CO ID MT UT WY)'),
       ('08', 'Far West (AK CA HI NV OR WA)'),
       ('09', 'Outlying Areas (AS GU MP PR VI)');

-- sum() visits by region.

SELECT obereg_codes.region,
       sum(pls14.visits) AS "visits_2014",
       sum(pls09.visits) AS "visits_2009",
       round( (CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits)) /
                    sum(pls09.visits) * 100, 2 ) AS "pct_change"
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
   ON pls14.fscskey = pls09.fscskey
JOIN obereg_codes
   ON pls14.obereg = obereg_codes.obereg
WHERE pls14.visits >= 0 AND pls09.visits >= 0
GROUP BY obereg_codes.region
ORDER BY pct_change DESC;


-- 3. Thinking back to the types of joins you learned in Chapter 6, which join
-- type will show you all the rows in both tables, including those without a
-- match? Write such a query and add an IS NULL filter in a WHERE clause to
-- show agencies not included in one or the other table.

SELECT pls14.libname, pls14.city, pls14.stabr, pls14.statstru, pls14.c_admin, pls14.branlib,
       pls09.libname, pls09.city, pls09.stabr, pls09.statstru, pls09.c_admin, pls09.branlib
FROM pls_fy2014_pupld14a pls14 FULL OUTER JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.libname IS NULL;

--------------
-- Chapter 9
--------------

-- In this exercise, you’ll turn our meat_poultry_egg_inspect table into useful
-- information. We want to answer two questions: How many of the companies
-- in the table process meat, and how many process poultry?

-- Create two new columns in your table called meat_processing and
-- poultry_processing. Each can be of the type boolean.

-- Using UPDATE, set meat_processing = TRUE on any row where the activities
-- column contains the text 'Meat Processing'. Do the same update on the
-- poultry_processing column, this time looking for the text
-- 'Poultry Processing' in activities.

-- Use the data from the new, updated columns to count how many companies
-- perform each type of activity. For a bonus challenge, count how many
-- companies perform both activities.


-- Add the columns
ALTER TABLE meat_poultry_egg_inspect ADD COLUMN meat_processing boolean;
ALTER TABLE meat_poultry_egg_inspect ADD COLUMN poultry_processing boolean;

-- Update the columns
UPDATE meat_poultry_egg_inspect
SET meat_processing = TRUE
WHERE activities ILIKE '%meat processing%';

UPDATE meat_poultry_egg_inspect
SET poultry_processing = TRUE
WHERE activities ILIKE '%poultry processing%';

-- Count meat and poultry processors
SELECT count(meat_processing), count(poultry_processing)
FROM meat_poultry_egg_inspect;

-- Count those who do both
SELECT count(*)
FROM meat_poultry_egg_inspect
WHERE meat_processing = TRUE AND
      poultry_processing = TRUE;

--------------
-- Chapter 10
--------------

-- 1. In Listing 10-2, the correlation coefficient, or r value, of the
-- variables pct_bachelors_higher and median_hh_income was about .68. Now
-- write a query to show the correlation between pct_masters_higher and
-- median_hh_income. Is the r value higher or lower? What might explain
-- the difference?

SELECT
    round(
    corr(median_hh_income, pct_bachelors_higher)::numeric, 2
    ) AS bachelors_income_r,
    round(
    corr(median_hh_income, pct_masters_higher)::numeric, 2
    ) AS masters_income_r
FROM acs_2011_2015_stats;

-- The r value of pct_bachelors_higher and median_hh_income is about .57, which
-- shows a smaller connection between percent master's degree or higher and
-- income than percent bachelor's degree or higher and income. Attaining a
-- master's degree or higher may have a more incremental impact on earnings
-- than just getting a four-year degree.

-- 2. Which cities with a population of 500,000 or more have the highest rates
-- of motor vehicle thefts (variable motor_vehicle_theft)? Which have the
-- highest violent crime rates (variable violent_crime)?

SELECT
    city,
    st,
    population,
    motor_vehicle_theft,
    round(
        (motor_vehicle_theft::numeric / population) * 100000, 1
        ) AS vehicle_theft_per_100000
FROM fbi_crime_data_2015
WHERE population >= 500000;

-- Milwaukee and Albuquerque have the two highest rates of motor vehicle theft.

SELECT
    city,
    st,
    population,
    violent_crime,
    round(
        (violent_crime::numeric / population) * 100000, 1
        ) AS violent_crime_per_100000
FROM fbi_crime_data_2015
WHERE population >= 500000
ORDER BY (violent_crime::numeric / population) * 100000 DESC;

-- Detroit and Memphis have the two highest rates of violent crime.

-- 3. As a bonus challenge, revisit the libraries data in table
-- pls_fy2014_pupld14a from Chapter 8. Rank library agencies based on the rate
-- of visits per 1,000 population (variable popu_lsa), and limit the query to
-- agencies serving 250,000 people or more.

SELECT
    libname,
    stabr,
    visits,
    popu_lsa,
    round(
        (visits::numeric / popu_lsa) * 1000, 1
        ) AS visits_per_1000,
    rank() OVER (ORDER BY (visits::numeric / popu_lsa) * 1000 DESC)
FROM pls_fy2014_pupld14a
WHERE popu_lsa >= 250000;

-- Cuyahoga County Public Library tops the rankings with 12,963 visits per
-- thousand people.

--------------
-- Chapter 11
--------------

-- 1. Using the New York City taxi data, calculate the length of each ride using
-- the pickup and drop-off timestamps. Sort the query results from longest ride
-- to shortest. Is there anything you notice about the longest or shortest trips
-- that you would want to ask more about?

SELECT
    trip_id,
    tpep_dropoff_datetime,
    tpep_pickup_datetime,
    tpep_dropoff_datetime - tpep_pickup_datetime AS length_of_ride
FROM nyc_yellow_taxi_trips_2016_06_01
ORDER BY tpep_dropoff_datetime - tpep_pickup_datetime DESC;

-- Answer: More than 500 of the trips last more than 3 hours, which seems
-- excessive. Two records have drop-off times before the pickup time, and
-- several have pickup and drop-off times that are the same. It's worth asking
-- whether these records have timestamp errors.

-- 2. Using the AT TIME ZONE keywords, write a query that displays the date and
-- time for London, Johannesburg, Moscow, and Melbourne when it's January 1, 2100,
-- in New York City.

SELECT '2100-01-01 00:00:00-05' AT TIME ZONE 'US/Eastern' AS "New York",
       '2100-01-01 00:00:00-05' AT TIME ZONE 'Europe/London' AS "London",
       '2100-01-01 00:00:00-05' AT TIME ZONE 'Africa/Johannesburg' AS "Johannesburg",
       '2100-01-01 00:00:00-05' AT TIME ZONE 'Europe/Moscow' AS "Moscow",
       '2100-01-01 00:00:00-05' AT TIME ZONE 'Australia/Melbourne' AS "Melbourne";

-- 3. For a bonus challenge, use the statistics functions from Chapter 10 to
-- calculate the correlation coefficient and r-squared values using trip time
-- and the total_amount column, which represents total amount charged to
-- passengers. Do the same with trip_distance and total_amount. Limit the query
-- to rides lasting three hours or less.

SELECT
    round(
          corr(total_amount, (
              date_part('epoch', tpep_dropoff_datetime) -
              date_part('epoch', tpep_pickup_datetime)
                ))::numeric, 2
          ) AS amount_time_corr,
    round(
        regr_r2(total_amount, (
              date_part('epoch', tpep_dropoff_datetime) -
              date_part('epoch', tpep_pickup_datetime)
        ))::numeric, 2
    ) AS amount_time_r2,
    round(
          corr(total_amount, trip_distance)::numeric, 2
          ) AS amount_distance_corr,
    round(
        regr_r2(total_amount, trip_distance)::numeric, 2
    ) AS amount_distance_r2
FROM nyc_yellow_taxi_trips_2016_06_01
WHERE tpep_dropoff_datetime - tpep_pickup_datetime <= '3 hours'::interval;


--------------
-- Chapter 12
--------------

-- 1. Revise the code in Listing 12-14 to dig deeper into the nuances of
-- Waikiki’s high temperatures. Limit the temps_collapsed table to the Waikiki
-- maximum daily temperature observations. Then, use the WHEN clauses in the
-- CASE statement to reclassify the temperatures into seven groups that would
-- result in the following text output:

-- '90 or more'
-- '88-89'
-- '86-87'
-- '84-85'
-- '82-83'
-- '80-81'
-- '79 or less'

-- In which of those groups does Waikiki’s daily maximum temperature fall most
-- often?

WITH temps_collapsed (station_name, max_temperature_group) AS
    (SELECT station_name,
           CASE WHEN max_temp >= 90 THEN '90 or more'
                WHEN max_temp BETWEEN 88 AND 89 THEN '88-89'
                WHEN max_temp BETWEEN 86 AND 87 THEN '86-87'
                WHEN max_temp BETWEEN 84 AND 85 THEN '84-85'
                WHEN max_temp BETWEEN 82 AND 83 THEN '82-83'
                WHEN max_temp BETWEEN 80 AND 81 THEN '80-81'
                WHEN max_temp <= 79 THEN '79 or less'
            END
    FROM temperature_readings
    WHERE station_name = 'WAIKIKI 717.2 HI US')

SELECT station_name, max_temperature_group, count(*)
FROM temps_collapsed
GROUP BY station_name, max_temperature_group
ORDER BY max_temperature_group;

-- Answer: Between 86 and 87 degrees. Nice.

-- 2. Revise the ice cream survey crosstab in Listing 12-10 to flip the table.
-- In other words, make flavor the rows and office the columns. Which elements
-- of the query do you need to change? Are the counts different?

SELECT *
FROM crosstab('SELECT flavor,
                      office,
                      count(*)
               FROM ice_cream_survey
               GROUP BY flavor, office
               ORDER BY flavor',

              'SELECT office
               FROM ice_cream_survey
               GROUP BY office
               ORDER BY office')

AS (flavor varchar(20),
    Downtown bigint,
    Midtown bigint,
    Uptown bigint);

-- Answer: You need to re-order the columns in the first subquery so flavor is
-- first and office is second. count(*) stays third. Then, you must change
-- the second subquery to produce a grouped list of office. Finally, you must
-- add the office names to the output list.

-- The numbers don't change, just the order presented in the crosstab.

--------------
-- Chapter 13
--------------

-- 1. The style guide of a publishing company you're writing for says to avoid
-- commas before suffixes in names. But your author database has several names
-- like Alvarez, Jr. and Williams, Sr. Which functions can you use to remove
-- these? Would a regular expression help?

-- Answer: You can use either the standard SQL replace() function or the
-- PostgreSQL regexp_replace() function:

SELECT replace('Williams, Sr.', ', ', ' ');
SELECT regexp_replace('Williams, Sr.', ', ', ' ');

-- 2. Using any one of the State of the Union addresses, count the number of
-- unique words that are five characters or more. Hint: You can use
-- regexp_split_to_table() in a subquery to create a table of words to count.
-- Bonus: Remove commas and periods at the end of each word.

-- Answer:
SELECT replace(replace(split_text.word, ',', ''), '.', ''), count(*)
FROM
    (SELECT regexp_split_to_table(speech_text, '\s') AS word
     FROM president_speeches
     WHERE speech_date = '1974-01-30') AS split_text
WHERE length(split_text.word) > 5
GROUP BY split_text.word
ORDER BY count(*) DESC;

-- 3. Rewrite the query in Listing 13-25 using the ts_rank_cd() function
-- instead of ts_rank(). According to th PostgreSQL documentation, ts_rank_cd()
-- computes cover density, which takes into account how close the lexeme search
-- terms are to each other. Does using that function significantly change
-- the results?

-- Answer:

SELECT president,
       speech_date,
       ts_rank_cd(search_speech_text, search_query, 2) AS "rank_score"
FROM president_speeches,
     to_tsquery('war & security & threat & enemy') search_query
WHERE search_speech_text @@ search_query
ORDER BY "rank_score" DESC
LIMIT 5;

-- The ranking does change, although the same speeches are generally
-- represented. The change might be more or less pronounced given another set
-- of texts.

--------------
-- Chapter 14
--------------

-- 1. Earlier, you found which US county has the largest area. Now,
-- aggregate the county data to find the area of each state in square
-- miles. (Use the statefp10 column in the us_counties_2010_shp table.)
-- How many states are bigger than the Yukon-Koyukuk area?

SELECT statefp10 AS st,
       round (
              ( sum(ST_Area(geom::geography) / 2589988.110336))::numeric, 2
             ) AS square_miles
FROM us_counties_2010_shp
GROUP BY statefp10
ORDER BY square_miles DESC;

-- Answer: Just three states are bigger than Yukon-Koyukuk: Alaska (FIPS 02),
-- Texas (48), and California (06).

-- 2. Using ST_Distance(), find how many miles separate these two farmers’ markets:
-- The Oakleaf Greenmarket (9700 Argyle Forest Blvd, Jacksonville, Florida) and
-- Columbia Farmers Market (1701 West Ash Street, Columbia, Missouri). You’ll
-- need to first find the coordinates for both in the farmers_markets table.
-- Tip: You can also write this query using the Common Table Expression syntax from
-- Chapter 12.

-- Answer:

WITH
    market_start (geog_point) AS
    (
     SELECT geog_point
     FROM farmers_markets
     WHERE market_name = 'The Oakleaf Greenmarket'
    ),
    market_end (geog_point) AS
    (
     SELECT geog_point
     FROM farmers_markets
     WHERE market_name = 'Columbia Farmers Market'
    )
SELECT ST_Distance(market_start.geog_point, market_end.geog_point) / 1609.344 -- convert to meters to miles
FROM market_start, market_end;

-- Answer: About 851 miles

-- 3. More than 500 rows in the farmers_markets table are missing a value
-- in the county column, an example of “dirty” government data. Using the
-- us_counties_2010_shp table and the ST_Intersects() function, perform a
-- spatial join to find the missing county names based on the longitude and
-- latitude of each market. Because geog_point in farmers_markets is type
-- geography and SRID 4326, you’ll need to cast geom in the Census table
-- to that type and change its SRID using ST_SetSRID().

-- Answer:

SELECT census.name10,
       census.statefp10,
       markets.market_name,
       markets.county,
       markets.st
FROM farmers_markets markets JOIN us_counties_2010_shp census
    ON ST_Intersects(markets.geog_point, ST_SetSRID(census.geom,4326)::geography)
    WHERE markets.county IS NULL
ORDER BY census.statefp10, census.name10;


--------------
-- Chapter 15
--------------

-- 1. Create a view that displays the number of New York City taxi trips per
-- hour. For resources, use the taxi data from Chapter 11 and the query in
-- Listing 11-8.

CREATE VIEW nyc_taxi_trips_per_hour AS
    SELECT
         date_part('hour', tpep_pickup_datetime),
         count(date_part('hour', tpep_pickup_datetime))
    FROM nyc_yellow_taxi_trips_2016_06_01
    GROUP BY date_part('hour', tpep_pickup_datetime)
    ORDER BY date_part('hour', tpep_pickup_datetime);

SELECT * FROM nyc_taxi_trips_per_hour;

-- 2. In Chapter 10, you learned how to calculate rates per thousand. Turn that
-- formula into a rates_per_thousand() function that takes three arguments:
-- the observed_number, the base_number, and the number of decimal_places for
-- the result.

CREATE OR REPLACE FUNCTION
rate_per_thousand(observed_number numeric,
                  base_number numeric,
                  decimal_places integer DEFAULT 1)
RETURNS numeric(10,2) AS $$
BEGIN
    RETURN
        round(
        (observed_number / base_number) * 1000, decimal_places
        );
END;
$$ LANGUAGE plpgsql;

SELECT rate_per_thousand(50, 11000, 2);

-- 3. Describe the steps needed to implement a trigger on a table and how the
-- components relate to each other.
