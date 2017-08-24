#!/bin/sh

site=$(echo $1 | cut -d= -f1 | cut -d_ -f2)
endpoint=$(echo $1 | cut -d= -f2)
port=$2
servername=$3

echo "Setting up new site with site=$site, endpoint=$endpoint, port=$port, servername=$servername" 
([ -z "$site" ] || [ -z "$endpoint" ] || [ -z "$port" ]) && echo You must specify site, endpoint and port && exit

conf=/etc/nginx/conf.d/$site.conf

echo server { > $conf
echo "listen $port;" >> $conf
echo "set \$endpoint $endpoint;" >> $conf
cat site.conf >> $conf

echo "Config for $site"
cat $conf

