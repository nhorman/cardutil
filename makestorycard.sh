#!/bin/sh

CARDFILE=$1

rm -f $CARDFILE

echo -n "Card Logo URL: "
read LOGO

echo -n "Difficulty: "
read LEVEL

YEAR=0

LOCATION=none

COUNTRYCODE=xx

echo -n "Card Text: "
read CARDTEXT

echo -n "Crop Parameters: "
read CROP

echo -n "Credit Text: "
read CREDITTEXT

echo -n "Credit URL: "
read CREDITURL

echo "{" >> $CARDFILE
echo -e "\t \"cardlogo\": \"$LOGO\"," >> $CARDFILE
echo -e "\t \"level\": $LEVEL," >> $CARDFILE
echo -e "\t \"year\": $YEAR," >> $CARDFILE
echo -e "\t \"location\": \"$LOCATION\"," >> $CARDFILE
echo -e "\t \"countrycode\": \"$COUNTRYCODE\"," >> $CARDFILE
echo -e "\t \"cardtext\": \"$CARDTEXT\"," >> $CARDFILE
echo -e "\t \"cardcrop\": \"$CARDCROP\"," >> $CARDFILE
echo -e "\t \"credittext\": \"$CREDITTEXT\"," >> $CARDFILE
echo -e "\t \"crediturl\": \"$CREITURL\"" >> $CARDFILE
echo "}" >> $CARDFILE

echo "$CARDFILE" >> categories/stories.txt


