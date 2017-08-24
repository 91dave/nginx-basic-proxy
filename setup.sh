#!/bin/sh

site=$(echo $1 | cut -d= -f1 | cut -d_ -f2)
endpoint=$(echo $1 | cut -d= -f2)
port=$2
servername=$3

echo "Setting up new site with site=$site, endpoint=$endpoint, port=$port, servername=$servername" 
([ -z "$site" ] || [ -z "$endpoint" ] || [ -z "$port" ]) && echo You must specify site, endpoint and port && exit

conf=$(pwd)/$site.conf

echo \$port=$port > $conf
echo \$endpoint=$endpoint >> $conf
cat site.conf >> $conf

