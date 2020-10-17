#!/bin/sh


JSONFILE=$1
TMPDIR=$(mktemp -d addcard.XXXXXX)

function cleanup()
{
	rm -rf $TMPDIR 
}

trap cleanup EXIT

CARDLOGO=$(jq -r '.cardlogo' $JSONFILE)
LOGONAME=$(basename $CARDLOGO)
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
identify -verbose $TMPDIR/$LOGONAME
convert $TMPDIR/$LOGONAME  $CARDCROP -resize 128x128 +repage -colors 32 $TMPDIR/cardlogo.png
composite -compose atop -gravity center -geometry +0-15 $TMPDIR/cardlogo.png borders/newborder.png $TMPDIR/cardfullimage.png
convert $TMPDIR/cardfullimage.png -crop 168x188 +repage -resize 148x168 +repage -colors 32 -gravity south -pointsize 10 -annotate +0+10 "$CARDTEXT" $TMPDIR/logo.png

display $TMPDIR/logo.png

