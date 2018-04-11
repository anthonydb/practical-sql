## Practical SQL: A Beginner's Guide to Storytelling with Data

### FAQ and Updates

This page contains answers to Frequently Asked Questions as well as additional information and clarifications on material in the book.

### Introduction

#### Working with pgAdmin: Change in pgAdmin app

Starting with version 3.0 of pgAdmin, released in April 2018, the app loads as a tab within your default web browser. Previous versions run as a standalone desktop application. All other functionality described in the book remains the same.

### Chapter 14: Analyzing Spatial Data with PostGIS

#### macOS PostGIS Shapefile and DBF Loader Exporter Unavailable

As noted on page 257 of the book, the shapefile GUI tool that's available for Windows and Linus is unfortunately no longer maintained for macOS. If that changes, I'll note here. In the meantime, use the `shp2pgsql` utility covered in Chapter 16 to load shapefiles into your database. The commands for both the Census county data and the New Mexico roads and waterways are [here](https://github.com/anthonydb/practical-sql/blob/master/Chapter_16/psql_commands.txt#L81).

### Chapter 15: Saving Time with Views, Functions, and Triggers

#### PL/Python Extension Windows Installation Error

When attempting to run the command `CREATE EXTENSION plpythonu;` from Listing 15-14 on page 281, Windows users may receive the error `could not access file "$libdir/plpython2": No such file or directory`. This means PostgreSQL was unable to find the necessary Python language files on your system. It seems the Language Pack from the Enterprise DB installer doesn't always place the Python language support files where needed.

After some investigation, I discovered that the file `plpython3.dll` included with PostgreSQL during the Windows installation has a dependency of `python34.dll`, which is not present unless you have Python 3.4 installed on your system.

To remedy the situation:

* Download the latest 32-bit Python 3.4 installer from the [Python site](https://www.python.org/downloads/windows/).
* Run the installer.
* When it finishes, open a File Explorer window and search for `python34.dll`.
* Copy the file (not moving it) to `C:\Windows\System32`.
* You then should be able to execute the command `CREATE EXTENSION plpython3u;` within your database.
