#!/bin/sh

site=$(echo $1 | cut -d= -f1 | cut -d_ -f2)
args=$(echo $@ | cut -d= -f2-)

root=/etc/nginx/
conf=$root/conf.d/$site.conf

echo $args | tr '|' '\n' > vars.$site.sh
source vars.$site.sh
rm vars.$site.sh

[ -z "$echohost" ] && echohost="true"

echo "Setting up new site with site=$site, endpoint=$endpoint, port=$port, host=$host, echohost=$echohost" 
([ -z "$site" ] || [ -z "$endpoint" ] || [ -z "$port" ]) && echo You must specify site, endpoint and port && exit

echo $auth_files | tr ',' '\n' | while read file
do
    [ -f "$root/$file.passwd" ] && cat $root/$file.passwd >> $root/$site.passwd
done


# Create nginx.conf for site
echo server { > $conf


if [ -n "$host" ]
then
    echo "  server_name $host;" >> $conf
fi

if [ -n "$max_request" ]
then
    echo "  client_max_body_size $max_request;" >> $conf
fi

echo "  listen $port;" >> $conf
echo "  set \$endpoint $endpoint;" >> $conf
echo "  location / {" >> $conf

if [ -f "/etc/nginx/$site.passwd" ]
then
    echo '    auth_basic "Restricted";' >> $conf
    echo "    auth_basic_user_file /etc/nginx/$site.passwd;" >> $conf
    echo '    proxy_set_header Authorization "";' >> $conf
fi

echo "    proxy_set_header X-Forwarded-For \$remote_addr;" >> $conf

if [ "$echohost" = "true" ]
then
    echo "    proxy_set_header Host \$http_host;" >> $conf
fi

if [ "$internal" = "true" ]
then
    echo "    proxy_pass $endpoint;" >> $conf
else
    echo "    proxy_pass \$endpoint;" >> $conf
    echo "    resolver 8.8.8.8;" >> $conf
fi

echo "  }" >> $conf
echo "}" >> $conf

echo "Config for $site"
cat $conf

