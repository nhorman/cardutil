#!/bin/sh

DB=$1
LIST=$2

for i in `cat $LIST`
do
	./addcard.sh $DB $i
done

