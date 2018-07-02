## Practical SQL: A Beginner's Guide to Storytelling with Data

### FAQ and Updates

This page contains answers to Frequently Asked Questions as well as additional information and clarifications on material in the book.

### Introduction

#### Working with pgAdmin: Change in pgAdmin app

Figure 1 on page xxxiii of the Introduction shows the pgAdmin app's opening screen. Beginning with version 3.0 of pgAdmin, released in April 2018, the application loads as a tab within your default web browser. Previous versions of pgAdmin run as a standalone desktop application. All other functionality for pgAdmin described in the book remains the same.

### Chapter 14: Analyzing Spatial Data with PostGIS

#### macOS PostGIS Shapefile and DBF Loader Exporter Unavailable

As noted on page 257 of the book, the shapefile GUI tool that's available for Windows and Linux is unfortunately no longer maintained for macOS. If that changes, I'll note here. In the meantime, use the `shp2pgsql` utility covered in Chapter 16 to load shapefiles into your database. The commands for both the Census county data and the New Mexico roads and waterways are [here](https://github.com/anthonydb/practical-sql/blob/master/Chapter_16/psql_commands.txt#L81).

### Chapter 15: Saving Time with Views, Functions, and Triggers

#### PL/Python Extension Windows Installation Error

When attempting to run the command `CREATE EXTENSION plpythonu;` from Listing 15-14 on page 281, Windows users may receive the error `could not access file "$libdir/plpython2": No such file or directory`. This means PostgreSQL was unable to find the necessary Python language files on your system.

Upon investigation, I discovered that the file `plpython3.dll` included with PostgreSQL during the EnterpriseDB Windows installation is looking for the file `python34.dll` to be present in the `C:\Windows\System32` directory. This file is included with the EDB Language Pack but not placed in that directory.

Here's how to remedy the situation. Note that you must have installed the EDB Language Pack as described on page xxx of the introduction to "Practical SQL":

* Using your File Explorer, navigate to `C:\edb\languagepack-10\x64\Python-3.4`
* Copy the file `python34.dll` (right-click and select Copy).
* Using File Explorer, navigate to `C:\Windows\System32` and paste the file.
* You then should be able to execute the command `CREATE EXTENSION plpython3u;` within your database. Note that this command is slightly different than in the book. You're naming `plpython3u` instead of `plpythonu`.
