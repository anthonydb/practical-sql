----------------------------------------------
-- Dig Through Data With SQL
-- by Anthony DeBarros

-- Chapter 11 Code Examples
----------------------------------------------

-- Listing 11-1: Extracting components of a timestamp

SELECT
    date_part('year', '2016-12-01 18:37:12-05'::timestamptz) AS "year",
    date_part('month', '2016-12-01 18:37:12-05'::timestamptz) AS "month",
    date_part('day', '2016-12-01 18:37:12-05'::timestamptz) AS "day",
    date_part('hour', '2016-12-01 18:37:12-05'::timestamptz) AS "hour",
    date_part('minute', '2016-12-01 18:37:12-05'::timestamptz) AS "minute",
    date_part('seconds', '2016-12-01 18:37:12-05'::timestamptz) AS "seconds",
    date_part('timezone_hour', '2016-12-01 18:37:12-05'::timestamptz) AS "tz",
    date_part('week', '2016-12-01 18:37:12-05'::timestamptz) AS "week",
    date_part('quarter', '2016-12-01 18:37:12-05'::timestamptz) AS "quarter",
    date_part('epoch', '2016-12-01 18:37:12-05'::timestamptz) AS "epoch";

-- Listing 11-2: Constructing datetimes from components

-- make a date
SELECT make_date(2018, 2, 22);
-- make a time
SELECT make_time(18, 4, 30.3);
-- make a timestamp with time zone
SELECT make_timestamptz(2018, 2, 22, 18, 4, 30.3, 'Europe/Lisbon');

-- Bonus: Retrieving the current date and time

SELECT
    current_date,
    current_time,
    current_timestamp,
    localtime,
    localtimestamp,
    now();

-- Listing 11-3: Capturing the current time during row insert

CREATE TABLE current_time_example (
    time_id bigserial,
    insert_time timestamp with time zone
);

INSERT INTO current_time_example (insert_time)
VALUES (now());

SELECT * FROM current_time_example;

-- Time Zones

-- Listing 11-4: Show your PostgreSQL server's default time zone

SHOW timezone;
-- Note: You can see all run-time defaults with SHOW ALL;


-- Listing 11-5: Show time zone abbreviations and names

SELECT * FROM pg_timezone_abbrevs;
SELECT * FROM pg_timezone_names;

-- Filter to find one
SELECT * FROM pg_timezone_names
WHERE name LIKE 'Europe%';

-- Listing 11-6: Setting the time zone for a session

SET timezone TO 'US/Pacific';

CREATE TABLE time_zone_test (
    test_date timestamp with time zone
);
INSERT INTO time_zone_test VALUES ('2020-01-01 4:00');

SELECT test_date
FROM time_zone_test;

SET timezone TO 'US/Eastern';

SELECT test_date
FROM time_zone_test;

SELECT test_date AT TIME ZONE 'Asia/Seoul'
FROM time_zone_test;


-- Math with dates!

SELECT '9/30/1929'::date - '9/27/1929'::date;
SELECT '9/30/1929'::date + '5 years'::interval;



-- Taxi Rides

-- Listing 11-7: Create table and import NYC yellow taxi data

CREATE TABLE nyc_yellow_taxi_trips_2016_06_01 (
    trip_id bigserial PRIMARY KEY,
    vendor_id varchar(1) NOT NULL,
    tpep_pickup_datetime timestamp with time zone NOT NULL,
    tpep_dropoff_datetime timestamp with time zone NOT NULL,
    passenger_count integer NOT NULL,
    trip_distance numeric(8,2) NOT NULL,
    pickup_longitude numeric(18,15) NOT NULL,
    pickup_latitude numeric(18,15) NOT NULL,
    rate_code_id varchar(2) NOT NULL,
    store_and_fwd_flag varchar(1) NOT NULL,
    dropoff_longitude numeric(18,15) NOT NULL,
    dropoff_latitude numeric(18,15) NOT NULL,
    payment_type varchar(1) NOT NULL,
    fare_amount numeric(9,2) NOT NULL,
    extra numeric(9,2) NOT NULL,
    mta_tax numeric(5,2) NOT NULL,
    tip_amount numeric(9,2) NOT NULL,
    tolls_amount numeric(9,2) NOT NULL,
    improvement_surcharge numeric(9,2) NOT NULL,
    total_amount numeric(9,2) NOT NULL
);

