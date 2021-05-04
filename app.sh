#!/bin/sh

# Clear out sites in /etc/nginx/sites-enabled
rm /etc/nginx/conf.d/* >& /dev/null
rm /etc/nginx/*.passwd >& /dev/null
cp /etc/nginx/custom.conf /etc/nginx/conf.d >& /dev/null


# Add Basic authentication lines to .passwd files
env | grep BASIC_ | while read entry
do
    
    file=$(echo $entry | cut -d= -f1 | cut -d_ -f2)
    basic=$(echo $entry | cut -d= -f2)

    echo $basic >> /etc/nginx/$file.passwd

done

# Setup all sites and redirects passed to us via env vars

env | grep SITE_ | while read entry
do

    ./setup-site.sh "$entry"

done

env | grep REDIRECT_ | while read entry
do

    ./setup-redirect.sh "$entry"

done


use_es=false
[ -n "$ES_LOG_URL" ] && [ -n "$ES_LOG_INDEX" ] && use_es=true

if [ "$use_es" = "true" ]
then

	cp json.conf /etc/nginx/conf.d
    echo "Using Elastic Search logging, writing logs to $ES_LOG_URL/$ES_LOG_INDEX"

	nginx -g 'daemon off;' | while read log
	do
		
        #timestamp=$(date +%Y-%m-%dT%H:%M:%S.000000000Z)
		index=$(date $ES_LOG_INDEX)
        entry=$(echo $log | sed -e "s/EXTRAPROPS/$ES_LOG_PROPS/g" )

        echo $entry | curl -X POST $ES_LOG_URL/$index/logs -d @- -H "Content-Type: application/json" -s
        echo ""
        echo $entry
	done

else
	cp text.conf /etc/nginx/conf.d
    echo "Using text-only logging"
	nginx -g 'daemon off;'
fi


