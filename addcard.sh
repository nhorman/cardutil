#!/bin/sh

DB=$1
JSONFILE=$2
CATEGORY=$3
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

if [ -z "$CATEGORY" ]
then
	CATEGORY="Any"
fi

if [ "$CARDCROP" == "null" ]
then
	CARDCROP=""
fi

#Check and maybe add the card location to our json list
./addlocation.sh $LOCATION

#Now add the location to the locations db, but only if it doesn't exist
SLOCATION=$(echo $LOCATION | tr -d '"')
L_LOCATION=$(jq -r --arg LOCATION $SLOCATION '.locations[] | select(.location==$LOCATION) | .location' locations/cardlocations.json)
L_FROMLEFT=$(jq --arg LOCATION $SLOCATION '.locations[] | select(.location==$LOCATION) | .fromleft' locations/cardlocations.json)
L_FROMTOP=$(jq --arg LOCATION $SLOCATION '.locations[] | select(.location==$LOCATION) | .fromtop' locations/cardlocations.json)
L_WIDTH=$(jq --arg LOCATION $SLOCATION '.locations[] | select(.location==$LOCATION) | .width' locations/cardlocations.json)
L_HEIGHT=$(jq --arg LOCATION $SLOCATION '.locations[] | select(.location==$LOCATION) | .height' locations/cardlocations.json)
echo "Adding location to locations table"
echo "INSERT OR IGNORE INTO locations(location, fromleft, fromtop, width, height) values(\"$L_LOCATION\", $L_FROMLEFT, $L_FROMTOP, $L_WIDTH, $L_HEIGHT);" | sqlite3 $DB
echo "Building card $JSONFILE"

#get the card logo
curl -s -o $TMPDIR/$LOGONAME "$CARDLOGO"

#convert it to a png file at a small size
convert $TMPDIR/$LOGONAME  $CARDCROP -resize 128x128 +repage -colors 32 $TMPDIR/cardlogo.png
composite -compose atop -gravity center $TMPDIR/cardlogo.png borders/cardborder.png $TMPDIR/cardfullimage.png
convert $TMPDIR/cardfullimage.png -crop 168x188+719+988 +repage -resize 148x168 +repage -colors 32 -gravity south -pointsize 10 -annotate +0+10 "$CARDTEXT" $TMPDIR/logo.png

#insert the data into the table
echo "insert into card(cardlogo, level, year, location, category, cardtext, credittext, crediturl) " \
     "values(x'"$(hexdump -v -e '1/1 "%02x"' $TMPDIR/logo.png)"', $LEVEL, $YEAR, $LOCATION, \"$CATEGORY\", $CARDTEXT, $CREDITTEXT, $CREDITURL);" | sqlite3 $DB
