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

echo "create glance user with password $GLANCE_PASS"
openstack user create --domain default --password-prompt glance
openstack role add --project service --user glance admin

echo "Create glance service"
openstack service create --name glance --description "OpenStack Image" image
echo "Create glance service enpoint public"
openstack endpoint create --region RegionOne image public http://controller:9292
echo "Create glance service enpoint internal"
openstack endpoint create --region RegionOne image internal http://controller:9292
echo "Create glance service enpoint admin"
openstack endpoint create --region RegionOne image admin http://controller:9292

echo "Verify glance user and endpoing"
openstack service list
openstack endpoint list
