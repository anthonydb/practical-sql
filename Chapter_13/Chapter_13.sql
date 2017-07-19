--------------------------------------------------------------
-- Practical SQL: A Beginner's Guide to Storytelling with Data
-- by Anthony DeBarros

-- Chapter 13 Code Examples
--------------------------------------------------------------

-- Commonly used string functions
-- Full list at https://www.postgresql.org/docs/current/static/functions-string.html

-- Case formatting
SELECT upper('Neal7');
SELECT lower('Randy');
SELECT initcap('at the end of the day');
-- Note initcap's imperfect for acronyms
SELECT initcap('Practical SQL');

-- Character Information
SELECT char_length(' Pat ');
SELECT length(' Pat ');
SELECT position(', ' in 'Tan, Bella');

-- Removing characters
SELECT trim(' Pat ');
SELECT char_length(trim(' Pat ')); -- note the length change
SELECT trim('s' from 'socks');
SELECT trim(trailing 's' from 'socks');
SELECT ltrim('socks', 's');
SELECT rtrim('socks', 's');

-- Extracting and replacing characters
SELECT left('703-555-1212', 3);
SELECT right('703-555-1212', 8);
SELECT replace('bat', 'b', 'c');


-- Table 13-2: Regular Expression Matching Examples

-- Any character one or more times
SELECT substring('The game starts at 7 p.m. on May 2, 2017.' from '.+');
-- One or two digits followed by a space and p.m.
SELECT substring('The game starts at 7 p.m. on May 2, 2017.' from '\d{1,2} (?:a.m.|p.m.)');
-- One or more word characters at the start
SELECT substring('The game starts at 7 p.m. on May 2, 2017.' from '^\w+');
-- One or more word characters followed by any character at the end.
SELECT substring('The game starts at 7 p.m. on May 2, 2017.' from '\w+.$');
-- The words May or June
SELECT substring('The game starts at 7 p.m. on May 2, 2017.' from 'May|June');
-- Four digits
SELECT substring('The game starts at 7 p.m. on May 2, 2017.' from '\d{4}');
-- May followed by a space, digit, comma, space, and four digits.
SELECT substring('The game starts at 7 p.m. on May 2, 2017.' from 'May \d, \d{4}');


-- Turning Text to Data with Regular Expression Functions

-- Listing 13-2: Create and load the crime_reports table
-- Data from https://sheriff.loudoun.gov/dailycrime

CREATE TABLE crime_reports (
    crime_id bigserial PRIMARY KEY,
    date_1 date,
    date_2 date,
    hour_1 time with time zone,
    hour_2 time with time zone,
    street varchar(250),
    city varchar(100),
    crime_type varchar(100),
    description text,
    case_number varchar(50),
    original_text text NOT NULL
);

COPY crime_reports (original_text)
FROM 'C:\YourDirectory\crime_reports.csv'
WITH (FORMAT CSV, HEADER OFF, QUOTE '"');

SELECT original_text FROM crime_reports;

-- Listing 13-3: Use regexp_matches() to find the first date
SELECT crime_id,
       regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}')
FROM crime_reports;

-- Listing 13-4: Adding the 'g' flag to regexp_matches()
SELECT crime_id,
       regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}', 'g')
FROM crime_reports;

-- Listing 13-5: Matching the second date
-- Note that the result includes an unwanted hyphen
SELECT crime_id,
       regexp_matches(original_text, '-\d{1,2}\/\d{1,2}\/\d{1,2}')
FROM crime_reports;

-- Listing 13-6: Using a capture group to return only the date
-- Eliminates the hyphen
SELECT crime_id,
       regexp_matches(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})')
FROM crime_reports;

-- Listing 13-7: Matching case number, date, crime type, and city

SELECT
    regexp_matches(original_text, '(?:C0|SO)[0-9]+') AS case_number,
    regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}') AS date_1,
    regexp_matches(original_text, '\n(?:\w+ \w+|\w+)\n(.*):') AS crime_type,
    regexp_matches(original_text, '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n')
        AS city
FROM crime_reports;

-- Bonus: Get all parsed elements at once

SELECT crime_id,
       regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}') AS date_1,
       CASE WHEN EXISTS (SELECT regexp_matches(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})'))
            THEN regexp_matches(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})')
            ELSE NULL
            END AS date_2,
       regexp_matches(original_text, '\/\d{2}\n(\d{4})') AS hour_1,
       CASE WHEN EXISTS (SELECT regexp_matches(original_text, '\/\d{2}\n\d{4}-(\d{4})'))
            THEN regexp_matches(original_text, '\/\d{2}\n\d{4}-(\d{4})')
            ELSE NULL
            END AS hour_2,
       regexp_matches(original_text, 'hrs.\n(\d+ .+(?:Sq.|Plz.|Dr.|Ter.|Rd.))') AS street,
       regexp_matches(original_text, '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n') AS city,
       regexp_matches(original_text, '\n(?:\w+ \w+|\w+)\n(.*):') AS crime_type,
       regexp_matches(original_text, ':\s(.+)(?:C0|SO)') AS description,
       regexp_matches(original_text, '(?:C0|SO)[0-9]+') AS case_number
FROM crime_reports;

-- Listing 13-8: Using unnest() to retrieve an array value

SELECT
    crime_id,
    unnest(
           regexp_matches(original_text, '(?:C0|SO)[0-9]+')
           ) AS case_number
