#!/bin/sh

site=$(echo $1 | cut -d= -f1 | cut -d_ -f2)
args=$(echo $@ | cut -d= -f2-)

root=/etc/nginx/
conf=$root/conf.d/$site.conf

echo $args | tr '|' '\n' > vars.$site.sh
source vars.$site.sh
rm vars.$site.sh


echo "Setting up new site with site=$site, endpoint=$endpoint, port=$port, host=$host" 
([ -z "$site" ] || [ -z "$endpoint" ] || [ -z "$port" ]) && echo You must specify site, endpoint and port && exit

conf=/etc/nginx/conf.d/$site.conf

echo server { > $conf
if [ -n "$host" ]
then
    echo "  server_name $host;" >> $conf
fi
echo "  listen $port;" >> $conf
echo "  location / {" >> $conf
echo "    return 301 $endpoint;" >> $conf
echo "  }" >> $conf
echo "}" >> $conf

echo "Config for $site"
cat $conf


