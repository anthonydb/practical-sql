----------------------------------------------
-- Dig Through Data with SQL
-- by Anthony DeBarros

-- Chapter 3 Code Examples
----------------------------------------------

-- Listing 3-1: Character data types in action

CREATE TABLE char_data_types (
    varchar_field varchar(10),
    char_field char(10),
    text_field text
);

INSERT INTO char_data_types
VALUES
    ('abc', 'abc', 'abc'),
    ('defghi', 'defghi', 'defghi');

COPY char_data_types TO '/Users/adebarros/Desktop/typetest.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');


-- Listing 3-2: Demonstrate number data types

CREATE TABLE number_data_types (
    decimal_field decimal(20,5),
    real_field real,
    double_field double precision
);

INSERT INTO number_data_types
VALUES
    (.7, .7, .7),
    (2.13579, 2.13579, 2.13579),
    (2.1357987654, 2.1357987654, 2.1357987654);

SELECT * FROM number_data_types;


-- Listing 3-3: Rounding issues
-- Assumes table created and loaded with Listing 3-2

SELECT
    decimal_field * 10000000 AS "Fixed",
    real_field * 10000000 AS "Float"
FROM number_data_types
WHERE decimal_field = .7;


-- Listing 3-4: Date and Time types

CREATE TABLE date_time_types (
    timestamp_field timestamp,
    date_field date,
    time_field time,
    interval_field interval
);

INSERT INTO date_time_types
VALUES
    ('12/31/2016','12/31/2016','08:00','2 days'),
    ('12/31/2016 18:16','1/1/2016','23:59','1 month'),
    ('7/3/2016 8:53','7/3/2016','8:53','1 year 1 hour'),
    ('10/20/2000','10/20/2000','18:00','1 century'),
    (now(),now(),now(),'1 week');

SELECT * FROM date_time_types;


-- Listing 3-5: Using the interval data type
-- Assumes script 3-4 has been run

SELECT
    date_field,
    interval_field,
    date_field - interval_field AS "new_date"
FROM date_time_types;

-- Listing 3-6: Three CAST() examples

SELECT timestamp_field, CAST(timestamp_field AS varchar(10)) FROM date_time_types;

SELECT decimal_field,
       CAST(decimal_field AS integer),
       CAST(decimal_field AS varchar(6))
FROM number_data_types;

-- Does not work:
SELECT CAST(char_field AS integer) FROM char_data_types;

-- Alternate notation for CAST is the double-colon:
SELECT timestamp_field::varchar(10)
FROM date_time_types;
	
