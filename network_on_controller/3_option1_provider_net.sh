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

openstack-config --set $file oslo_concurrency lock_path /var/lib/neutron/tmp


echo "Configure the Modular Layer 2 (ML2)"
cp /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.back
ml2="/etc/neutron/plugins/ml2/ml2_conf.ini"

openstack-config --set $ml2 ml2 type_drivers flat,vlan
openstack-config --set $ml2 ml2 tenant_network_types 
openstack-config --set $ml2 ml2 mechanism_drivers linuxbridge
openstack-config --set $ml2 ml2 extension_drivers port_security
openstack-config --set $ml2 ml2_type_flat flat_networks provider
openstack-config --set $ml2 securitygroup enable_ipset True

echo "Configure the Linux bridge agent"
PROVIDER_INTERFACE_NAME="eth0"
cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.back
br="/etc/neutron/plugins/ml2/linuxbridge_agent.ini"
openstack-config --set $br linux_bridge physical_interface_mappings provider:$PROVIDER_INTERFACE_NAME
openstack-config --set $br vxlan enable_vxlan False
openstack-config --set $br securitygroup enable_security_group True
openstack-config --set $br securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

echo "Configure the DHCP agent"
cp /etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini.back
dhcp="/etc/neutron/dhcp_agent.ini"
openstack-config --set $dhcp DEFAULT interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver
openstack-config --set $dhcp DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
openstack-config --set $dhcp DEFAULT enable_isolated_metadata True

echo "Done option2"