FROM crime_reports;

-- Listing 13-9: Updating the crime_reports date_1 column

UPDATE crime_reports
SET
    date_1 = unnest(
                    regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}')
                    )::date;

SELECT crime_id,
       date_1,
       original_text
FROM crime_reports;

-- Listing 13-10: Updating all crime_reports columns

UPDATE crime_reports
SET
    date_1 = unnest(regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))::date,

    date_2 = CASE WHEN EXISTS (
                  SELECT regexp_matches(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})')
                              )
             THEN unnest(regexp_matches(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})')
                        )::date
             ELSE NULL END,

    hour_1 = unnest(regexp_matches(original_text, '\/\d{2}\n(\d{4})'))::timetz,

    hour_2 = CASE WHEN EXISTS (
                  SELECT regexp_matches(original_text, '\/\d{2}\n\d{4}-(\d{4})')
                              )
                  THEN unnest(
                              regexp_matches(original_text, '\/\d{2}\n\d{4}-(\d{4})')
                              )::timetz
                  ELSE NULL END,

    street = unnest(regexp_matches(original_text, 'hrs.\n(\d+ .+(?:Sq.|Plz.|Dr.|Ter.|Rd.))')),
    city = unnest(regexp_matches(original_text,
                                 '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n')),
    crime_type = unnest(regexp_matches(original_text, '\n(?:\w+ \w+|\w+)\n(.*):')),
    description = unnest(regexp_matches(original_text, ':\s(.+)(?:C0|SO)')),
    case_number = unnest(regexp_matches(original_text, '(?:C0|SO)[0-9]+'));


-- Listing 13-11: Viewing selected crime data

SELECT date_1,
       street,
       city,
       crime_type
FROM crime_reports;


-- Listing 13-12: Using regular expressions in a WHERE clause

SELECT geo_name
FROM us_counties_2010
WHERE geo_name ~* '(.+lade.+|.+lare.+)'
ORDER BY geo_name;

SELECT geo_name
FROM us_counties_2010
WHERE geo_name ~* '.+ash.+' AND geo_name !~*'Wash.+'
ORDER BY geo_name;


-- Listing 13-13: Regular expression functions to replace and split

SELECT regexp_replace('05/12/2017', '\d{4}', '2016');

SELECT regexp_split_to_table('Four,score,and,seven,years,ago', ',');

SELECT regexp_split_to_array('Phil Mike Tony Steve', ' ');

-- Listing 13-14: Finding an array length

SELECT array_length(regexp_split_to_array('Phil Mike Tony Steve', ' '), 1);


-- FULL TEXT SEARCH

-- Listing 13-15: Converting text to tsvector data

SELECT to_tsvector('I am walking across the sitting room to sit with you.');

-- Listing 13-16: Converting search terms to tsquery data

SELECT to_tsquery('walking & sitting');

-- Listing 13-17: Querying a tsvector type with a tsquery

SELECT to_tsvector('I am walking across the sitting room') @@ to_tsquery('walking & sitting');

SELECT to_tsvector('I am walking across the sitting room') @@ to_tsquery('walking & running');

-- Listing 13-18: Create and fill the president_speeches table

-- Sources:
-- https://archive.org/details/State-of-the-Union-Addresses-1945-2006
-- http://www.presidency.ucsb.edu/ws/index.php
-- https://www.eisenhower.archives.gov/all_about_ike/speeches.html

CREATE TABLE president_speeches (
    sotu_id serial PRIMARY KEY,
    president varchar(100) NOT NULL,
    title varchar(250) NOT NULL,
    speech_date date NOT NULL,
    speech_text text NOT NULL,
    search_speech_text tsvector
);

COPY president_speeches (president, title, speech_date, speech_text)
FROM 'C:\YourDirectory\sotu-1946-1977.csv'
WITH (FORMAT CSV, DELIMITER '|', HEADER OFF, QUOTE '@');

SELECT * FROM president_speeches;

-- Listing 13-19: Convert speeches to tsvector in the search_speech_text column
UPDATE president_speeches
SET search_speech_text = to_tsvector('english', speech_text);

-- Listing 13-20: Create a GIN index for text search
CREATE INDEX search_idx ON president_speeches USING gin(search_speech_text);


-- Full-text search operators:
-- & (AND)
-- | (OR)
-- ! (NOT)

-- Listing 13-21: Find speeches containing the word "Vietnam"

SELECT president, speech_date
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('Vietnam')
ORDER BY speech_date;

-- Listing 13-22: Displaying search results with ts_headline()

SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('Vietnam'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('Vietnam');

-- Listing 13-23: Find speeches with the word "transportation" but not "roads"

SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('transportation & !roads'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('transportation & !roads');

-- Listing 13-24: Find speeches where "defense" follows "military"

SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('military <-> defense'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('military <-> defense');

-- Example with a distance of 2:
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('military <2> defense'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=2')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('military <2> defense');

-- Listing 13-25: Scoring relevance with ts_rank()

SELECT president,
       speech_date,
       ts_rank(search_speech_text,
               to_tsquery('war & security & threat & enemy')) AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY score DESC
LIMIT 5;

-- Listing 13-26: Normalizing ts_rank() by speech length

SELECT president,
       speech_date,
       ts_rank(search_speech_text,
               to_tsquery('war & security & threat & enemy'), 2) AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY score DESC
LIMIT 5;


