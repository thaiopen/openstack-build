#!/bin/bash

if [ -z "$ADMIN_TOKEN" ]; then
    echo "Sorry!! Need to run 'source passwordlist'"
    echo "Auto source passwordlist"
    source ../passwordlist
fi

echo "Environment Varaible"
echo "ADMIN_TOKEN= $ADMIN_TOKEN"
service=`systemctl is-active mariadb`
if [ "$service"  = "active" ]; then
    echo "Mariadb status: Active"
else
    echo "Mariadb is stop. Auto start mariadb..."
    systemctl start mariadb
    systemctl enable mariadb
fi

read -p "Press enter to continue"


export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3

echo "Create keystone service"
openstack service create --name keystone --description "OpenStack Identity" identity 
echo "Create keystone endpoint public"
openstack endpoint create --region RegionOne identity public http://controller:5000/v3 
echo "Create keystone endpoint internal"
openstack endpoint create --region RegionOne identity internal http://controller:5000/v3 
echo "Create keystone endpoint admin"
openstack endpoint create --region RegionOne identity admin http://controller:35357/v3

echo "Verify Service"
openstack service list
echo "Verify Endpoint"
openstack endpoint list
