#!/bin/bash

if [ -z "$ADMIN_TOKEN" ]; then
    echo "Sorry!! Need to run 'source passwordlist'"
    echo "Auto source passwordlist"
    source ../passwordlist
fi


file="/etc/nova/nova.conf"
echo ""
echo "Target config file: $file"
openstack-config --set $file DEFAULT enabled_apis osapi_compute,metadata
openstack-config --set $file api_database connection mysql+pymysql://nova:$NOVA_DBPASS@controller/nova_api
openstack-config --set $file database connection mysql+pymysql://nova:$NOVA_DBPASS@controller/nova
openstack-config --set $file DEFAULT rpc_backend rabbit
openstack-config --set $file oslo_messaging_rabbit rabbit_host controller
openstack-config --set $file oslo_messaging_rabbit rabbit_userid openstack
openstack-config --set $file oslo_messaging_rabbit rabbit_password $RABBIT_PASS

openstack-config --set $file DEFAULT auth_strategy keystone
openstack-config --set $file keystone_authtoken auth_uri http://controller:5000
openstack-config --set $file keystone_authtoken auth_url http://controller:35357
openstack-config --set $file keystone_authtoken memcached_servers controller:11211
openstack-config --set $file keystone_authtoken auth_type password
openstack-config --set $file keystone_authtoken project_domain_name default
openstack-config --set $file keystone_authtoken user_domain_name default
openstack-config --set $file keystone_authtoken project_name service
openstack-config --set $file keystone_authtoken username nova
openstack-config --set $file keystone_authtoken  password $NOVA_PASS

openstack-config --set $file DEFAULT my_ip 10.0.0.11 
openstack-config --set $file DEFAULT use_neutron True
openstack-config --set $file DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver

openstack-config --set $file vnc vncserver_listen \$my_ip
openstack-config --set $file vnc vncserver_proxyclient_address \$my_ip

openstack-config --set $file glance api_servers http://controller:9292
openstack-config --set $file oslo_concurrency lock_path /var/lib/nova/tmp

echo ""
echo "Populate Database"
echo "Ignore any deprecation messages in this output"
echo "monitor by tail -f /var/log/nova/api.log on other terminal"
su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage db sync" nova

echo "Finalize installation"
systemctl enable openstack-nova-api.service 
systemctl enable openstack-nova-consoleauth.service openstack-nova-scheduler.service
systemctl enable openstack-nova-conductor.service openstack-nova-novncproxy.service

systemctl start openstack-nova-api.service 
systemctl start openstack-nova-consoleauth.service openstack-nova-scheduler.service
systemctl start openstack-nova-conductor.service openstack-nova-novncproxy.service


echo "Verify compute service on port 8774"
echo "netstat -tapnu | grep 8774"
netstat -tapnu | grep 8774 > /dev/tty


