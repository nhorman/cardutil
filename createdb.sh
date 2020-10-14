#!/bin/sh

echo "CREATE TABLE card (rowId INTEGER PRIMARY KEY AUTOINCREMENT, level INTEGER, cardlogo BLOB, year INTEGER, location TEXT, category TEXT, cardtext TEXT, credittext TEXT, crediturl TEXT);" | sqlite3 $1


