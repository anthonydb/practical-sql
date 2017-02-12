----------------------------------------------
-- Dig Through Data with SQL
-- by Anthony DeBarros

-- Try It Yourself Answer Key
----------------------------------------------


--------------
-- Chapter 1
--------------

-- 1. Imagine you're building a database to catalog all the animals at your local zoo.
-- You want one table for tracking all the kinds of animals and another table to track
-- the specifics on each animal. Write CREATE TABLE statements for each table that
-- include some of the columns you need. Why did you include the columns you chose?

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


-- 3. Create an additional INSERT statement for one of your tables. On purpose, leave out
-- one of the required commas separating the entries in the VALUES clause of the query. What
-- is the error message? Does it help you find the error in the code?

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

-- 2. Find the one teacher whose name both starts with the letter
-- 'S' and who earns more than $40,000.

SELECT first_name, last_name, school, salary
FROM teachers
WHERE first_name LIKE 'S%'
      AND salary > 40000;

-- 3. Rank teachers hired since Jan. 1, 2010, ordered by highest paid to lowest

SELECT last_name, first_name, school, hire_date, salary
FROM teachers
WHERE hire_date >= '2010-01-01'
ORDER BY salary DESC;


--------------
-- Chapter 3
--------------

-- 1. Assuming no driver would ever travel more than 999 miles in a day,
-- what would be an appropriate data type for the mileage column in your
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
-- to convert that string to the data type of timestamp?
SELECT CAST('4//2017' AS timestamp);
-- Returns an error because the string is an invalid date format.


--------------
-- Chapter 4
--------------

-- 1. Write a WITH statement to include with COPY to handle the import of an
-- imaginary text file that has a first couple of rows that look like this:
-- id:movie:actor
-- 50:%Mission: Impossible%:Tom Cruise

WITH (FORMAT CSV, HEADER, DELIMITER ':', QUOTE '%')

-- 2. Using the table us_counties_2010, write SQL to export to CSV the 20
-- counties in the United States that have the most housing units. Make sure
-- you export each county's name, state and number of housing units. Hint: H
-- ousing units are totaled for each county in the field HU100.

COPY (SELECT NAME, STUSAB, HU100 FROM us_counties_2010 ORDER BY HU100 DESC LIMIT 20)
TO 'C:\YourDirectory\us_counties_mill_export.txt'
WITH (FORMAT CSV, HEADER)

-- 3. Imagine you're importing a file that contains a field with values such as these:
      -- 17519.668
      -- 20084.461
      -- 18976.335
-- Will a field in your target table with data type decimal(3,8) work for these values? Why or why not?

-- Answer:
-- No, it won't -- in fact, you won't even be able to create a field with that data type because the
-- precision must be larger than the scale. The correct type is decimal(8,3)


--------------
-- Chapter 5
--------------

-- 1. Write a SQL statement for calculating the area of a circle whose radius is 5 inches?
-- Do you need parentheses in your calculation? Why or why not?

-- Answer:
SELECT 3.14 * 5 ^ 2;
-- Formula is pi * radius squared
-- You do not need parentheses because exponents and roots take precedence over multiplication.

-- 2. Using  2010 Census county data, find the county in New York state that has the highest
-- percentage of the population that identified as "American Indian/Alaska Native Alone." What
-- can you learn about that county from online research that explains the relatively high
-- American Indian population compared with other New York counties?

-- Answer:
SELECT name,
       STUSAB,
       (CAST (P0010005 AS DECIMAL(8,1)) / P0010001) * 100 AS "Pct Am Indian/Alaska Native Alone"
FROM us_counties_2010
WHERE stusab = 'NY'
ORDER BY "Pct Am Indian/Alaska Native Alone" DESC;
-- Franklin County, N.Y., with 7.4%. The county contains the St. Regis Mohawk Reservation.

-- 3. Is median county population higher in California or New York?

-- Answer:
SELECT median(P0010001)
FROM us_counties_2010
WHERE stusab = 'NY';

SELECT median(P0010001)
FROM us_counties_2010
WHERE stusab = 'CA';
-- California has a median county population of 179,140.5, almost double that of New York, at 91,301.

--------------
-- Chapter 6
--------------

-- 1. The table us_counties_2010 contains 3,143 rows, while us_counties_2000 has 3,141.
-- That reflects the ongoing adjustments to county-level geographies that typically result
-- from government decision-making. Using appropriate joins and the NULL value, identify
-- which counties don't exist in both tables.

-- Answers:

-- Exist in 2010 data but not 2000:
SELECT c2010.name,
       c2010.stusab,
       c2000.geography
FROM us_counties_2010 c2010 LEFT JOIN us_counties_2000 c2000
ON c2010.state = c2000.state AND c2010.county = c2000.county
WHERE c2000.geography IS NULL;

