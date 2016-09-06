#!/bin/bash
if [ -z "$METADATA_SECRET" ]; then
    echo "Sorry!! Need to run 'source passwordlist'"
    echo "Auto source passwordlist"
    source ../passwordlist
fi

cp /etc/neutron/metadata_agent.ini  /etc/neutron/metadata_agent.ini.back
meta="/etc/neutron/metadata_agent.ini"
echo "Config /etc/neutron/metadata_agent.ini "
openstack-config --set $meta DEFAULT nova_metadata_ip controller
openstack-config --set $meta DEFAULT metadata_proxy_shared_secret $METADATA_SECRET

echo "Configure Compute to use Networking"
cp /etc/nova/nova.conf /etc/nova/nova.conf.back
nova="/etc/nova/nova.conf"
openstack-config --set $nova neutron url http://controller:9696
openstack-config --set $nova neutron auth_url  http://controller:35357
openstack-config --set $nova neutron auth_type  password
openstack-config --set $nova neutron project_domain_name  default
openstack-config --set $nova neutron user_domain_name  default
openstack-config --set $nova neutron region_name  RegionOne
openstack-config --set $nova neutron project_name  service
openstack-config --set $nova neutron username  neutron
openstack-config --set $nova neutron password  $NEUTRON_PASS
openstack-config --set $nova neutron service_metadata_proxy  True
openstack-config --set $nova neutron metadata_proxy_shared_secret  $METADATA_SECRET

echo "Finalize installation"
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

echo "Populate the database"
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
