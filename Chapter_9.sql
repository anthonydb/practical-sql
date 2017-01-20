----------------------------------------------
-- Dig Through Data with SQL
-- by Anthony DeBarros

-- Chapter 9 Code Examples
----------------------------------------------

-- Listing 9-1: Import the FSIS Meat, Poultry, and Egg Inspection Directory
-- https://catalog.data.gov/dataset/meat-poultry-and-egg-inspection-directory-by-establishment-name


CREATE TABLE meat_poultry_egg_inspect (
    est_number varchar(50) CONSTRAINT est_number_key PRIMARY KEY,
    company varchar(100),
    street varchar(100),
    city varchar(30),
    st varchar(2),
    zip varchar(5),
    phone varchar(14),
    grant_date date,
    activities text,
    dbas text
);
CREATE INDEX company_idx ON meat_poultry_egg_inspect (company);

COPY meat_poultry_egg_inspect
-- FROM 'C:\YourDirectory\MPI_Directory_by_Establishment_Name.csv'
FROM '/Users/adebarros/Dropbox/DataMonky/Book-Writing/DigThroughDataWithSQL/Data/FSIS/MPI_Directory_by_Establishment_Name.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

-- Count the rows imported:
SELECT count(*) FROM meat_poultry_egg_inspect;

-- Listing 9-2: Find multiple companies at the same address
SELECT company, street, city, st, count(street)
FROM meat_poultry_egg_inspect
GROUP BY company, street, city, st
HAVING count(street) > 1
ORDER BY company, street, city, st;

-- Listing 9-3: Group and count states
SELECT st, count(st)
FROM meat_poultry_egg_inspect
GROUP BY st
ORDER BY st;

-- Listing 9-4: Use IS NULL to find which rows are missing a state
SELECT est_number, company, city, st, zip
FROM meat_poultry_egg_inspect
WHERE st IS NULL;

-- Listing 9-5: GROUP BY and count() to find inconsistent company names

SELECT company, count(company)
FROM meat_poultry_egg_inspect
GROUP BY company
ORDER BY company ASC;

-- Listing 9-6: Using length() and count() to test the zip column

SELECT length(zip), count(length(zip))
FROM meat_poultry_egg_inspect
GROUP BY length(zip)
ORDER BY length(zip) ASC;

-- Listing 9-7: Using length to find short zip values

SELECT st, count(st)
FROM meat_poultry_egg_inspect
WHERE length(zip) < 5
GROUP BY st
ORDER BY st ASC;

-- Listing 9-8: Two ways to back up a table

-- Method one:
CREATE TABLE meat_poultry_egg_inspect_backup AS
SELECT * FROM meat_poultry_egg_inspect;

-- Method two:
SELECT * INTO meat_poultry_egg_inspect_backup
FROM meat_poultry_egg_inspect;

-- Check number of records:
SELECT COUNT(*) FROM meat_poultry_egg_inspect;
-- Check number of records:
SELECT COUNT(*) FROM meat_poultry_egg_inspect_backup;


-- Listing 9-9: Creating and filling the st_copy column with ALTER TABLE and UPDATE

ALTER TABLE meat_poultry_egg_inspect ADD COLUMN st_copy varchar(5);

UPDATE meat_poultry_egg_inspect
SET st_copy = st;

-- Listing 9-10: Check values in the st and st_copy columns
SELECT st, st_copy
FROM meat_poultry_egg_inspect
ORDER BY st;

-- Listing 9-11: Update the st column for three establishments

UPDATE meat_poultry_egg_inspect
SET st = 'NE'
WHERE est_number = 'V18677A';

UPDATE meat_poultry_egg_inspect
SET st = 'AL'
WHERE est_number = 'M45319+P45319';

UPDATE meat_poultry_egg_inspect
SET st = 'WI'
WHERE est_number = 'M263A+P263A+V263A';

-- Listing 9-12: Creating and filling the company_standard column

ALTER TABLE meat_poultry_egg_inspect ADD COLUMN company_standard varchar(100);

UPDATE meat_poultry_egg_inspect
SET company_standard = company;

-- Listing 9-13: UPDATE field values that match a string

UPDATE meat_poultry_egg_inspect
SET company_standard = 'Armour-Eckrich Meats'
WHERE company LIKE 'Armour%';

SELECT company, company_standard
FROM meat_poultry_egg_inspect
WHERE company LIKE 'Armour%';

-- Listing 9-14: Creating and filling the zip_copy column

ALTER TABLE meat_poultry_egg_inspect ADD COLUMN zip_copy varchar(5);

UPDATE meat_poultry_egg_inspect
SET zip_copy = zip;

-- Listing 9-15: UPDATE zip codes missing two leading zeroes

UPDATE meat_poultry_egg_inspect
SET zip = '00' || zip
WHERE st IN('PR','VI');

-- Listing 9-16: UPDATE zip codes missing one leading zero

UPDATE meat_poultry_egg_inspect
SET zip = '0' || zip
WHERE st IN('CT','MA','ME','NH','NJ','RI','VT');

-- Listing 9-17: Create a state_regions table

CREATE TABLE state_regions (
    st varchar(2) CONSTRAINT st_key PRIMARY KEY,
    region varchar(20) NOT NULL
);

CREATE INDEX st_idx ON state_regions (st);

COPY state_regions
-- FROM 'C:\YourDirectory\state_regions.csv'
FROM '/Users/adebarros/Dropbox/DataMonky/Book-Writing/DigThroughDataWithSQL/Data/state_regions.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

-- Listing 9-18: Add and UPDATE an inspection_date column

UPDATE meat_poultry_egg_inspect m
SET inspection_date = '12/1/2019'
WHERE EXISTS (SELECT s.region
              FROM state_regions s
              WHERE m.st = s.st AND s.region = 'New England');

-- Listing 9-19: View updated inspection_date values

SELECT st, inspection_date
FROM meat_poultry_egg_inspect
GROUP BY st, inspection_date
ORDER BY st;

-- Listing 9-20: DELETE rows matching an expression

DELETE FROM meat_poultry_egg_inspect
WHERE st IN('PR','VI');

-- Listing 9-21: DROP a column from a table

ALTER TABLE meat_poultry_egg_inspect DROP COLUMN zip_copy;

-- Listing 9-22: DROP a table from a database

DROP TABLE meat_poultry_egg_inspect_backup;