-- Exist in 2000 data but not 2010:
SELECT c2010.name,
       c2000.state,
       c2000.county,
       c2000.geography
FROM us_counties_2010 c2010 RIGHT JOIN us_counties_2000 c2000
ON c2010.state = c2000.state AND c2010.county = c2000.county
WHERE c2010.name IS NULL;

-- 2. Using either the median() or percentile_cont() functions from Chapter 5,
-- determine the median percent change in county population.

-- Answer: 3.2%

-- Using median():
SELECT median(round( (CAST(c2010.P0010001 AS DECIMAL(8,1)) - c2000.P0010001)
           / c2000.P0010001 * 100, 1 )) AS "Median Pct. change"
FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
ON c2010.state = c2000.state AND c2010.county = c2000.county;

-- Using percentile_cont():
SELECT percentile_cont(.5)
       WITHIN GROUP (ORDER BY round( (CAST(c2010.P0010001 AS DECIMAL(8,1)) - c2000.P0010001)
           / c2000.P0010001 * 100, 1 )) AS "50th Percentile"
FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
ON c2010.state = c2000.state AND c2010.county = c2000.county;


-- 3. Which county had the greatest percentage loss of population between 2000 and 2010?
-- Any idea why? Hint: A weather event that happened in 2005.

-- Answer: St. Bernard Parish, La.

SELECT c2010.name,
       c2010.stusab,
       c2010.P0010001 AS "2010 pop",
       c2000.P0010001 AS "2000 pop",
       c2010.P0010001 - c2000.P0010001 AS "Raw change",
       round( (CAST(c2010.P0010001 AS DECIMAL(8,1)) - c2000.P0010001)
           / c2000.P0010001 * 100, 1 ) AS "Pct. change"
FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
ON c2010.state = c2000.state AND c2010.county = c2000.county
ORDER BY "Pct. change" ASC;

--------------
-- Chapter 7
--------------

-- Consider the following two tables, part of a database you’re making to keep track of your vinyl LP collection.
-- You start by sketching out these CREATE TABLE statements:

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
-- plus additional constraints on both tables. Explain why you made your choices.

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


-- 2. Instead of using album_id as a surrogate key for your primary key, are there
-- any columns in albums that could be useful as a natural key? What would you have to
-- know to decide?

-- We could consider the album_catalog_code. We would have to answer yes to these
-- questions:
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

-- 1. We saw that library visits have declined in most places. What about the use of technology
-- in libraries? Both the 2014 and 2009 library survey tables contain the columns gpterms
-- (the number of Internet computers used by the public) and pitusr (uses of public internet
-- computers per year). Modify the code in Listing 8-12 to calculate the percent change in the
-- sum of each column over time. (And watch out for negative values!)


-- sum() gpterms (computer terminals) by state, add pct. change, and sort

SELECT pls14.stabr,
       sum(pls14.gpterms) AS "gpterms_2014",
       sum(pls09.gpterms) AS "gpterms_2009",
       round( (CAST(sum(pls14.gpterms) AS decimal(10,1)) - sum(pls09.gpterms)) /
                    sum(pls09.gpterms) * 100, 2 ) AS "Pct. Chg."
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.gpterms >= 0 AND pls09.gpterms >= 0
GROUP BY pls14.stabr
ORDER BY "Pct. Chg." DESC;

-- sum() pitusr (uses of public internet computers per year) by state, add pct. change, and sort

SELECT pls14.stabr,
       sum(pls14.pitusr) AS "pitusr_2014",
       sum(pls09.pitusr) AS "pitusr_2009",
       round( (CAST(sum(pls14.pitusr) AS decimal(10,1)) - sum(pls09.pitusr)) /
                    sum(pls09.pitusr) * 100, 2 ) AS "Pct. Chg."
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.pitusr >= 0 AND pls09.pitusr >= 0
GROUP BY pls14.stabr
ORDER BY "Pct. Chg." DESC;


-- 2. Both library survey tables contain a column called obereg, a two-digit Bureau of Economic
-- Analysis Code that classifies each library agency according to a region of the United States:
-- New England, Rocky Mountains, etc. Just as we calculated the percent change in visits and
-- grouped by state, do the same for U.S. regions using obereg. To find the meaning of each
-- code, consult the survey documentation. For a bonus, create a new table with the obereg code
-- as the primary key and the region name as text, and join it to the summary query to
-- group by the region name rather than the code.

-- sum() visits by region.

SELECT pls14.obereg,
       sum(pls14.visits) AS "visits_2014",
       sum(pls09.visits) AS "visits_2009",
       round( (CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits)) /
                    sum(pls09.visits) * 100, 2 ) AS "Pct. Chg."
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.visits >= 0 AND pls09.visits >= 0
GROUP BY pls14.obereg
ORDER BY "Pct. Chg." DESC;

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
                    sum(pls09.visits) * 100, 2 ) AS "Pct. Chg."
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
   ON pls14.fscskey = pls09.fscskey
