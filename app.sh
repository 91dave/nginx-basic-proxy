#!/bin/sh

# Clear out sites in /etc/nginx/sites-enabled
#rm /etc/nginx/sites-enabled/*

# Setup all sites passed to us via env vars
env | grep SITE_ | while read entry
do

    ./setup.sh $entry

done
