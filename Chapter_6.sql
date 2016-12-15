----------------------------------------------
-- Dig Through Data with SQL
-- by Anthony DeBarros

-- Chapter 6 Code Examples
----------------------------------------------

-- Listing 6-1: CREATE departments and employees tables

CREATE TABLE departments (
    dept_id bigserial,
    dept varchar(100),
    city varchar(100),
    CONSTRAINT dept_key PRIMARY KEY (dept_id)
);

CREATE TABLE employees (
    emp_id bigserial,
    first_name varchar(100),
    last_name varchar(100),
    salary integer,
    dept_id integer,
    CONSTRAINT emp_key PRIMARY KEY (emp_id)
);

INSERT INTO departments (dept, city)
VALUES
    ('Tax', 'Atlanta'),
    ('IT', 'Boston');

INSERT INTO employees (first_name, last_name, salary, dept_id)
VALUES
    ('Nancy', 'Jones', 62500, 1),
    ('Lee', 'Smith', 59300, 1),
    ('Soo', 'Nguyen', 83000, 2),
    ('Janet', 'King', 95000, 2);

-- Listing 6-2: Basic JOIN

SELECT *
FROM employees JOIN departments
ON employees.dept_id = departments.dept_id;

-- Listing 6-3: Creating two tables to explore JOIN types

CREATE TABLE schools_left (
    id integer CONSTRAINT left_id_key PRIMARY KEY,
    left_school varchar(30)
);

CREATE TABLE schools_right (
    id integer CONSTRAINT right_id_key PRIMARY KEY,
    right_school varchar(30)
);

INSERT INTO schools_left (id, left_school) VALUES
    (1, 'Oak Street School'),
    (2, 'Roosevelt High School'),
    (5, 'Washington Middle School'),
    (6, 'Jefferson High School');

INSERT INTO schools_right (id, right_school) VALUES
    (1, 'Oak Street School'),
    (2, 'Roosevelt High School'),
    (3, 'Morrison Elementary'),
    (4, 'Chase Magnet Academy'),
    (6, 'Jefferson High School');

-- Listing 6-4: JOIN

SELECT *
FROM schools_left JOIN schools_right
ON schools_left.id = schools_right.id;

-- Listing 6-5: LEFT JOIN

SELECT *
FROM schools_left LEFT JOIN schools_right
ON schools_left.id = schools_right.id;

-- Listing 6-6: RIGHT JOIN

SELECT *
FROM schools_left RIGHT JOIN schools_right
ON schools_left.id = schools_right.id;


-- Listing 6-7: FULL OUTER JOIN

SELECT *
FROM schools_left FULL OUTER JOIN schools_right
ON schools_left.id = schools_right.id;

-- Listing 6-8: CROSS JOIN

SELECT *
FROM schools_left CROSS JOIN schools_right;

-- Listing 6-9: Filtering to show missing values with IS NULL

SELECT *
FROM schools_left LEFT JOIN schools_right
ON schools_left.id = schools_right.id
WHERE schools_right.id IS NULL;

-- Listing 6-10: Querying specific columns in a join
SELECT schools_left.id AS "left_id", schools_left.left_school, schools_right.right_school
FROM schools_left LEFT JOIN schools_right
ON schools_left.id = schools_right.id;

-- Listing 6-11: Simplifying code with table aliases
SELECT l.id, l.left_school, r.right_school
FROM schools_left l LEFT JOIN schools_right r
ON l.id = r.id;

-- Listing 6-12: Joining multiple tables
CREATE TABLE schools_enrollment (
	id integer,
	enrollment integer
);

CREATE TABLE schools_grades (
	id integer,
	grades varchar(10)
);

INSERT INTO schools_enrollment (id, enrollment)
VALUES
	(1, 360),
	(2, 1001),
	(5, 450),
	(6, 927);

INSERT INTO schools_grades (id, grades)
VALUES
	(1, 'K-3'),
	(2, '9-12'),
	(5, '6-8'),
	(6, '9-12');

SELECT l.id, l.left_school, en.enrollment, gr.grades
FROM schools_left l LEFT JOIN schools_enrollment en
    ON l.id = en.id
LEFT JOIN schools_grades gr
    ON l.id = gr.id;

-- Listing 6-13: Performing math on joined Census tables

CREATE TABLE us_counties_2000 (
    state varchar(2), 	   -- State FIPS code
    county varchar(3), 	   -- County code
    geography varchar(90), -- County/state name,
    P0010001 integer, 	   -- Total population
    P0010002 integer, 	   -- Population of one race:
    P0010003 integer,        -- White Alone
    P0010004 integer,        -- Black or African American alone
    P0010005 integer,        -- American Indian and Alaska Native alone
    P0010006 integer,        -- Asian alone
    P0010007 integer,        -- Native Hawaiian and Other Pacific Islander alone
    P0010008 integer,        -- Some Other Race alone
    P0010009 integer       -- Two or more races
);

COPY us_counties_2000
-- FROM 'C:\YourDirectory\us_counties_2000.csv'
FROM '/Users/adebarros/Dropbox/DataMonky/Book-Writing/DigThroughDataWithSQL/Data/us_counties_2000.csv'
WITH (FORMAT CSV, HEADER);

SELECT c2010.name,
       c2010.stusab,
       c2010.P0010001 AS "2010 pop",
       c2000.P0010001 AS "2000 pop",
       c2010.P0010001 - c2000.P0010001 AS "Raw change",
       round( (CAST(c2010.P0010001 AS DECIMAL(8,1)) - c2000.P0010001)
           / c2000.P0010001 * 100, 1 ) AS "Pct. change"
FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
ON c2010.state = c2000.state AND c2010.county = c2000.county
ORDER BY "Pct. change" DESC;
