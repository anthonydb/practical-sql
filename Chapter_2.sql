----------------------------------------------
-- Dig Through Data With SQL
-- by Anthony DeBarros

-- Chapter 2 Code Examples
----------------------------------------------

-------------------------------------------
-- Listing 2-1: Querying all rows and columns from the teachers table

SELECT * FROM teachers;

-------------------------------------------
-- Listing 2-2: Querying a subset of columns

SELECT first_name, last_name, salary FROM teachers;

-------------------------------------------
-- Listing 2-3: Querying distinct values in the school column

SELECT DISTINCT school
FROM teachers;

-------------------------------------------
-- Listing 2-4: Querying distinct pairs of values in the scool and salary columns

SELECT DISTINCT school, salary
FROM teachers;

-------------------------------------------
-- Listing 2-5: Sorting a column with ORDER BY

SELECT first_name, last_name, salary
FROM teachers
ORDER BY salary DESC;

-------------------------------------------
-- Listing 2-6: Sorting multiple columns with ORDER BY

SELECT last_name, school, hire_date
FROM teachers
ORDER BY school ASC, hire_date DESC;

-------------------------------------------
-- Listing 2-7: Filtering rows using WHERE

SELECT first_name, last_name, school
FROM teachers
WHERE school = 'Myers Middle School';


-------------------------------------------
-- WHERE comparison operators

/* teachers with first name of Janet  */

SELECT first_name, last_name, school
FROM teachers
WHERE first_name = 'Janet';

/* school names not equal to F.D. Roosevelt HS */

SELECT school
FROM teachers
WHERE school != 'F.D. Roosevelt HS';

/* teachers hired before Jan. 1, 2000 */

SELECT first_name, last_name, hire_date
FROM teachers
WHERE hire_date < '1/1/2000';

/* teachers earning 43,500 or more */

SELECT first_name, last_name, salary
FROM teachers
WHERE salary >= 43500;

/* Teachers who earn between $30,000 and $40,000  */

SELECT first_name, last_name, school, salary
FROM teachers
WHERE salary BETWEEN 30000 AND 40000;

----------------------------------------
-- Listing 2-8: Filtering with LIKE AND ILIKE

SELECT first_name
FROM teachers
WHERE first_name LIKE 'sam%';

SELECT first_name
FROM teachers
WHERE first_name ILIKE 'sam%';


-------------------------------------------
-- Listing 2-9: SELECT statement with WHERE and ORDER BY

SELECT first_name, last_name, school, hire_date, salary
FROM teachers
WHERE school LIKE '%Roos%'
ORDER BY hire_date DESC;
