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
nova="/etc/nova/nova.conf"

openstack-config --set $nova neutron rpc_backend rabbit
openstack-config --set $nova neutron url  http://controller:9696
openstack-config --set $nova neutron auth_url  http://controller:35357
openstack-config --set $nova neutron auth_type  password
openstack-config --set $nova neutron project_domain_name  default
openstack-config --set $nova neutron user_domain_name  default
openstack-config --set $nova neutron region_name  RegionOne
openstack-config --set $nova neutron project_name  service
openstack-config --set $nova neutron username  neutron
openstack-config --set $nova neutron password  $NEUTRON_PASS
