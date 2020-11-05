#!/bin/sh
DB=$1
JSONFILE=$2
TMPDIR=$(mktemp -d addstory.XXXXXX)

function cleanup()
{
	rm -rf $TMPDIR 
}

trap cleanup EXIT


echo "Building story $JSONFILE"
STORYNAME=$(jq '.storyname' $JSONFILE)

#insert the story into the story table
echo "insert into stories(storyname) values($STORYNAME);" | sqlite3 $DB

PAGECOUNT=$(jq '.pages | length' $JSONFILE)
let PAGECOUNT=$PAGECOUNT-1

for i in `seq 0 1 $PAGECOUNT`
do
	let PAGENUMBER=$i+1
	echo "Building page $i for story $STORYNAME"
	PAGEFILE=$(jq --argjson idx "$i" -r '.pages[$idx].pagefile' $JSONFILE)

	# copy the html for the pages and convert any ANSWER tokens to input
	BASEPAGEFILE=$(basename $PAGEFILE)
	cp $PAGEFILE $TMPDIR/$BASEPAGEFILE
	for p in `grep -o "ANSWER[0-9]\+" $TMPDIR/$BASEPAGEFILE | sort | uniq`
	do 
		sed -i -e"s/\(\\$\)\($p\)/<input type=text readOnly=true value=\2 class=\"ANSWER\"><\/input>/g" $TMPDIR/$BASEPAGEFILE
	done
	PAGEFILE=$TMPDIR/$BASEPAGEFILE
	ANSWERFILE=$(jq --argjson idx "$i" -r '.pages[$idx].answerfile' $JSONFILE)
	ANSWERORDERMATTERS=$(jq --argjson idx "$i" -r '.pages[$idx].answerordermatters' $JSONFILE)
	CORRECTCARDS=""
	CORRECTCOUNT=$(jq --argjson idx "$i" '.pages[$idx].correctcards | length' $JSONFILE)
	let CORRECTCOUNT=$CORRECTCOUNT-1
	for j in `seq 0 1 $CORRECTCOUNT`
	do
		NEWCARD=$(jq -r --argjson idx "$i" --argjson jidx "$j" '.pages[$idx].correctcards[$jidx]' $JSONFILE)

		# Check to see if the card exists in the db
		echo "select * from card where cardname=\"$NEWCARD\"" | sqlite3 $DB > /dev/null
		if [ $? -ne 0 ]
		then
			echo "ERROR: CARDNAME $NEWCARD doesn't exist in the database!"
			exit 1
		fi
		if [ -z "$CORRECTCARDS" ]
		then
			CORRECTCARDS="$NEWCARD"
		else
			CORRECTCARDS="$CORRECTCARDS:$NEWCARD"
		fi
	done
	if [ "$ANSWERFILE" == "none" ]
	then
		echo "insert into storypage (pagenumber, storyname, storytext, correctcardname, answerordermatters, answertext) values ($PAGENUMBER, $STORYNAME, readfile(\"$PAGEFILE\"), \"$CORRECTCARDS\", $ANSWERORDERMATTERS, \"none\");" | sqlite3 $DB 
	else
		echo "insert into storypage (pagenumber, storyname, storytext, correctcardname, answerordermatters, answertext) values ($PAGENUMBER, $STORYNAME, readfile(\"$PAGEFILE\"), \"$CORRECTCARDS\", $ANSWERORDERMATTERS, readfile(\"$ANSWERFILE\"));" | sqlite3 $DB 
	fi

done
