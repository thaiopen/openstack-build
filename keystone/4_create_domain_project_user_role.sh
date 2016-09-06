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

echo "Create default domain"
openstack domain create --description "Default Domain" default
echo "Create admin project"
openstack project create --domain default --description "Admin Project" admin
echo "Create admin user, please set admin password $ADMIN_PASS"
openstack user create --domain default --password-prompt admin
echo "Create admin role"
openstack role create admin
echo "Add 'admin' role to project and user"
openstack role add --project admin --user admin admin

echo "Create service project"
openstack project create --domain default --description "Service Project" service
echo "Create Demo project"
openstack project create --domain default --description "Demo Project" demo
echo "Create Demo user, please set demo password $DEMO_PASS"
openstack user create --domain default --password-prompt demo
echo "Create user role"
openstack role create user
echo "Add user role to demo project and user"
openstack role add --project demo --user demo user

