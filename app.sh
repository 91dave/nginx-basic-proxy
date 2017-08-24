#!/bin/sh

# Clear out sites in /etc/nginx/sites-enabled
rm /etc/nginx/conf.d/*

# Setup all sites passed to us via env vars
env | grep SITE_ | while read entry
do

    ./setup-site.sh $entry

done

env | grep REDIRECT_ | while read entry
do

    ./setup-redirect.sh $entry

done

nginx -g 'daemon off;'

