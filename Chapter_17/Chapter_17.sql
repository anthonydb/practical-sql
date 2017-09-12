--------------------------------------------------------------
-- Practical SQL: A Beginner's Guide to Storytelling with Data
-- by Anthony DeBarros

-- Chapter 17 Code Examples
--------------------------------------------------------------

-- VACUUM

-- Listing 17-1: Create a table to test vacuuming

CREATE TABLE vacuum_test (
    integer_column integer
);

-- Listing 17-2: Determine the size of vacuum_test

SELECT pg_size_pretty(
           pg_total_relation_size('vacuum_test')
       );
       
SELECT pg_size_pretty(
           pg_database_size('analysis')
       );

-- Listing 17-3: Insert 500,000 rows into vacuum_test and determine its size

INSERT INTO vacuum_test
SELECT * FROM generate_series(1,500000);

-- Test its size again
SELECT pg_size_pretty(
           pg_table_size('vacuum_test')
       );

-- Listing 17-4: Update all rows in vacuum_test and determine its size

UPDATE vacuum_test
SET integer_column = integer_column * 1;

-- Test its size again (35 MB)
SELECT pg_size_pretty(
           pg_table_size('vacuum_test')
       );

-- Listing 17-5: Viewing autovacuum statistics for vacuum_test

SELECT relname,
       last_vacuum,
       last_autovacuum,
       vacuum_count,
       autovacuum_count
FROM pg_stat_all_tables
WHERE relname = 'vacuum_test';

-- To see all columns available
SELECT *
FROM pg_stat_all_tables
WHERE relname = 'vacuum_test';

-- Listing 17-6: Running VACUUM manually

VACUUM vacuum_test;

VACUUM; -- vacuums the whole database

VACUUM VERBOSE; -- provides messages

-- Listing 17-7: Using VACUUM FULL to reclaim disk space

VACUUM FULL vacuum_test;

-- Test its size again
SELECT pg_size_pretty(
           pg_table_size('vacuum_test')
       );
       
-- SETTINGS

-- Listing 17-8: Show location of postgresql.conf

SHOW config_file;

-- Listing 17-10: Show location of data directory

SHOW data_directory;

-- reload settings
-- Mac and Linux: pg_ctl reload -D '/path/to/data/directory/'
-- Windows: pg_ctl reload -D "C:\path\to\data\directory\"


-- BACKUP AND RESTORE

-- Listing 17-11: Back up the analysis database with pg_dump
pg_dump -d analysis -U [user_name] > analysis_backup.sql

-- Back up just a table
pg_dump -t 'train_rides' -d analysis -U [user_name] > train_backup.sql 

-- Listing 17-12: Restore

-- Database

-- In psql:
CREATE DATABASE analysis;
-- At command prompt:
psql -d postgres -U [user_name] -f analysis_backup.sql

-- Table
psql -d analysis -U [user_name] -f train_backup.sql

-- Back up everything
pg_dumpall > whole_db.out
-- Restore it via psql
psql -d postgres -U [user_name] -f whole_db.out 


