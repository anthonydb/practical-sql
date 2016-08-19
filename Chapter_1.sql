----------------------------------------------
-- Dig Through Data With SQL
-- by Anthony DeBarros

-- Chapter 1 Code Examples
----------------------------------------------

-------------------------------------------
-- 1-1: Create a database

CREATE DATABASE analysis;


-------------------------------------------
-- 1-2: Create a table

CREATE TABLE teachers (
    id serial,
    first_name varchar(25),
    last_name varchar(50),
    school varchar(50),
    hire_date date,
    salary decimal
);

-- DROP TABLE teachers;

-------------------------------------------
-- 1-3 Insert rows into a table

INSERT INTO teachers (first_name, last_name, school, hire_date, salary) 
VALUES ('Janet', 'Smith', 'F.D. Roosevelt HS', '2011-10-30', 36200),
       ('Lee', 'Reynolds', 'F.D. Roosevelt HS', '1993-5-22', 65000),
       ('Samuel', 'Cole', 'Myers Middle School', '2005-8-1', 43500),
       ('Samantha', 'Lee', 'Myers Middle School', '2011-10-30', 36200),
       ('Betty', 'Diaz', 'Myers Middle School', '2005-08-30', 43500),
       ('Kathleen', 'Roush', 'F.D. Roosevelt HS', '2010-10-22', 38500);

 
-- Try It Yourself

-- 1. Imagine you're building a database to catalog all the animals at your local zoo. You want one table for tracking all the kinds of animals and another table to track the specifics on each animal. Write CREATE TABLE statements for each table that include some of the columns you need. Why did you include the columns you chose? 

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

 -- 2. Now create INSERT statements to load sample data into the tables. How does the SQL syntax differ for handling text, numbers and dates?

INSERT INTO animal_types (common_name, scientific_name, conservation_status)
VALUES ('Bengal Tiger', 'Panthera tigris tigris', 'Endangered'),
       ('Arctic Wolf', 'Canis lupus arctos', 'Least Concern');
-- source: https://www.worldwildlife.org/species/directory?direction=desc&sort=extinction_status

INSERT INTO menagerie (animal_type_id, date_acquired, gender, acquired_from, name, notes)
VALUES
(1, '3/12/1996', 'F', 'Dhaka Zoo', 'Ariel', 'Healthy coat at last exam.'),
(2, '9/30/2000', 'F', 'National Zoo', 'Freddy', 'Strong appetite.');



