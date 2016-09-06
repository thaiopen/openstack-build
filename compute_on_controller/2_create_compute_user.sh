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

echo "create compute user (nova) with password $NOVA_PASS"
openstack user create --domain default --password-prompt nova
openstack role add --project service --user nova admin

echo "Create nova service (compute)"
openstack service create --name nova --description "OpenStack Compute" compute
echo "Create compute service api endpoint public"
openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1/%\(tenant_id\)s
echo "Create glance service api endpoint internal"
openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1/%\(tenant_id\)s
echo "Create glance service api endpoint admin"
openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1/%\(tenant_id\)s
echo "Verify glance user and endpoing"
openstack service list
openstack endpoint list
