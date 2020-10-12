#!/bin/sh


DB=$1
JSONFILE=$2
TMPDIR=$(mktemp -d addcard.XXXXXX)

function cleanup()
{
	rm -rf $TMPDIR 
}

trap cleanup EXIT

CARDLOGO=$(echo ${row} | jq -r '.cardlogo' $JSONFILE)
LOGONAME=$(echo ${row} | basename $CARDLOGO)
YEAR=$(echo ${row} | jq -r '.year' $JSONFILE)
LOCATION=$(echo ${row} | jq '.location' $JSONFILE)
CARDTEXT=$(echo ${row} | jq '.cardtext' $JSONFILE)
CREDITTEXT=$(echo ${row} | jq '.credittext' $JSONFILE)
CREDITURL=$(echo ${row} | jq  '.crediturl' $JSONFILE)

echo $CARDLOGO
echo $LOGONAME
echo $year

#get the card logo
curl -o $TMPDIR/$LOGONAME "$CARDLOGO"

#convert it to a png file at a small size
convert $TMPDIR/$LOGONAME  -resize 256x256 -colors 32 -border 0x30 -gravity South -annotate +0+10 "$CARDTEXT" $TMPDIR/logo.png

#insert the data into the table
echo "insert into card(cardlogo, year, location, cardtext, credittext, crediturl) " \
     "values(x'"$(hexdump -v -e '1/1 "%02x"' $TMPDIR/logo.png)"', $YEAR, $LOCATION, $CARDTEXT, $CREDITTEXT, $CREDITURL);" | sqlite3 $DB
