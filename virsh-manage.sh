

sudo virsh save openstack3_controller openstack3_controller_0
sudo virsh save openstack3_network openstack3_network_0
sudo virsh save openstack3_compute1 openstack3_compute1_0
sudo virsh save openstack3_compute2 openstack3_compute2_0
sudo virsh save openstack3_block1 openstack3_block1_0
sudo virsh save openstack3_object1 openstack3_object1_0
sudo virsh save openstack3_object2 openstack3_object2_0
sudo virsh save openstack3_share1 openstack3_share1_0
sudo virsh save openstack3_share2 openstack3_share2_0


#!/bin/bash
START=$(date +%s)

vagrant up --no-parallel

END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"
