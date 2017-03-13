----------------------------------------------
-- Dig Through Data with SQL
-- by Anthony DeBarros

-- Chapter 5 Code Examples
----------------------------------------------

-- Listing 5-1: Basic addition, subtraction and multiplication with SQL

SELECT 2 + 2;    -- addition
SELECT 9 - 1;    -- subtraction
SELECT 3 * 4;    -- multiplication

-- Listing 5-2: Integer and decimal division with SQL

SELECT 11 / 6;   -- integer division
SELECT 11 % 6;   -- modulo division
SELECT 11.0 / 6; -- decimal division
SELECT CAST (11 AS decimal(3,1)) / 6;

-- Listing 5-3: Exponents, roots and factorials with SQL

SELECT 3 ^ 4;    -- exponentiation
SELECT |/ 10;    -- square root (operator)
SELECT sqrt(10); -- square root (function)
SELECT ||/ 10;   -- cube root
SELECT 4 !;      -- factorial

-- Order of operations

SELECT 7 + 8 * 9; 	-- answer: 79
SELECT (7 + 8) * 9;	-- answer: 135

-- Listing 5-4: Selecting Census population columns by race with aliases

SELECT geo_name,
       state_us_abbreviation,
       p0010001 AS "Total Population",
       p0010003 AS "White Alone",
       p0010004 AS "Black Alone",
       p0010005 AS "Am Indian/Alaska Native Alone",
       p0010006 AS "Asian Alone",
       p0010007 AS "Native Hawaiian and Other Pacific Islander Alone",
       p0010008 AS "Some Other Race Alone",
       p0010009 AS "Two or More Races"
FROM us_counties_2010;

-- Listing 5-5: Adding two columns in Census data

SELECT geo_name,
       state_us_abbreviation,
       p0010003 AS "White Alone",
       p0010004 AS "Black Alone",
       p0010003 + p0010004 AS "Total White and Black"
FROM us_counties_2010;

-- Listing 5-6: Check Census race column totals

SELECT geo_name,
       state_us_abbreviation,
       p0010001 AS "Total",
       p0010003 + p0010004 + p0010005 + p0010006 + p0010007
           + p0010008 + p0010009 AS "All Races",
       (p0010003 + p0010004 + p0010005 + p0010006 + p0010007
           + p0010008 + p0010009) - p0010001 AS "Difference"
FROM us_counties_2010
ORDER BY "Difference" DESC;

-- Listing 5-7: Calculate percent of population that is Asian by county (percent of the whole)

SELECT geo_name,
       state_us_abbreviation,
       (CAST (p0010006 AS numeric(8,1)) / p0010001) * 100 AS "Pct Asian"
FROM us_counties_2010
ORDER BY "Pct Asian" DESC;


-- Listing 5-8: Calculating percent change

CREATE TABLE percent_change (
    department varchar(20),
    spend_2014 integer,
    spend_2017 integer
);

INSERT INTO percent_change
VALUES
    ('Building', 250000, 289000),
    ('Assessor', 178556, 179500),
    ('Library', 87777, 90001),
    ('Clerk', 451980, 650000),
    ('Police', 250000, 223000),
    ('Recreation', 199000, 195000);

SELECT department,
       spend_2014,
       spend_2017,
       round( (CAST(spend_2017 AS numeric(10,1)) - spend_2014) /
                    spend_2014 * 100, 1 )
FROM percent_change;

-- DROP TABLE percent_change;


-- Listing 5-9: Using sum() and avg() aggregate functions

SELECT sum(p0010001) AS "County Sum",
       round(avg(p0010001), 0) AS "County Average"
FROM us_counties_2010;


-- Listing 5-10: Create a median() aggregate function

CREATE OR REPLACE FUNCTION _final_median(anyarray)
   RETURNS float8 AS
$$
  WITH q AS
  (
     SELECT val
     FROM unnest($1) val
     WHERE VAL IS NOT NULL
     ORDER BY 1
  ),
  cnt AS
  (
    SELECT COUNT(*) AS c FROM q
  )
  SELECT AVG(val)::float8
  FROM
  (
    SELECT val FROM q
    LIMIT  2 - MOD((SELECT c FROM cnt), 2)
    OFFSET GREATEST(CEIL((SELECT c FROM cnt) / 2.0) - 1,0)
  ) q2;
$$
LANGUAGE sql IMMUTABLE;

CREATE AGGREGATE median(anyelement) (
  SFUNC=array_append,
  STYPE=anyarray,
  FINALFUNC=_final_median,
  INITCOND='{}'
);

-- Listing 5-11: Using sum(), avg() and median() aggregate functions

SELECT sum(p0010001) AS "County Sum",
       round(avg(p0010001), 0) AS "County Average",
       median(p0010001) AS "County Median"
FROM us_counties_2010;

-- Listing 5-12: Testing SQL percentile functions

CREATE TABLE percentile_test (
    numbers integer
);

INSERT INTO percentile_test (numbers) VALUES
    (1), (2), (3), (4), (5), (6);

SELECT
    percentile_cont(.5)
    WITHIN GROUP (ORDER BY numbers),
    percentile_disc(.5)
    WITHIN GROUP (ORDER BY numbers)
FROM percentile_test;

-- Listing 5-13: Using percentile_cont() with Census data

SELECT sum(p0010001) AS "County Sum",
       round(avg(p0010001), 0) AS "County Average",
       median(p0010001) AS "County Median",
       percentile_cont(.5)
       WITHIN GROUP (ORDER BY p0010001) AS "50th Percentile"
FROM us_counties_2010;
