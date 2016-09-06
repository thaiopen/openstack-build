#!/bin/bash
cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.back
bridge="/etc/neutron/plugins/ml2/linuxbridge_agent.ini"
PROVIDER_INTERFACE_NAME=eth0
echo "Configure the Linux bridge agent"
openstack-config --set $bridge linux_bridge physical_interface_mappings provider:$PROVIDER_INTERFACE_NAME
openstack-config --set $bridge vxlan enable_vxlan False
openstack-config --set $bridge securitygroup enable_security_group true 
openstack-config --set $bridge securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver 

