#!/bin/sh

rm -f $1


echo "CREATE TABLE locations (location TEXT NOT NULL PRIMARY KEY, longitude REAL NOT NULL, latitude REAL NOT NULL , longdir TEXT, latdir TEXT, width INTEGER NOT NULL, height INTEGER NOT NULL, UNIQUE(location));" | sqlite3 $1

echo "CREATE TABLE card (rowId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, level INTEGER, cardname TEXT, storyonly INTEGER, cardlogo BLOB, year INTEGER, location TEXT, category TEXT, cardtext TEXT, credittext TEXT, crediturl TEXT, FOREIGN KEY(location) REFERENCES locations(location));" | sqlite3 $1

echo "CREATE TABLE stories(rowId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, storyname TEXT NOT NULL);" | sqlite3 $1

echo "CREATE TABLE storypage(rowId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, pagenumber INTEGER NOT NULL, storyname TEXT NOT NULL, storytext BLOB NOT NULL, correctcardname TEXT NOT NULL, answerordermatters INTEGER NOT NULL, answertext BLOB NOT NULL);" | sqlite3 $1

