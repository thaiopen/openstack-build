#!/bin/bash
cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.back
file="/etc/neutron/neutron.conf"

openstack-config --set $file database connection mysql+pymysql://neutron:$NEUTRON_DBPASS@controller/neutron
openstack-config --set $file DEFAULT core_plugin ml2
openstack-config --set $file DEFAULT service_plugins
openstack-config --set $file DEFAULT rpc_backend rabbit
openstack-config --set $file oslo_messaging_rabbit rabbit_host controller
openstack-config --set $file oslo_messaging_rabbit rabbit_userid openstack
openstack-config --set $file oslo_messaging_rabbit rabbit_password $RABBIT_PASS

openstack-config --set $file DEFAULT auth_strategy keystone
openstack-config --set $file keystone_authtoken  uth_uri  http://controller:5000
openstack-config --set $file keystone_authtoken  auth_url  http://controller:35357
openstack-config --set $file keystone_authtoken  memcached_servers  controller:11211
openstack-config --set $file keystone_authtoken  auth_type  password
openstack-config --set $file keystone_authtoken  project_domain_name  default
openstack-config --set $file keystone_authtoken  user_domain_name  default
openstack-config --set $file keystone_authtoken  project_name  service
openstack-config --set $file keystone_authtoken  username  neutron
openstack-config --set $file keystone_authtoken  password  $NEUTRON_PASS

openstack-config --set $file DEFAULT notify_nova_on_port_status_changes True
openstack-config --set $file DEFAULT notify_nova_on_port_data_changes True

openstack-config --set $file nova  auth_url http://controller:35357
openstack-config --set $file nova  auth_type password
openstack-config --set $file nova  project_domain_name default
openstack-config --set $file nova  user_domain_name default
openstack-config --set $file nova  region_name RegionOne
openstack-config --set $file nova  project_name service
openstack-config --set $file nova  username nova
openstack-config --set $file nova  password $NOVA_PASS
