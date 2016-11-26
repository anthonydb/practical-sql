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
   animal_type_id serial,
   common_name varchar(100),
   scientific_name varchar(100),
   conservation_status varchar(50)
);

CREATE TABLE menagerie (
   animal_id serial,
   animal_type_id integer,
   date_acquired date,
   gender char(1),
   acquired_from varchar(100),
   name varchar(100),
   notes text
);

-- 2. Now create INSERT statements to load sample data into the tables. How does
-- the SQL syntax differ for handling text, numbers and dates?

INSERT INTO animal_types (common_name, scientific_name, conservation_status)
VALUES ('Bengal Tiger', 'Panthera tigris tigris', 'Endangered'),
      ('Arctic Wolf', 'Canis lupus arctos', 'Least Concern');
-- source: https://www.worldwildlife.org/species/directory?direction=desc&sort=extinction_status

INSERT INTO menagerie (animal_type_id, date_acquired, gender, acquired_from, name, notes)
VALUES
(1, '3/12/1996', 'F', 'Dhaka Zoo', 'Ariel', 'Healthy coat at last exam.'),
(2, '9/30/2000', 'F', 'National Zoo', 'Freddy', 'Strong appetite.');


--------------
-- Chapter 2
--------------

-- 1. Write a query that lists the schools in alphabetical order along
-- with teachers ordered by last name A-Z.

SELECT school, first_name, last_name
FROM teachers
ORDER BY school, last_name;

-- 2. Explore how PostgreSQL sorts characters. Create a table called sort_test
-- with a varchar(10) column called values. Insert the following strings:
-- Alvin, alex, 1990, @twitter. When you query the column and sort values
-- ascending, what order will the strings appear? Why?

CREATE TABLE sort_test (
values varchar(10)
);

INSERT INTO sort_test
VALUES
('Alvin'),
('alex'),
('1990'),
('@twitter');

SELECT values FROM sort_test ORDER BY values;

-- 3. Find the one teacher whose name both starts with the letter
-- S and who earns more than $40,000.

SELECT first_name, last_name, school, salary
FROM teachers
WHERE first_name LIKE 'S%' AND salary > 40000;


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


-- 2. Instead of using album_id as a surrogate key for your primary key, would any
-- columns in albums potentially be useful as a natural key? What would you have to
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
