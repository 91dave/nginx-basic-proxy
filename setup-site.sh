#!/bin/sh

site=$(echo $1 | cut -d= -f1 | cut -d_ -f2)
args=$(echo $@ | cut -d= -f2-)

endpoint=$(echo $args | cut -d '|' -f1)
port=$(echo $args | cut -d '|' -f2)
servername=$(echo $args | cut -d '|' -f3)
internal=$(echo $args | cut -d '|' -f4)
bodysize=$(echo $args | cut -d '|' -f5)

echo "Setting up new site with site=$site, endpoint=$endpoint, port=$port, servername=$servername" 
([ -z "$site" ] || [ -z "$endpoint" ] || [ -z "$port" ]) && echo You must specify site, endpoint and port && exit

conf=/etc/nginx/conf.d/$site.conf

# add default passwords
if [ -f "/etc/nginx/all.passwd" ]
then
    cat /etc/nginx/all.passwd >> /etc/nginx/$site.passwd
fi

# Create nginx.conf for site
echo server { > $conf

if [ -n "$servername" ]
then
    echo "  server_name $servername;" >> $conf
fi

if [ -n "$bodysize" ]
then
    echo "  client_max_body_size $bodysize;" >> $conf
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
echo "    proxy_set_header Host \$http_host;" >> $conf

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

