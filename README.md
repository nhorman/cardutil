#What is cardutil

cardutil is a collection of scripts intended to create game "cards" for the game When and Where, found on google play here:
https://play.google.com/store/apps/details?id=com.thinkfreely.whenandwhere


This suite of scripts converts a series of included json files into cards and stories used to play the game

And the best part is, you can create your own cards and use them in the game!

By creating a card database, you can place it in a reachable web location on the internet and use the game config settings to import the database to the game

#Script utilities

## createdb.sh <dbname>
This script creates an empty sqlite database used for popuation by the other scripts

## makecard.sh <cards/cardname.json>
This script will prompt you for information to generate a game card of interest to you, storing the information in the specified json file

## makestorycard.sh <cards/cardname.json>
Works identially to makecard.sh, but marks the card as being only for use in the story section of the game - useful for creation of cards that have neither an associated time or place

## addcard.sh <dbname> <card json file> <category> <storycard>
Adds the information in a card json file to the specified database under the provided category, and marks it as a story (y) or general use (n) card

## addcardlist.sh <dbname> <categories/category.txt>
Adds a list of cards of the specified category type to the specified database

## addstory.sh <dbname> <stories/story.json>
Adds a story to the story list for the game

## buildfulldb.sh <dbname>
Complete db builder script.  Runs the above scripts, creating the specified db name, and adding cards of all categories in the categories subdirectory, and all stories in the stories subdirectory



