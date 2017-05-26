#!/bin/bash
echo "Updating /etc/hosts:"
NGINX_CONTAINER_IP=$(cat /etc/hosts | grep nginx | awk 'NR==1 {print $1}')

rm -f /etc/varnish/sites.vcl
rm -f /etc/varnish/vcl_recv.vcl
rm -f /etc/varnish/other_vcl_recv.vcl

STR=$(echo $OTHER_BACKENDS | sed 's/[][]//g;s/\"//g')
IFS=', ' read -r -a array <<< $STR

BACKEND_NAME=$(echo "id$BACKEND" | sed 's/\.//g')
sed "s/<BACKEND_NAME>/$BACKEND_NAME/;s/<BACKEND_HOST>/$BACKEND/" < /etc/varnish/docs/sites.vcl.TEMPLATE >> /etc/varnish/sites.vcl

for OTHER_BACKEND in "${array[@]}"
do
	OTHER_BACKEND_NAME=$(echo $OTHER_BACKEND | sed 's/\.//g')
    echo "$NGINX_CONTAINER_IP $OTHER_BACKEND" >> /etc/hosts
    sed "s/<BACKEND_NAME>/$OTHER_BACKEND_NAME/;s/<BACKEND_HOST>/$OTHER_BACKEND/" < /etc/varnish/docs/sites.vcl.TEMPLATE >> /etc/varnish/sites.vcl
    sed "s/<BACKEND_NAME>/$BACKEND_NAME/" < /etc/varnish/docs/vcl_recv.vcl.TEMPLATE > /etc/varnish/vcl_recv.vcl
    sed "s/<BACKEND_HOST>/$OTHER_BACKEND/;s/<BACKEND_NAME>/$OTHER_BACKEND_NAME/" < /etc/varnish/docs/other_vcl_recv.vcl.TEMPLATE >> /etc/varnish/other_vcl_recv.vcl
done


echo "Starting supervisor:"
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
