#!/bin/sh

rm -f $1


echo "CREATE TABLE locations (location TEXT NOT NULL PRIMARY KEY, fromleft REAL, fromtop REAL, width INTEGER, height INTEGER, UNIQUE(location));" | sqlite3 $1

echo "CREATE TABLE card (rowId INTEGER PRIMARY KEY AUTOINCREMENT, level INTEGER, cardlogo BLOB, year INTEGER, location TEXT, category TEXT, cardtext TEXT, credittext TEXT, crediturl TEXT, FOREIGN KEY(location) REFERENCES locations(location));" | sqlite3 $1


