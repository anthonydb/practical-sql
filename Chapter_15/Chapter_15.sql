--------------------------------------------------------------
-- Practical SQL: A Beginner's Guide to Storytelling with Data
-- by Anthony DeBarros

-- Chapter 15 Code Examples
--------------------------------------------------------------

-- VIEWS

-- Listing 15-1: Create a view that displays Nevada 2010 counties

CREATE OR REPLACE VIEW nevada_counties_pop_2010 AS
    SELECT geo_name,
           state_fips,
           county_fips,
           p0010001 AS pop_2010
    FROM us_counties_2010
    WHERE state_us_abbreviation = 'NV'
    ORDER BY county_fips;

-- Listing 15-2: Querying the nevada_counties_pop_2010 view

SELECT *
FROM nevada_counties_pop_2010
LIMIT 5;

-- Listing 15-3: Create view showing population change for US counties

CREATE OR REPLACE VIEW county_pop_change_2010_2000 AS
    SELECT c2010.geo_name,
           c2010.state_us_abbreviation AS st,
           c2010.state_fips,
           c2010.county_fips,
           c2010.p0010001 AS pop_2010,
           c2000.p0010001 AS pop_2000,
           round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
               / c2000.P0010001 * 100, 1 ) AS pct_change_2010_2000
    FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
    ON c2010.state_fips = c2000.state_fips
       AND c2010.county_fips = c2000.county_fips
    ORDER BY c2010.state_fips, c2010.county_fips;

-- Listing 15-4: Selecting columns from the county_pop_change_2010_2000 view

SELECT geo_name,
       st,
       pop_2010,
       pct_change_2010_2000
FROM county_pop_change_2010_2000
WHERE st = 'NV'
LIMIT 5;

-- Listing 15-5: Create a view on the employees table

CREATE OR REPLACE VIEW employees_tax_dept AS
     SELECT emp_id,
            first_name,
            last_name,
            dept_id
     FROM employees
     WHERE dept_id = 1
     ORDER BY emp_id
     WITH LOCAL CHECK OPTION;

SELECT * FROM employees_tax_dept;

-- Listing 15-6: Successful and rejected inserts via the employees_tax_dept view

INSERT INTO employees_tax_dept (first_name, last_name, dept_id)
VALUES ('Suzanne', 'Legere', 1);

INSERT INTO employees_tax_dept (first_name, last_name, dept_id)
VALUES ('Jamil', 'White', 2);

SELECT * FROM employees_tax_dept;

SELECT * FROM employees;

-- Listing 15-7: Updating a row via the employees_tax_dept view

UPDATE employees_tax_dept
SET last_name = 'Le Gere'
WHERE emp_id = 5;

SELECT * FROM employees_tax_dept;

UPDATE employees_tax_dept
SET salary = 100000
WHERE emp_id = 5;

-- Listing 15-8: Deleting a row via the employees_tax_dept view

DELETE FROM employees_tax_dept
WHERE emp_id = 5;


-- FUNCTIONS
-- https://www.postgresql.org/docs/current/static/plpgsql.html

-- Listing 15-9: Creating a percent_change function
-- To delete this function: DROP FUNCTION percent_change(numeric,numeric,integer);

CREATE OR REPLACE FUNCTION
percent_change(new_value numeric,
               old_value numeric,
               decimal_places integer DEFAULT 1)
RETURNS numeric AS
$$
BEGIN
    RETURN
    round(
          ((new_value - old_value) / old_value) * 100, decimal_places
         );
END;
$$
LANGUAGE plpgsql;

-- Listing 15-10: Testing the percent_change() function

SELECT percent_change(110, 108);

-- Listing 15-11: Testing percent_change() on Census data

SELECT c2010.geo_name,
       c2010.state_us_abbreviation AS st,
       c2010.p0010001 AS pop_2010,
       percent_change(c2010.p0010001, c2000.p0010001) AS pct_chg_func,
       round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
           / c2000.p0010001 * 100, 1 ) AS pct_chg_formula
FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
ON c2010.state_fips = c2000.state_fips
   AND c2010.county_fips = c2000.county_fips
ORDER BY pct_chg_func DESC
LIMIT 5;

-- Listing 15-12: Add a column to the teachers table and see the data

ALTER TABLE teachers ADD COLUMN days_off integer;

SELECT first_name,
       last_name,
       hire_date,
       days_off
FROM teachers;

-- Listing 15-13: Create an update_days_off() function

CREATE OR REPLACE FUNCTION update_days_off()
RETURNS void AS $$
BEGIN
    UPDATE teachers
    SET days_off =
        CASE WHEN (now() - hire_date) BETWEEN '5 years'::interval
                                      AND '10 years'::interval THEN 4
             WHEN (now() - hire_date) > '10 years'::interval THEN 5
             ELSE 3
        END;
    RAISE NOTICE 'days_off updated!';
