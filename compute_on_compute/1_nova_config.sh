#!/bin/bash

if [ -z "$ADMIN_TOKEN" ]; then
    echo "Sorry!! Need to run 'source passwordlist'"
    echo "Auto source passwordlist"
    source ../passwordlist
fi


file="/etc/nova/nova.conf"
echo ""
echo "Target config file: $file"
openstack-config --set $file DEFAULT rpc_backend  rabbit
openstack-config --set $file oslo_messaging_rabbit rabbit_host controller
openstack-config --set $file oslo_messaging_rabbit rabbit_userid openstack
openstack-config --set $file oslo_messaging_rabbit rabbit_password $RABBIT_PASS
openstack-config --set $file DEFAULT auth_strategy keystone

openstack-config --set $file keystone_authtoken auth_uri  http://controller:5000
openstack-config --set $file keystone_authtoken auth_url  http://controller:35357
openstack-config --set $file keystone_authtoken memcached_servers  controller:11211
openstack-config --set $file keystone_authtoken auth_type  password
openstack-config --set $file keystone_authtoken project_domain_name  default
openstack-config --set $file keystone_authtoken user_domain_name  default
openstack-config --set $file keystone_authtoken project_name  service
openstack-config --set $file keystone_authtoken username  nova
openstack-config --set $file keystone_authtoken password  $NOVA_PASS

openstack-config --set $file DEFAULT my_ip 10.0.0.31
openstack-config --set $file DEFAULT use_neutron True
openstack-config --set $file DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver

openstack-config --set $file vnc enabled True
openstack-config --set $file vnc vncserver_listen 0.0.0.0
openstack-config --set $file vnc vncserver_proxyclient_address \$my_ip
openstack-config --set $file vnc novncproxy_base_url http://controller:6080/vnc_auto.html
openstack-config --set $file glance api_servers http://controller:9292
openstack-config --set $file oslo_concurrency lock_path /var/lib/nova/tmp
echo ""
echo "egrep -c '(vmx|svm)' /proc/cpuinfo"
egrep -c '(vmx|svm)' /proc/cpuinfo
echo ""
echo "Finalize installation"
systemctl enable libvirtd.service openstack-nova-compute.service
systemctl start libvirtd.service openstack-nova-compute.service

