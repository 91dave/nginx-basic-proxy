#!/bin/sh

site=$(echo $1 | cut -d= -f1 | cut -d_ -f2)
args=$(echo $@ | cut -d= -f2-)

endpoint=$(echo $args | cut -d '|' -f1)
port=$(echo $args | cut -d '|' -f2)
servername=$(echo $args | cut -d '|' -f3)

echo "Setting up new site with site=$site, endpoint=$endpoint, port=$port, servername=$servername" 
([ -z "$site" ] || [ -z "$endpoint" ] || [ -z "$port" ]) && echo You must specify site, endpoint and port && exit

conf=/etc/nginx/conf.d/$site.conf

echo server { > $conf
if [ -n "$servername" ]
then
    echo "  server_name $servername;" >> $conf
fi
echo "  listen $port;" >> $conf
echo "  location / {" >> $conf
echo "    return 301 $endpoint;" >> $conf
echo "  }" >> $conf
echo "}" >> $conf

echo "Config for $site"
cat $conf


