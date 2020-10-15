#!/bin/sh
export RLOC=$*

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

echo "Set location for $RLOC"
echo :-n "longitude: "
read LONGITUDE 

echo -n "North or South [N/S]: "
read LONGDIR

echo -n "lattitude: "
read LATITUDE 

echo -n "East or West [E/W]: "
read LATDIR

WIDTH=20
HEIGHT=20

FROMTOP=$(dc -e "3 k $LONGITUDE 90 / 331 * p")
if [ "$LONGDIR" == "s" ]
then
	FROMTOP=$(dc -e "3 k $FROMTOP 90 + p")
fi

FROMLEFT=$(dc -e "3 k $LATITUDE 180 / 530 * p")

if [ "$LATDIR" == "w" ]
then
	FROMLEFT=$(dc -e "3 k 530 $FROMLEFT - p")
fi

cat <<< $(jq --arg RLOC "$GRLOC" --arg FROMLEFT $FROMLEFT --arg FROMTOP $FROMTOP --arg WIDTH $WIDTH --arg HEIGHT $HEIGHT \
 '.locations[.locations | length ] |= . + {"location":$RLOC,"fromleft":$FROMLEFT|tonumber,"fromtop":$FROMTOP | tonumber ,"width":$WIDTH | tonumber ,"height":$HEIGHT | tonumber}' ./locations/cardlocations.json) > ./locations/cardlocations.json


