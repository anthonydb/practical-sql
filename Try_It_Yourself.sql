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
-- what would be an appropriate data type for the mileage field in your
-- table. Why?

decimal(5,1)
-- Total five digits with one after the decimal, such as 1000.9.
-- Never assume people won't go beyond your assumptions!

-- 2. In the table listing each driver in your company, what are appropriate
-- data types for the drivers’ first and last names? Why is it a good idea to
-- separate first and last names into two fields rather than having one
-- larger name field?
varchar(50)
-- Separating first and last names will allow you later to sort on each.

-- 3. Assume you have a text field that includes strings formatted as dates.
-- One of the strings is written as '4//2017'. What will happen when you try
-- to convert that string to the data type of timestamp?
SELECT CAST('4//2017' AS timestamp);
-- Returns an error because the string is an invalid date format.


--------------
-- Chapter 4
--------------

-- 1. Write a WITH statement to include with COPY to handle the import of a
-- text file that has a first couple of rows that look like this:
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

-- 3. You're importing a file that contains a field with values such as these:
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
-- can you learn about that county that explains the relatively high American Indian population
-- compared with other New York counties?

-- Answer:
SELECT name,
       STUSAB,
       (CAST (P0010005 AS DECIMAL(8,1)) / P0010001) * 100 AS "Pct Am Indian/Alaska Native Alone"
FROM us_counties_2010
WHERE stusab = 'NY'
ORDER BY "Pct Am Indian/Alaska Native Alone" DESC;
-- Franklin County, N.Y., with 7.4%. The county contain the St. Regis Mohawk Reservation.

-- 3. Is median county population higher in California or New York?

-- Answer:
SELECT median(P0010001)
FROM us_counties_2010
WHERE stusab = 'NY';

SELECT median(P0010001)
FROM us_counties_2010
WHERE stusab = 'CA';
-- California has a median county population of 179,140.5, almost double that of New York, at 91,301.
