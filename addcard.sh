#!/bin/sh


DB=$1
JSONFILE=$2
TMPDIR=$(mktemp -d addcard.XXXXXX)

function cleanup()
{
	rm -rf $TMPDIR 
}

trap cleanup EXIT

CARDLOGO=$(jq -r '.cardlogo' $JSONFILE)
LOGONAME=$(basename $CARDLOGO)
LEVEL=$(jq -r '.level' $JSONFILE)
YEAR=$(jq -r '.year' $JSONFILE)
LOCATION=$(jq '.location' $JSONFILE)
CARDTEXT=$(jq '.cardtext' $JSONFILE)
CREDITTEXT=$(jq '.credittext' $JSONFILE)
CREDITURL=$(jq  '.crediturl' $JSONFILE)
CARDCROP=$(jq -r '.cardcrop' $JSONFILE)

if [ "$CARDCROP" == "null" ]
then
	CARDCROP=""
fi

echo "Building card $JSONFILE"

#get the card logo
curl -s -o $TMPDIR/$LOGONAME "$CARDLOGO"

#convert it to a png file at a small size
convert $TMPDIR/$LOGONAME  $CARDCROP -resize 128x128 +repage -colors 32 $TMPDIR/cardlogo.png
composite -compose atop -gravity center $TMPDIR/cardlogo.png borders/cardborder.png $TMPDIR/cardfullimage.png
convert $TMPDIR/cardfullimage.png -crop 168x188+719+988 +repage -resize 148x168 +repage -colors 32 -gravity south -pointsize 10 -annotate +0+10 "$CARDTEXT" $TMPDIR/logo.png

#insert the data into the table
echo "insert into card(cardlogo, level, year, location, cardtext, credittext, crediturl) " \
     "values(x'"$(hexdump -v -e '1/1 "%02x"' $TMPDIR/logo.png)"', $LEVEL, $YEAR, $LOCATION, $CARDTEXT, $CREDITTEXT, $CREDITURL);" | sqlite3 $DB
