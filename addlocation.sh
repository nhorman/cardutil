#!/bin/sh

TMPDIR=$(mktemp -d addlocation.XXXXXX)

function cleanup()
{
        rm -rf $TMPDIR
}

trap cleanup EXIT

export COUNTRYCODE=$1
shift
export RLOC=$*

#Create the output file if it doesnt exist
if [ ! -f locations/cardlocations.json ]
then
cat << EOF > ./locations/cardlocations.json
{
	"locations":[]
}
EOF
fi

#strip quotes, if any
GRLOC=$(echo $RLOC | tr -d '"')
#check locations list to see if we need to add it
FOUNDLOC=$(jq -r --arg RLOC "$GRLOC" '.locations[] | select(.location==$RLOC) | .location' ./locations/cardlocations.json)

if [ -n "$FOUNDLOC" ]
then
	echo "Found location info for $GRLOC"
	exit 0
else
	echo "No location found for $GRLOC"
fi

WIDTH=20
HEIGHT=20

#Try to get location from opencage
curl -s -G -o $TMPDIR/opencage.json --data-urlencode "countrycode=$COUNTRYCODE" --data-urlencode "location=$GRLOC" "https://api.opencagedata.com/geocode/v1/json?q=%{location}&countrycode=%{countrycode}&key=4079fa880a1b4d83b3a9b07a9323b64a"
LONGRESULT=$(jq -r '.results[0].annotations.DMS.lng' $TMPDIR/opencage.json | tr -cd '[:print:]' | tr -d \')
LATRESULT=$(jq -r '.results[0].annotations.DMS.lat' $TMPDIR/opencage.json | tr -cd '[:print:]' | tr -d \')

if [ -n "$LONGRESULT" -a -n "$LATRESULT" ]
then
	LONGDEG=$(echo $LONGRESULT | cut -d" " -f1)
	LONGMIN=$(echo $LONGRESULT | cut -d" " -f2)
	LATDEG=$(echo $LATRESULT | cut -d" " -f1)
	LATMIN=$(echo $LATRESULT | cut -d" " -f2)

	LATITUDE=$(dc -e "3 k $LATMIN 60 / $LATDEG + p")
	LONGITUDE=$(dc -e "3 k $LONGMIN 60 / $LONGDEG + p")
	if [ "$EW" == "E" ]
	then
		LONGDIR="East"
	else
		LONGDIR="West"
	fi
	if [ "$NS" == "N" ]
	then
		LATDIR="North"
	else
		LATDIR="South"
	fi
else
	echo "Set location for $RLOC"

	echo -n "lattitude: "
	read LATITUDE 

	echo -n "North or South [n/s]: "
	read LATDIR

	echo -n "longitude: "
	read LONGITUDE 

	echo -n "East or West [e/w]: "
	read LONGDIR

	if [ "$LONGDIR" == "e" ]
	then
		LONGDIR="East"
	else
		LONGDIR="West"
	fi

	if [ "$LATDIR" = "n" ]
	then
		LATDIR="North"
	else
		LATDIR="South"
	fi
fi

cat <<< $(jq --arg RLOC "$GRLOC" --arg LATITUDE $LATITUDE --arg LONGITUDE $LONGITUDE --arg LONGDIR $LONGDIR --arg LATDIR $LATDIR --arg WIDTH $WIDTH --arg HEIGHT $HEIGHT \
 '.locations[.locations | length ] |= . + {"location":$RLOC,"longitude":$LONGITUDE|tonumber,"latitude":$LATITUDE | tonumber ,"longdir":$LONGDIR, "latdir":$LATDIR, "width":$WIDTH | tonumber ,"height":$HEIGHT | tonumber}' ./locations/cardlocations.json) > ./locations/cardlocations.json

