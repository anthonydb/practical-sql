----------------------------------------------
-- Dig Through Data with SQL
-- by Anthony DeBarros

-- Chapter 3 Code Examples
----------------------------------------------

-- Listing 3-1: Character data types in action

CREATE TABLE char_data_types (
    varchar_column varchar(10),
    char_column char(10),
    text_column text
);

INSERT INTO char_data_types
VALUES
    ('abc', 'abc', 'abc'),
    ('defghi', 'defghi', 'defghi');

COPY char_data_types TO '/Users/adebarros/Desktop/typetest.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');


-- Listing 3-2: Demonstrate number data types

CREATE TABLE number_data_types (
    decimal_column decimal(20,5),
    real_column real,
    double_column double precision
);

INSERT INTO number_data_types
VALUES
    (.7, .7, .7),
    (2.13579, 2.13579, 2.13579),
    (2.1357987654, 2.1357987654, 2.1357987654);

SELECT * FROM number_data_types;


-- Listing 3-3: Rounding issues with float columns
-- Assumes table created and loaded with Listing 3-2

SELECT
    decimal_column * 10000000 AS "Fixed",
    real_column * 10000000 AS "Float"
FROM number_data_types
WHERE decimal_column = .7;


-- Listing 3-4: Date and Time types

CREATE TABLE date_time_types (
    timestamp_column timestamp,
    date_column date,
    time_column time,
    interval_column interval
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
    date_column,
    interval_column,
    date_column - interval_column AS "new_date"
FROM date_time_types;

-- Listing 3-6: Three CAST() examples

SELECT timestamp_column, CAST(timestamp_column AS varchar(10)) FROM date_time_types;

SELECT decimal_column,
       CAST(decimal_column AS integer),
       CAST(decimal_column AS varchar(6))
FROM number_data_types;

-- Does not work:
SELECT CAST(char_column AS integer) FROM char_data_types;

-- Alternate notation for CAST is the double-colon:
SELECT timestamp_column::varchar(10)
FROM date_time_types;