COPY nyc_yellow_taxi_trips_2016_06_01 (
    vendor_id,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    passenger_count,
    trip_distance,
    pickup_longitude,
    pickup_latitude,
    rate_code_id,
    store_and_fwd_flag,
    dropoff_longitude,
    dropoff_latitude,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount
   )
FROM 'C:\YourDirectory\yellow_tripdata_2016_06_01.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

CREATE INDEX tpep_pickup_idx ON nyc_yellow_taxi_trips_2016_06_01 (tpep_pickup_datetime);

SELECT count(*) FROM nyc_yellow_taxi_trips_2016_06_01;

-- Listing 11-8: Count taxi trips by hour

SELECT
    date_part('hour', tpep_pickup_datetime),
    count(date_part('hour', tpep_pickup_datetime))
FROM nyc_yellow_taxi_trips_2016_06_01
GROUP BY date_part('hour', tpep_pickup_datetime)
ORDER BY date_part('hour', tpep_pickup_datetime);

-- Listing 11-9: Export taxi pickups per hour to CSV

COPY
    (SELECT
        date_part('hour', tpep_pickup_datetime),
        count(date_part('hour', tpep_pickup_datetime))
    FROM nyc_yellow_taxi_trips_2016_06_01
    GROUP BY date_part('hour', tpep_pickup_datetime)
    ORDER BY date_part('hour', tpep_pickup_datetime))
TO 'C:\YourDirectory\hourly_pickups_2016_06_01.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

-- Listing 11-10: Calculate median trip time by hour

SELECT
    date_part('hour', tpep_pickup_datetime),
    median(
        date_part('epoch', tpep_dropoff_datetime - tpep_pickup_datetime)
           ) * interval '1 second' AS "median_trip"
FROM nyc_yellow_taxi_trips_2016_06_01
GROUP BY date_part('hour', tpep_pickup_datetime)
ORDER BY date_part('hour', tpep_pickup_datetime);

-- Listing 11-11: Create table to hold train trip data

SET timezone TO 'US/Central';

CREATE TABLE train_rides (
    trip_id bigserial PRIMARY KEY,
    segment varchar(50) NOT NULL,
    departure timestamp with time zone NOT NULL,
    arrival timestamp with time zone NOT NULL
);

INSERT INTO train_rides (segment, departure, arrival)
VALUES
    ('Chicago to New York', '2017-11-13 21:30 CST', '2017-11-14 18:23 EST'), -- 19:53
    ('New York to New Orleans', '2017-11-15 14:15 EST', '2017-11-16 19:32 CST'), -- 30:17
    ('New Orleans to Los Angeles', '2017-11-17 13:45 CST', '2017-11-18 9:00 PST'), -- 21:15
    ('Los Angeles to San Francisco', '2017-11-19 10:10 PST', '2017-11-19 21:24 PST'), -- 11:14
    ('San Francisco to Denver', '2017-11-20 9:10 PST', '2017-11-21 18:38 MST'), -- 32:28
    ('Denver to Chicago', '2017-11-22 19:10 MST', '2017-11-23 14:50 CST'); -- 18:40

SELECT * FROM train_rides;

-- Listing 11-12: Calculate the length of each trip segment

SELECT segment,
       to_char(departure, 'YYYY-MM-DD HH12:MI a.m. TZ') AS "departure",
       arrival - departure AS "segment_time"
FROM train_rides;

-- Listing 11-13: Calculating cumulative intervals with OVER

SELECT segment,
       arrival - departure AS "segment_time",
       sum(arrival - departure) OVER (ORDER BY trip_id) as cume_time
FROM train_rides;

-- Listing 11-14: Better formatting for cumulative trip time

SELECT segment,
       arrival - departure AS "segment_time",
       sum(date_part('epoch', (arrival - departure)))
           OVER (ORDER BY trip_id) * interval '1 second' AS "cume_time"
FROM train_rides;
