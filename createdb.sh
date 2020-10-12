#!/bin/sh

echo "CREATE TABLE card (rowId INTEGER PRIMARY KEY AUTOINCREMENT, cardlogo BLOB, year INTEGER, location TEXT, cardtext TEXT, credittext TEXT, crediturl TEXT);" | sqlite3 $1