JOIN obereg_codes
   ON pls14.obereg = obereg_codes.obereg
WHERE pls14.visits >= 0 AND pls09.visits >= 0
GROUP BY obereg_codes.region
ORDER BY "Pct. Chg." DESC;


-- 3. Thinking back to the types of joins you learned in Chapter 6, which join type will
-- show you all the rows in both tables, including the ones where there’s no match? Write
-- such a query, and add an IS NULL filter in a WHERE clause to easily show agencies
-- not in one or the other table.

SELECT pls14.libname, pls14.city, pls14.stabr, pls14.statstru, pls14.c_admin, pls14.branlib,
       pls09.libname, pls09.city, pls09.stabr, pls09.statstru, pls09.c_admin, pls09.branlib
FROM pls_fy2014_pupld14a pls14 FULL OUTER JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.libname IS NULL;

--------------
-- Chapter 9
--------------

-- This chapter’s exercise focuses on turning this simple table into useful
-- information. We want to answer two simple questions: How many of the
-- companies in the table process meat, and how many process poultry?

-- Create two new columns in your table: meat_processing and poultry_processing.
-- Each can be of the type varchar(1).
-- Update the meat_processing column to contain a Y (for yes) on any row where the
-- activities column contains the text Meat Processing. Do the same update on the
-- poultry_processing column, this time looking for the text Poultry Processing
-- in activities.

-- Use the data in the new, updated columns to count how many companies perform
-- each type of activity. As a bonus, count how many companies perform both activities.


-- Add the columns
ALTER TABLE meat_poultry_egg_inspect ADD COLUMN meat_processing varchar(1);
ALTER TABLE meat_poultry_egg_inspect ADD COLUMN poultry_processing varchar(1);

-- Update the columns
UPDATE meat_poultry_egg_inspect
SET meat_processing = 'Y'
WHERE activities ILIKE '%meat processing%';

UPDATE meat_poultry_egg_inspect
SET poultry_processing = 'Y'
WHERE activities ILIKE '%poultry processing%';

-- Count meat and poultry processors
SELECT count(meat_processing), count(poultry_processing)
FROM meat_poultry_egg_inspect;

-- Count those who do both
SELECT count(*)
FROM meat_poultry_egg_inspect
WHERE meat_processing = 'Y' AND
      poultry_processing = 'Y';

--------------
-- Chapter 10
--------------

-- 1. Using Listing 10-2, we saw that the correlation coefficient, or r-value, of
-- the variables pct_bachelors_higher and median_hh_income was about .68. Now
-- write a query to show the correlation between pct_masters_higher and median_hh_income.
-- Is the r-value higher or lower? What might explain the difference?

SELECT
    round(
    corr(median_hh_income, pct_bachelors_higher)::numeric, 2
    ) AS bachelors_income_r,
    round(
    corr(median_hh_income, pct_masters_higher)::numeric, 2
    ) AS masters_income_r
FROM acs_2011_2015_stats;

-- The r-value of pct_bachelors_higher and median_hh_income is about .57, which shows a
-- smaller connection between percent master's degree or higher and income than
-- percent bachelor's degree or higher and income. It may be that attaining a master's
-- degree or higher has a more incremental impact on earnings than a four-year degree.

-- 2. Which cities with a population of 500,000 or more have the highest rates of motor
-- vehicle thefts (variable motor_vehicle_theft)? Which have the highest violent crime
-- rates (violent_crime)?  Include add a rank() function in your queries.

SELECT
    city,
    st,
    population,
    motor_vehicle_theft,
    round(
        (motor_vehicle_theft::numeric / population) * 100000, 1
         ) AS vehicle_theft_per_100000,
    rank() OVER (ORDER BY (motor_vehicle_theft::numeric / population) * 100000 DESC)
FROM fbi_crime_data_2015
WHERE population >= 500000;

-- Milwaukee and Albuquerque are No. 1 and No. 2.

SELECT
    city,
    st,
    population,
    violent_crime,
    round(
        (violent_crime::numeric / population) * 100000, 1
         ) AS violent_crime_per_100000,
    rank() OVER (ORDER BY (violent_crime::numeric / population) * 100000 DESC)
FROM fbi_crime_data_2015
WHERE population >= 500000;

-- Detroit and Memphis are No. 1 and No. 2.

-- 3. As a bonus, revisit the libraries data (table pls_fy2014_pupld14a) from
-- Chapter 8. Rank library agencies based on the rate of visits per 1,000 population
-- (column popu_lsa), and limit the query to agencies serving 250,000 people or more.

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

-- Cuyahoga County Public Library tops the rankings with 12,963 visits per thousand people.
