#!/bin/bash
 
if [ -z "$ADMIN_TOKEN" ]; then
    echo "Sorry!! Need to run 'source passwordlist'"
    echo "Auto source passwordlist"
    source ../passwordlist
fi

echo "source admin-openrc"
if [ -f admin-openrc ]; then
    echo "File admin-openrc  exist"
    source admin-openrc
else
    echo "File admin-openrc does not exist"
fi

cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.back
neutron="/etc/neutron/neutron.conf"
echo "Configure the common component"
openstack-config --set $neutron DEFAULT rpc_backend rabbit
openstack-config --set $neutron oslo_messaging_rabbit rabbit_host controller
openstack-config --set $neutron oslo_messaging_rabbit rabbit_userid openstack
openstack-config --set $neutron oslo_messaging_rabbit rabbit_password $RABBIT_PASS

openstack-config --set $neutron DEFAULT auth_strategy keystone
openstack-config --set $neutron keystone_authtoken auth_uri  http://controller:5000
openstack-config --set $neutron keystone_authtoken auth_url  http://controller:35357
openstack-config --set $neutron keystone_authtoken memcached_servers controller:11211
openstack-config --set $neutron keystone_authtoken auth_type  password
openstack-config --set $neutron keystone_authtoken project_domain_name  default
openstack-config --set $neutron keystone_authtoken user_domain_name  default
openstack-config --set $neutron keystone_authtoken project_name  service
openstack-config --set $neutron keystone_authtoken username  neutron
openstack-config --set $neutron keystone_authtoken password  $NEUTRON_PASS

openstack-config --set $neutron oslo_concurrency lock_path /var/lib/neutron/tmp

echo "Done"
