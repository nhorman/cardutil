#!/bin/sh

DB=$1
LIST=$2
LISTFILE=$(basename $LIST)
CATEGORY=`echo $LISTFILE | cut -d'.' -f1`

for i in `cat $LIST`
do
	if [ "$CATEGORY" != "stories" ]
	then
		./addcard.sh $DB $i $CATEGORY y
	else
		./addcard.sh $DB $i $CATEGORY n
	fi
done

