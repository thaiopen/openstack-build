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

echo "Create neutron user with password $NEUTRON_PASS"
openstack user create --domain default --password-prompt neutron
echo "Add user neutron to project service as admin"
openstack role add --project service --user neutron admin
echo "create service neutron"
openstack service create --name neutron --description "OpenStack Networking" network
echo "create network endpoint"
openstack endpoint create --region RegionOne network public http://controller:9696
openstack endpoint create --region RegionOne network internal http://controller:9696
openstack endpoint create --region RegionOne network admin http://controller:9696

echo "endpoint list"
openstack endpoint list
