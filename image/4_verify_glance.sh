#!/bin/bash
if [ -z "$ADMIN_TOKEN" ]; then
    echo "Sorry!! Need to run 'source passwordlist'"
    echo "Auto source passwordlist"
    source ../passwordlist
fi

source admin-openrc
if [ ! -f cirros-0.3.4-x86_64-disk.img ]; then
 	echo "please wail, on process downloading cirros image"
	wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img --progress=dot
fi

echo ""
echo "Upload image to glance service"
openstack image create "cirros" --file cirros-0.3.4-x86_64-disk.img  --disk-format qcow2 --container-format bare --public

echo ""
echo "Confirm"
openstack image list

