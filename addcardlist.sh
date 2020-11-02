#!/bin/sh

DB=$1
LIST=$2
LISTFILE=$(basename $LIST)
CATEGORY=`echo $LISTFILE | cut -d'.' -f1`

for i in `cat $LIST`
do
	if [ "$LISTFILE" == "stories" ]
	then
		./addcard.sh $DB $i $CATEGORY 1
	else
		./addcard.sh $DB $i $CATEGORY 0
	fi
done

