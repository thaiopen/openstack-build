#!/bin/bash

if [ -z "$ADMIN_TOKEN" ]; then
    echo "Sorry!! Need to run 'source passwordlist'"
    echo "Auto source passwordlist"
    source ../passwordlist
fi


file="/etc/glance/glance-api.conf"
echo ""
echo "Target config file: $file"
openstack-config --set  $file database connection mysql+pymysql://glance:$GLANCE_DBPASS@controller/glance
openstack-config --set  $file keystone_authtoken auth_uri  http://controller:5000
openstack-config --set  $file keystone_authtoken auth_url  http://controller:35357
openstack-config --set  $file keystone_authtoken memcached_servers  controller:11211
openstack-config --set  $file keystone_authtoken auth_type  password
openstack-config --set  $file keystone_authtoken project_domain_name  default
openstack-config --set  $file keystone_authtoken user_domain_name  default
openstack-config --set  $file keystone_authtoken project_name  service
openstack-config --set  $file keystone_authtoken username  glance
openstack-config --set  $file keystone_authtoken password  $GLANCE_PASS
openstack-config --set  $file paste_deploy  flavor keystone
openstack-config --set  $file glance_store stores file,http
openstack-config --set  $file glance_store default_store file
openstack-config --set  $file glance_store filesystem_store_datadir /var/lib/glance/images/

registry="/etc/glance/glance-registry.conf"
echo ""
echo "Target config file: $registry"
openstack-config --set $registry database connection mysql+pymysql://glance:$GLANCE_DBPASS@controller/glance
openstack-config --set $registry keystone_authtoken auth_uri http://controller:5000
openstack-config --set $registry keystone_authtoken auth_url http://controller:35357
openstack-config --set $registry keystone_authtoken memcached_servers controller:11211
openstack-config --set $registry keystone_authtoken auth_type password
openstack-config --set $registry keystone_authtoken project_domain_name  default
openstack-config --set $registry keystone_authtoken user_domain_name default
openstack-config --set $registry keystone_authtoken project_name service
openstack-config --set $registry keystone_authtoken username glance
openstack-config --set $registry keystone_authtoken password $GLANCE_PASS
openstack-config --set $registry paste_deploy flavor keystone

echo ""
echo "Get variable on $registry"
openstack-config --get $registry database connection 
openstack-config --get $registry keystone_authtoken auth_uri 
openstack-config --get $registry keystone_authtoken auth_url 
openstack-config --get $registry keystone_authtoken memcached_servers 
openstack-config --get $registry keystone_authtoken auth_type 
openstack-config --get $registry keystone_authtoken project_domain_name  
openstack-config --get $registry keystone_authtoken user_domain_name 
openstack-config --get $registry keystone_authtoken project_name 
openstack-config --get $registry keystone_authtoken username 
openstack-config --get $registry keystone_authtoken password 
openstack-config --get $registry paste_deploy flavor 


echo ""
echo "Populate Database"
echo "Ignore any deprecation messages in this output"
echo "monitor by tail -f /var/log/glance/api.log on other terminal"
su -s /bin/sh -c "glance-manage db_sync" glance

echo "Finalize installation"
echo "Start Image service: openstack-glance-api.service openstack-glance-registry.service"

systemctl enable openstack-glance-api.service openstack-glance-registry.service
systemctl start openstack-glance-api.service openstack-glance-registry.service   

echo "Verify image service on port 9292"
echo "netstat -tapnu | grep 9292"
netstat -tapnu | grep 9292 > /dev/tty


