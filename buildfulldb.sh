#!/bin/sh
DB=$1

echo "Creating Database"
./createdb.sh $DB

echo "Adding all card categories"
for i in `ls categories/*.txt`
do
	./addcardlist.sh $DB $i
done

echo "Adding stories to database"
for i in `ls stories/*.json`
do
	./addstory.sh $DB $i
done

