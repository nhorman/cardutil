#!/bin/sh

rm -f $1


echo "CREATE TABLE locations (location TEXT NOT NULL PRIMARY KEY, longitude REAL NOT NULL, latitude REAL NOT NULL , longdir TEXT, latdir TEXT, width INTEGER NOT NULL, height INTEGER NOT NULL, UNIQUE(location));" | sqlite3 $1

echo "CREATE TABLE card (rowId INTEGER PRIMARY KEY AUTOINCREMENT, level INTEGER, cardlogo BLOB, year INTEGER, location TEXT, category TEXT, cardtext TEXT, credittext TEXT, crediturl TEXT, FOREIGN KEY(location) REFERENCES locations(location));" | sqlite3 $1