END;
$$ LANGUAGE plpgsql;

-- To run the function:
SELECT update_days_off();

-- Listing 15-14: Enable the PL/Python procedural language

CREATE EXTENSION plpythonu;

-- Listing 15-15: Using PL/Python in a function

CREATE OR REPLACE FUNCTION categorize_population(population numeric)
RETURNS text AS $$
    if population >= 100000:
        return 'big'
    else:
        return 'not big'
$$ LANGUAGE plpythonu;

-- Listing 15-16: Testing the categorize_population() function

SELECT geo_name,
       p0010001,
       categorize_population(p0010001)
FROM us_counties_2010
ORDER BY state_fips, county_fips
LIMIT 5;


-- TRIGGERS

-- Listing 15-17: Create the grades and grades_history tables

CREATE TABLE grades (
    student_id bigint,
    course_id bigint,
    course varchar(30) NOT NULL,
    grade varchar(5) NOT NULL,
PRIMARY KEY (student_id, course_id)
);

INSERT INTO grades
VALUES
    (1, 1, 'Biology 2', 'F'),
    (1, 2, 'English 11B', 'D'),
    (1, 3, 'World History 11B', 'C'),
    (1, 4, 'Trig 2', 'B');

CREATE TABLE grades_history (
    id bigserial,
    student_id bigint NOT NULL,
    course_id bigint NOT NULL,
    change_time timestamp with time zone NOT NULL,
    course varchar(30) NOT NULL,
    old_grade varchar(5) NOT NULL,
    new_grade varchar(5) NOT NULL,
PRIMARY KEY (id)
);

SELECT * FROM grades;

-- Listing 15-18: Create the record_if_grade_changed() function

CREATE OR REPLACE FUNCTION record_if_grade_changed()
    RETURNS trigger AS
$$
BEGIN
    IF NEW.grade <> OLD.grade THEN
    INSERT INTO grades_history (
        student_id,
        course_id,
        change_time,
        course,
        old_grade,
        new_grade)
    VALUES
        (OLD.student_id,
         OLD.course_id,
         now(),
         OLD.course,
         OLD.grade,
         NEW.grade);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Listing 15-19: Create the grades_update trigger

CREATE TRIGGER grades_update
  AFTER UPDATE
  ON grades
  FOR EACH ROW
  EXECUTE PROCEDURE record_if_grade_changed();

-- Listing 15-20: Testing the grades_update trigger

-- There are 0 records in the history
SELECT * FROM grades_history;

-- Update a grade
UPDATE grades
SET grade = 'C'
WHERE student_id = 1 AND course_id = 1;

-- Now check the history
SELECT student_id,
       change_time,
       course,
       old_grade,
       new_grade
FROM grades_history;

-- Listing 15-21: Create a temperature_test table

CREATE TABLE temperature_test (
    station_name varchar(50),
    observation_date date,
    max_temp integer,
    min_temp integer,
    max_temp_group varchar(40),
PRIMARY KEY (station_name, observation_date)
);

-- Listing 15-22: Create the classify_max_temp() function

CREATE OR REPLACE FUNCTION classify_max_temp()
    RETURNS trigger AS
$$
BEGIN
    CASE
       WHEN NEW.max_temp >= 90 THEN
           NEW.max_temp_group := 'Hot';
       WHEN NEW.max_temp BETWEEN 70 AND 89 THEN
           NEW.max_temp_group := 'Warm';
       WHEN NEW.max_temp BETWEEN 50 AND 69 THEN
           NEW.max_temp_group := 'Pleasant';
       WHEN NEW.max_temp BETWEEN 33 AND 49 THEN
           NEW.max_temp_group :=  'Cold';
       WHEN NEW.max_temp BETWEEN 20 AND 32 THEN
           NEW.max_temp_group :=  'Freezing';
       ELSE NEW.max_temp_group :=  'Inhumane';
    END CASE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Listing 15-23: Create the temperature_update trigger

CREATE TRIGGER temperature_insert
    BEFORE INSERT
    ON temperature_test
    FOR EACH ROW
    EXECUTE PROCEDURE classify_max_temp();

-- Listing 15-24: Insert rows to test the temperature_update trigger

INSERT INTO temperature_test (station_name, observation_date, max_temp, min_temp)
VALUES
    ('Rochester', '1/19/2017', 10, -3),
    ('Rochester', '3/20/2017', 28, 19),
    ('Rochester', '5/2/2017', 65, 42),
    ('Rochester', '8/9/2017', 93, 74);

SELECT * FROM temperature_test;
