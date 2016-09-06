#!/bin/bash
if [ -z "$ADMIN_TOKEN" ]; then
    echo "Sorry!! Need to run 'source passwordlist'"
    echo "Auto source passwordlist"
    source ../passwordlist
fi

echo "source admin-openrc"
source admin-openrc
echo ""
echo "openstack compute service list"
openstack compute service list
